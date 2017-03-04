#!/bin/bash

echo "Installe les packs laptop"
ZVER="1200608.1632.1200728.0044"
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

    sudo apt-get -y install gnome-power-manager cpufrequtils xfce4-volumed tpb

    sudo cp ./init.zpack /etc/init.d/
    sudo update-rc.d init.zpack defaults 
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


