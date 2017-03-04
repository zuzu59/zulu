#!/bin/bash

echo "Installe Tequila"
ZVER="1200720.0007.1200728.0051"
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

    echo ""
    echo "Attention, il faut avoir installé Apache avant (faire tourner le packages-apache.sh ou packages-apache_proxies.sh) !"
    echo ""

    read -p "Touche ENTER pour continuer !"

    sudo cp ./tequila.conf /etc/apache2/mods-available/
    sudo cp ./mod_tequila.so /usr/lib/apache2/modules/
    sudo su -c "echo 'LoadModule tequila_module /usr/lib/apache2/modules/mod_tequila.so' > /etc/apache2/mods-available/tequila.load"
    sudo a2enmod tequila
    mkdir -p /home/zulu/log/ramfs/apache2/Tequila/Sessions
    chmod a+w /home/zulu/log/ramfs/apache2/Tequila/Sessions

    sudo service apache2 restart
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""



