#!/bin/bash

echo "Réactive l'utilisation des drivers Nvidia pour la couche X11"
echo "en renommant le fichier /etc/X11/xorg.conf.nvidia en /etc/X11/xorg.conf"
echo "zf 1200620.1420"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

sudo mv /etc/X11/xorg.conf.nvidia /etc/X11/xorg.conf

echo ""
echo "On peut faire maintenant un: sudo service slim restart"

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


