#!/bin/bash

echo "Installe le pack impression pour imprimer sur les imprimantes windows"
ZVER="1200618.1506.1200728.0051"
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
    sudo apt-get -y install smbclient cups system-config-printer cups-bsd

    sudo usermod -G lpadmin -a $USER

    cat ./readme.windows_printers.txt

    echo ""
    echo -e ${GREEN}$0 "end..."${NOCOL}
    echo ""

    echo ""
    echo "ATTENTION, il faut redémarrer la session pour que cela fonctionne !"
    echo ""

    read -p "Touche ENTER pour continuer !"
    xfce4-session-logout
fi

