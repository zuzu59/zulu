#!/bin/bash

echo "Installe le DNS dynamique Inadyn"
ZVER="120726.2346.1200727.1736"
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
    sudo apt-get -y install inadyn

    sudo insserv -r dyndns
    sudo cp ./dyndns /etc/init.d/
    sudo insserv dyndns
    mkdir ~/Perso 2> /dev/null
    if [ -f ~/"Perso/inadyn.conf" ]; then
        echo ""
    else
        cp ./inadyn.conf ~/Perso/
        echo ""
        echo "Le service dyndns (inadyn) a été installé, il faut maintenant le configurer !"
        echo ""
        read -p "Touche ENTER pour continuer !"
        gedit ~/Perso/inadyn.conf
        read -p "Touche ENTER pour continuer !"
    fi
    sudo service dyndns restart

fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""



