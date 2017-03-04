#!/bin/bash

echo "Installe les packs desktop"
ZVER="1200720.2140.1200728.0044"
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

    sudo apt-get -y install avahi-discover chromium-browser chromium-browser-l10n chromium-browser-inspector chromium-codecs-ffmpeg epdfview flashplugin-nonfree xvnc4viewer ssvnc tsclient filezilla gigolo gvfs-fuse wine
    sudo apt-get -y remove pyneighborhood

    # Configure Chromium comme browser par défaut dans Gnome
    gconftool-2 --type string -s /desktop/gnome/url-handlers/http/command "chromium-browser %s"
    gconftool-2 --type string -s /desktop/gnome/url-handlers/https/command "chromium-browser %s"

    # Configuration de la partie Gigolo
    sudo  gpasswd -a $USER fuse 
    mkdir ~/.gvfs
    chmod 700 ~/.gvfs
    ln -s ~/.gvfs ~/Network

    # Configuration de la partie Filezilla
    mkdir ~/.filezilla
    cp ~/zpack/sitemanager.xml ~/.filezilla/
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

