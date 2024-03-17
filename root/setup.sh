#!/bin/bash

# Ask for sudo if not running as root
if [ "$(id -u)" -ne 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

CURDIR=$(realpath $0)
CURDIR=${CURDIR%/*}
echo
echo "Working from $CURDIR"
echo

for file in etc/systemd/system/mangohud-fixes.service usr/local/bin/mangohud-fixes; do
    echo "Processing $file..."
    destination=/$file
    parent_dir=${destination%/*}
    if [ ! -d $parent_dir ]; then
        echo "Creating directory $parent_dir..."
        mkdir -p $parent_dir
    fi
    if [ -e $destination ]; then
        echo "Backing up existing $destination to $destination.bak"
        mv $destination $destination.bak
    fi
    echo "Deploying $CURDIR/$file to $destination"
    cp $CURDIR/$file $destination

    # Ensure service files are enabled
    if [[ $file =~ ".service" ]]; then
        echo "Reloading systemd..."
        service=${file##*/}
        systemctl daemon-reload
        systemctl enable $service
    fi

    echo "Done!"
    echo
done

echo "All done!"
