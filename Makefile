.PHONY: default test

default:
	mkdir -p ~/.stellarium/scripts/
	cp wallpaper.ssc ~/.stellarium/scripts/

	mkdir -p ~/.config/
	cp sway-wallpaper-stellarium.env ~/.config/

	mkdir -p ~/.config/systemd/user/
	cp swww.service sway-wallpaper-stellarium.service sway-wallpaper-stellarium.timer ~/.config/systemd/user/

	mkdir -p ~/.local/lib/
	cp sway-wallpaper-stellarium.sh ~/.local/lib/

	systemctl --user enable --now swww.service sway-wallpaper-stellarium.timer

test:
	shellcheck ./sway-wallpaper-stellarium.sh
