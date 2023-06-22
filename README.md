# sway-wallpaper-stellarium

Generate a star map using Stellarium and set it as the wallpaper of your Sway desktop.


## Runtime dependencies

1. [`sway`](https://swaywm.org/) - the compositor.

1. [`swww`](https://github.com/Horus645/swww) - wallpaper manager, to be able to change the wallpaper dynamically.

1. [`stellarium`](https://stellarium.org/) - astronomy software, to generate the star map.

1. [`ImageMagick`](https://www.imagemagick.org/) - the `convert` utility is used to chop the star map screenshot into the individual wallpapers for each output.

1. `cpulimit` - limits Stellarium's CPU usage so that it is not noticeable while it runs in the background.

1. [`gojq`](https://github.com/itchyny/gojq) or [`jq`](https://jqlang.github.io/jq/) - JSON processing utility, to munge the output of `swaymsg`.


## Files

1. `sway-wallpaper-stellarium.env` - Environment file for the Stellarium script. Edit it to contain your location's latitude and longitude.

1. `sway-wallpaper-stellarium.sh` - Wallpaper script. It runs `stellarium`, waits for the star map screenshot to be taken, uses `convert` to create the individual wallpapers for each output, and uses `swww` to update the wallpapers of each output.

1. `wallpaper.ssc` - Stellarium script to generate the star map screenshot.

1. `sway-wallpaper-stellarium.service` - User-session systemd service unit to run the wallpaper script. Invoked by the timer unit.

1. `sway-wallpaper-stellarium.timer` - User-session systemd timer unit to run the wallpaper service once every 15 minutes.

1. `swww.service` - User-session systemd service unit to run `swww` daemon.

`make install` will install all files to the appropriate directories and enable the systemd units.

Make sure to edit `~/.config/sway-wallpaper-stellarium.env` to contain your latitude and longitude.

The systemd units assume the existence of `sway-session.target` and `graphical-session.target`. Edit them as you need if your Sway setup does not use those targets.


## Other compositors?

Sway-specific things:

1. `sway-wallpaper-stellarium.sh` uses `swaymsg -t get_outputs` to discover the output names and dimensions. Something based on `zxdg_output_manager_v1` would be more compositor-agnostic.

1. `sway-wallpaper-stellarium.sh` uses `swaymsg` to run Stellarium in the background, to move it to the scratchpad, and to resize it to the size required for the screenshot. If Stellarium ever provides a way to take screenshots headlessly, this would not be necessary. Alternatively one could have a nested headless compositor and run `stellarium` against its `WAYLAND_DISPLAY` instead.

Wayland-specific things:

1. `swww` only supports Wayland compositors, specifically those that support the xdg-output-unstable-v1 and wlr-layer-shell-unstable-v1 protocols.

systemd-specific things:

1. The service and timer units. They don't do anything complicated and can be trivially replaced with your service manager's equivalents.

I'm open to PRs to make it more general.


## But how often do you look at your wallpaper if you're using a tiling WM like Sway?

Yeah I spent a few hours implementing this and then realized it's not actually useful to me :V


## License

AGPL-3.0-only

```
sway-wallpaper-stellarium

https://github.com/Arnavion/sway-wallpaper-stellarium

Copyright 2023 Arnav Singh

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, version 3 of the
License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```
