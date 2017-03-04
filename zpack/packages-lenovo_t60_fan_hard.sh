#!/bin/bash

echo "Repositionne la régulation du ventilateur par le hardware"
echo "zf 1200612.1446"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

#sudo apt-get update > /dev/null
#sudo apt-get -y install vlc libdvdcss2

sudo rm /etc/fancontrol
sudo service fancontrol stop
#echo level auto | sudo tee /proc/acpi/ibm/fan
sudo rm /etc/modprobe.d/thinkpad_acpi.conf
sudo rmmod thinkpad_acpi
sudo modprobe thinkpad_acpi

./fan_status_lenovo_t60.sh

## Patch le média automount pour les CD audio et DVD vidéo
#if [ -f "~/.config/Thunar/volmanrc" ]; then
#    patch -f ~/.config/Thunar/volmanrc < ./patch.media.automount
#else
#  cp ./volmanrc ~/.config/Thunar/volmanrc
#fi


echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

