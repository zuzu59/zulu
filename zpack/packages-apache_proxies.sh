#!/bin/bash

echo "Installe Apache"
ZVER="1200723.2337.1200728.0051"
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
    sudo apt-get -y install apache2

    sudo mkdir /etc/apache2/ssl
    sudo a2enmod ssl proxy proxy_http
    sudo make-ssl-cert /usr/share/ssl-cert/ssleay.cnf /etc/apache2/ssl/apache.pem

    sudo cp ./proxies-ssl /etc/apache2/sites-available/
    sudo a2ensite proxies-ssl 

    sudo patch -f /etc/apache2/envvars < ./patch.envars
    sudo patch -f /etc/apache2/conf.d/other-vhosts-access-log  < ./patch.other-vhosts-access-log
    sudo rm -rf /etc/apache2/conf.d/other-vhosts-access-log.orig  /etc/apache2/conf.d/other-vhosts-access-log.rej
    mkdir -p /home/zulu/log/ramfs/apache2

    sudo service apache2 restart
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""



