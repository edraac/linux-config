#!/bin/bash

function usage {
    echo """

${0##*/} [-h] [-u] [-f [yes|no]] [-m [yes|no]]
    -h          print this message and exit
    -u          configure bash prompt for Ubuntu-based distros
    -f [yes|no] configure flatpak if "yes" (default), skip if "no"
    -m [yes|no] configure mangohud if "yes" (default), skip if "no"
"""
}

is_ubuntu=0
configure_flatpak="yes"
configure_mangohud="yes"
OPTSTRING=":uf:m:h"
while getopts ${OPTSTRING} opt; do
    case ${opt} in
        h)
            usage
            exit 0
            ;;
        u)
            is_ubuntu=1
            ;;
        f)
            if [[ $OPTARG != "yes" && $OPTARG != "no" ]]; then
                echo "ERROR: invalid value '$OPTARG' for -f"
                usage
                exit 1
            fi
            configure_flatpak=$OPTARG
            ;;
        m)
            if [[ $OPTARG != "yes" && $OPTARG != "no" ]]; then
                echo "ERROR: invalid value '$OPTARG' for -m"
                usage
                exit 1
            fi
            configure_mangohud=$OPTARG
            ;;
        :)
            echo "Option -${OPTARG} requires an argument."
            usage
            exit 1
            ;;
        ?)
            echo "Invalid option: -${OPTARG}."
            usage
            exit 1
        ;;
  esac
done

CURDIR=$(realpath $0)
CURDIR=${CURDIR%/*}
echo
echo "Working from $CURDIR"
echo
# file=destination (relative to $HOME)
declare -A files=(
    ["$CURDIR/aliases.sh"]=".bashrc.d/aliases.sh"
    ["$CURDIR/configure-prompt.sh"]=".bashrc.d/configure-prompt.sh"
    ["$CURDIR/tmux.conf"]=".tmux.conf"
    ["$CURDIR/gitconfig"]=".gitconfig"
    ["$CURDIR/MangoHud.conf"]="Games/MangoHud.conf"
    ["$CURDIR/yakuakerc"]=".config/yakuakerc"
    ["$CURDIR/Personal.profile"]=".local/share/konsole/Personal.profile"
    ["$CURDIR/BreezeTranslucent.colorscheme"]=".local/share/konsole/BreezeTranslucent.colorscheme"
)
REAL_HOME=$(realpath $HOME)

function link_file {
    file=$1
    destination=$2
    echo "Processing $file..."
    if [[ ! -e $file ]]; then
        echo "ERROR: $file does not exist!"
        echo
        exit 1
    fi

    # Back up existing file if it's not a symlink, delete if so
    if [[ -e $destination && ! -L $destination ]] ; then
        echo "Backing up existing $REAL_HOME/$destination to $REAL_HOME/$destination.bak"
        mv $destination $destination.bak
    elif [[ -L $destination ]]; then
        rm $destination
    fi

    echo "Linking $file to $REAL_HOME/$destination"
    ln -s $file $destination
    echo "Done!"
    echo
}

cd $HOME

# Create missing directories
if [[ ! -d Games && ( $configure_flatpak == "yes" ||
        $configure_mangohud == "yes" ) ]]; then
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

# Link configuration files
for file in ${!files[@]}; do

    if [[ $file =~ "MangoHud" && $configure_mangohud == "no" ]]; then
        continue
    fi

    destination=${files[$file]}
    link_file $file $destination
done

# Configure prompt for Ubuntu
if [[ $is_ubuntu -eq 1 ]]; then
    link_file "$CURDIR/configure-prompt-ubuntu.sh" ".bashrc.d/configure-prompt-ubuntu.sh"
    if [[ $(grep configure-prompt-ubuntu ~/.bashrc) == "" ]]; then
        echo ". ~/.bashrc.d/configure-prompt-ubuntu.sh" >> ~/.bashrc
    fi
fi

# General Flatpak settings
if [[ $configure_flatpak == "yes" ]]; then
    echo "Configuring flatpak..."
    flatpak override --user --env=STEAM_FORCE_DESKTOPUI_SCALING=2 com.valvesoftware.Steam
    flatpak override --user --filesystem=$REAL_HOME/Games com.valvesoftware.Steam
    flatpak override --user --filesystem=$REAL_HOME/Games com.heroicgameslauncher.hgl
    echo "Done!"
    echo
else
    echo "Skipping flatpak configuration..."
    echo
fi

# Ensure Steam and Heroic have access to MangoHud's config
if [[ $configure_mangohud == "yes" ]]; then
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
else
    echo "Skipping MangoHud configuration..."
    echo
fi

echo "All done!"
