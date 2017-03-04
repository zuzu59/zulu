#!/bin/bash

echo "Installe les drivers de Nvidia de Debian"
echo "zf 1200625.1411"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

sudo apt-get update > /dev/null
sudo apt-get -y install nvidia-kernel-2.6.32-5-686-bigmem nvidia-settings nvidia-xconfig

sudo cp ./xorg.conf.nvdia.two.screens /etc/X11/xorg.conf
cp ./xfce4-desktop.xml.two_screens ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

echo ""
echo "Il faut redémarrer la machine pour l'activer !"
echo ""

read -p "Touche ENTER pour continuer !"
xfce4-session-logout

