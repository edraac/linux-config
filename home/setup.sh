#!/bin/bash

CURDIR=$(realpath $0)
CURDIR=${CURDIR%/*}
echo
echo "Working from $CURDIR"
echo
# file=destination (relative to $HOME)
declare -A files=(
    ["$CURDIR/tmux.conf"]=".tmux.conf"
    ["$CURDIR/gitconfig"]=".gitconfig"
    ["$CURDIR/MangoHud.conf"]="Games/MangoHud.conf"
    ["$CURDIR/configure-prompt.sh"]=".bashrc.d/configure-prompt.sh"
)

cd $HOME
REAL_HOME=$(realpath $HOME)

# Create missing directories
if [[ ! -d Games ]]; then
    echo "Creating Games directory..."
    mkdir -p Games
    echo "Done!"
    echo
fi
if [[ ! -d .bashrc.d ]]; then
    echo "Creating .bashrc.d directory..."
    mkdir -p .bashrc.d
    echo "Done!"
    echo
fi

# Process configuration files
for file in ${!files[@]}; do
    destination=${files[$file]}
    echo "Processing $file..."
    if [[ ! -e $file ]]; then
        echo "ERROR: $file does not exist!"
        echo
        exit 1
    fi

    if [[ -L $destination || -e $destination ]] ; then
        echo "Backing up existing $REAL_HOME/$destination to $REAL_HOME/$destination.bak"
        mv $destination $destination.bak
    fi

    echo "Linking $file to $REAL_HOME/$destination"
    ln -s $file $destination
    echo "Done!"
    echo
done

# General Flatpak settings
echo "Configuring flatpak..."
flatpak override --user --env=STEAM_FORCE_DESKTOPUI_SCALING=2 com.valvesoftware.Steam
flatpak override --user --filesystem=$REAL_HOME/Games com.valvesoftware.Steam
flatpak override --user --filesystem=$REAL_HOME/Games com.heroicgameslauncher.hgl
echo "Done!"
echo

# Ensure Steam and Heroic have access to MangoHud's config
mangohud_conf=$REAL_HOME/Games/MangoHud.conf
if [[ -L $mangohud_conf ]]; then
    echo "Enabling MangoHud config..."
    flatpak override --user --filesystem=$mangohud_conf com.valvesoftware.Steam
    flatpak override --user --env=MANGOHUD_CONFIGFILE=$mangohud_conf com.valvesoftware.Steam
    flatpak override --user --env=MANGOHUD=1 com.valvesoftware.Steam
    flatpak override --user --filesystem=$mangohud_conf com.heroicgameslauncher.hgl
    echo "Done!"
    echo
fi

echo "All done!"
