#!/bin/bash

echo "Désactive le menu de boot"
echo "zf 1200608.1759"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

sudo extlinux -i /
sudo extlinux-update

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


