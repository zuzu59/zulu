#!/bin/bash

echo "Installe et configure le Zulu Linux à la zuzu"
ZVER="1200625.1700.1200727.2115"
echo -e "zf "$ZVER

RED='\033[1;31m'
GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

cd ~/zpack
./packages-mini.sh
./packages-first.sh
./packages-desktop.sh
./packages-laptop.sh
./packages-media.sh
./install_sun_jre.sh

# Clean les restes d'anciens zpack
sudo apt-get -y remove broadcom-sta-common

# Clean les sources de dépôts
sudo bash -c 'sort -u /etc/apt/sources.list > /etc/apt/sources.list.sort'
sudo mv /etc/apt/sources.list.sort /etc/apt/sources.list

ZSTR1=${ZVER%.*.*}
if [ "$(ls ~/.zpack/${0##*/}.$ZSTR1* 2> /dev/null)" != "" ]; then
    echo $0" déjà installé !"
else
    echo $0" pas encore installé !"
    mkdir ~/.zpack 2> /dev/null
    touch ~/.zpack/${0##*/}.$ZSTR1.`date +%Y%m%d.%H%M`

    xfdesktop&

    # Restaure le .config
    #sudo killall xfce4-panel ; sleep 4
    tar xzfP .config.tar.gz
    # reconfigure encore une fois les shortcuts clavier, ceux de packages-mini viennent d'être écrasés par le tar !
    cp ./xfce4-keyboard-shortcuts.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
    sudo pkill -HUP xfconfd
    #exec xfce4-panel &

    # Restaure le .mozilla
    tar xzfP .mozilla.tar.gz

    # Configure le desktop
    cp ./Apps\ Store.desktop ~/Desktop/
    cp ./Zulu\ Docu.desktop ~/Desktop/
    cp ./Zulu\ Spec.desktop ~/Desktop/
    cp ./xfce4-desktop.xml.two_screens ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

    # Configure gedit
    #sudo killall gconfd-2 ; sleep 3 ; 
    tar xzfP gedit-2.tar.gz
    sudo pkill -HUP gconfd-2

    # Patch l'autostart
    cp conky.desktop ~/.config/autostart/
    cp gigolo.desktop ~/.config/autostart/

    # Configure la langue du système
    sudo dpkg-reconfigure locales
fi

# Fait les mises à jour du système
sudo apt-get -y upgrade
sudo apt-get -y autoremove

echo ""
echo "Zpack terminé, il faut redémarrer la machine pour l'activer !"
echo ""

read -p "Touche ENTER pour continuer !"
xfce4-session-logout


