#!/bin/bash

set -euo pipefail
shopt -s inherit_errexit

if command -v 'gojq'; then
    JQ='gojq'
else
    JQ='jq'
fi

eval "$(
    # `shellcheck` thinks the $'s in the jq filter are shell variables and tells us that shell variables don't expand in single-quoted strings.
    #
    # shellcheck disable=SC2016
    swaymsg -t get_outputs |
        "$JQ" --raw-output '
            map({ x_min: .rect.x, x_max: (.rect.x + .rect.width), y_min: .rect.y, y_max: (.rect.y + .rect.height) }) as $rects |
            "x_min=\($rects | map(.x_min) | min); x_max=\($rects | map(.x_max) | max); y_min=\($rects | map(.y_min) | min); y_max=\($rects | map(.y_max) | max);"
        '
)"

pkill -x -9 stellarium || :

swaymsg -q 'for_window [app_id = "org.stellarium.stellarium"] move scratchpad';

(
    while [ "$(swaymsg -t get_tree | "$JQ" '[.nodes[] | .. | select(.app_id? == "org.stellarium.stellarium")] | length')" -lt 2 ]; do
        sleep 1
    done

    # `shellcheck` warns that `{x,y}_{max,min}` are not defined. They would be defined by the `eval` above.
    #
    # shellcheck disable=SC2154
    swaymsg -q "[app_id = \"org.stellarium.stellarium\"] resize set width $(( x_max - x_min )) px height $(( y_max - y_min )) px"
) &

cpulimit -f -l 10 -m -- \
    stellarium \
        --full-screen no \
        --screenshot-dir "$XDG_RUNTIME_DIR" \
        --startup-script 'wallpaper.ssc'

# `shellcheck` warns about not putting the `$()` expr in a double-quoted string.
# But we need word-splitting to occur on the output of `jobs -pr`.
#
# shellcheck disable=SC2046
wait $(jobs -pr)

eval "$(
    swaymsg -t get_outputs |
        "$JQ" \
            --arg XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR" \
            --argjson X_MIN "$x_min" \
            --argjson X_MAX "$x_max" \
            --argjson Y_MIN "$y_min" \
            --argjson Y_MAX "$y_max" \
            --raw-output \
            $'
                .[] |
                (
                    "convert \'\\($XDG_RUNTIME_DIR)/wallpaper.png\' -crop \'\\(.rect.width)x\\(.rect.height)+\\(.rect.x - $X_MIN)+\\(.rect.y - $Y_MIN)\' \'png32:\\($XDG_RUNTIME_DIR)/wallpaper-\\(.name).png\'; " +
                    "swww img --outputs \'\\(.name)\' --no-resize --fill-color 222222 --transition-step 255 \'\\($XDG_RUNTIME_DIR)/wallpaper-\\(.name).png\';"
                )
            '
)"

pkill -x -9 stellarium || :
