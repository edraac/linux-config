# linux-config

Personal configuration to be done on any Linux fresh install.
It has only been tested in Fedora Kinoite 40.

## Home Directory

The following configurations are included and deployed or executed:

* bash prompt configuration (colors, git branch, etc)
* tmux.conf
* gitconfig
* MangoHud.conf
* Various flatpak overrides for Steam and Heroic Games Launcher

Where possible, symlinks are created so configuration updates can be manged in
git and pulled to existing deployments.

Execution:

```
cd linux-config/home
./setup.sh
```

## Root Files

The following is currently done:

* a simple service to fix CPU power usage read permissions on start up, so
MangoHud can poll and display this value.

Execution:

```
cd linux-config/root
sudo ./setup.sh
```
