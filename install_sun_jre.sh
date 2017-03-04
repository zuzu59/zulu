#!/bin/bash

echo "Installe la dernière version de SUN JAVA JRE"
ZVER="1200608.1635.1200728.0051"
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

    echo "deb http://www.duinsoft.nl/pkg debs all" | sudo tee -a /etc/apt/sources.list 1>/dev/null
    sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 5CB26B26
    echo "apt-get update..."
    sudo apt-get update > /dev/null
    sudo apt-get -y install update-sun-jre
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

