#!/bin/bash

echo "Installe le client lourd Icedove pour le courriel"
ZVER="120726.2346.1200727.2144"
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
    sudo apt-get -t squeeze-backports -y install icedove icedove-l10n-fr 
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


