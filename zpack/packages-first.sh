#!/bin/bash

echo "Installe les packs first"
ZVER="1200628.2252.1200728.0044"
echo -e "zf "$ZVER

RED='\033[1;31m'
GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

ZSTR1=${ZVER%.*.*}
if [ "$(ls ~/.zpack/$0.$ZSTR1* 2> /dev/null)" != "" ]; then
    echo $0" déjà installé !"
else
    echo $0" pas encore installé !"
    mkdir ~/.zpack 2> /dev/null
    touch ~/.zpack/$0.$ZSTR1.`date +%Y%m%d.%H%M`

    echo "apt-get update..."
    sudo apt-get update > /dev/null

    sudo apt-get -y install zip squeeze vino synaptic gedit-plugins gparted htop iotop bzip2 conky curl baobab gdebi gnome-disk-utility gnome-search-tool gnome-system-monitor update-manager-gnome xfce4-goodies gnome-system-log gconf-editor gnome-schedule

    sudo apt-get -y remove xfce4-power-manager

    cp ./.xscreensaver ~/
    mkdir -p ~/.local/share/xfce4/helpers
    cp ./chromium-browser.desktop ~/.local/share/xfce4/helpers/
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

