#!/bin/bash

echo "Active le menu de boot"
echo "zf 1200625.1059"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

# Fix extlinux default
UUID="$(sudo blkid -o value $(mount |grep '/ type ext4' | cut -f1 -d' ') | head -n 1)"
sudo sed -i "s/EXTLINUX_ROOT=.*/EXTLINUX_ROOT=\"root=UUID=$UUID\"/" /etc/default/extlinux
# Use the right extlinux
sudo extlinux -i /boot/extlinux
sudo extlinux-update

sudo cp /home/zulu/zpack/zulu_logo_640_480_1.png /boot/extlinux/themes/debian/splash.png

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


