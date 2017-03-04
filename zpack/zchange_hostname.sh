#!/bin/bash

echo "Change le nom de la machine"
echo "jb/zf 1200724.1711"

RED='\033[1;31m'
GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

zend(){
    echo ""
    echo -e ${GREEN}$0 "end..."${NOCOL}
    echo ""
}  

if [ $# -ne 1 ]; then
    echo -e ${RED} "Usage: sudo $0 <hostname>"${NOCOL}
    zend
    exit 1

fi

echo "Nom actuel: \"$HOSTNAME\""

HOSTNAME="$@"
if [ $(grep $HOSTNAME /etc/hosts > /dev/null; echo $?) -ne 0 ]; then
    if [ $(grep 127.0.1.1 /etc/hosts > /dev/null; echo $?) -eq 0 ]; then
        sudo sed -i "s/127.0.1.1.*/127.0.1.1 $HOSTNAME/" /etc/hosts
    else
        sudo su -c "echo 127.0.1.1 $HOSTNAME >> /etc/hosts"
    fi
fi

sudo su -c "echo $HOSTNAME > /etc/hostname"

echo "Nouveau nom: \"$HOSTNAME\""

echo ""
echo "Le nom de la machine est changé, il faut ABSOLUMENT redémarrer la machine pour que cela fonctionne !"
echo ""

zend
read -p "Touche ENTER pour continuer !"
xfce4-session-logout


