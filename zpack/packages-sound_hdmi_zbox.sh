#!/bin/bash

echo "Compile et installe les drivers nvidia pour la zbox"
echo "zf 1200620.1412"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

cp ./.asoundrc ~/.
sudo cp ~/zpack/sound-zbox-hdmi.conf /etc/modprobe.d/
sudo apt-get -y install pulseaudio pavucontrol

echo ""
echo ""
echo "Pour avoir le son sur la sortie HDMI d'une zBox, il faut"
echo "avoir un kernel 3.2, les drivers Nvidia de chez Nvidia,"
echo "le modprobe balcklist, le fichier .asoundrc et le pulsaudio."
echo "Pour cela faire tourner les zpack/packages:"
echo "packages-kernel_3.2.686.sh et packages-nvidia_zbox_part_1.sh"
echo ""
echo "Plus d'info sur:"
echo "http://wiki.debian.org/InstallingDebianOn/Zotac/Zbox/squeeze"

echo ""
echo -e ${GREEN}$"De toute façon, il faudra redémarrer la machine afin que le module son pour l'HDMI soit chargé dans le noyau !"${NOCOL}

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


