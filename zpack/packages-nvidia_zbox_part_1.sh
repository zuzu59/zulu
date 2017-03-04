#!/bin/bash

echo "Compile et installe les drivers nvidia pour la zbox"
echo "zf 1200618.1545"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

zURL='http://us.download.nvidia.com/XFree86/Linux-x86/295.53/NVIDIA-Linux-x86-295.53.run'
zFILE=${zURL##*/}
echo $zURL
echo $zFILE

cd ~/Desktop
mkdir nvidia
cd nvidia
rm $zFILE*
wget $zURL
chmod +x $zFILE
sudo apt-get update > /dev/null
sudo apt-get install build-essential linux-headers-2.6.32-5-686 linux-headers-3.2.0-0.bpo.2-686-pae 
sudo cp ~/zpack/nvidia-installer-disable-nouveau.conf /etc/modprobe.d/

echo "Il faut rédémarrer la machine maintenant, puis après quand on est avec le bureau, faire CTRL-ALT-F2"
echo "Se logger puis faire tourner zpack/packages-nvidia_zbox_part_2.sh"

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

read -p "Touche ENTER pour continuer !"
xfce4-session-logout

