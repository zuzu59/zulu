#!/bin/bash

echo "Installe le kernel 3.2"
ZVER="1200608.1835.1200727.2144"
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
    sudo apt-get -t squeeze-backports -y install initramfs-tools linux-base linux-image-3.2.0-0.bpo.2-686-pae
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


