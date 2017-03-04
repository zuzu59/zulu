#!/bin/bash

echo "Compile Tequila"
ZVER="1200719.2302.1200727.2206"
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

    zURL='http://tequila.epfl.ch/download/2.0/tequila-apache-C-2.0.12.tgz'
    zFILE=${zURL##*/}
    echo $zURL
    echo $zFILE

    cd ~/Desktop
    rm -rf tequila
    mkdir tequila
    cd tequila
    rm $zFILE*
    wget $zURL

    tar zxf $zFILE
    rm $zFILE
    cd tequila-2.0.12/modules/C

    sudo apt-get update > /dev/null
    sudo apt-get -t squeeze-backports -y install libsqlite3-dev apache2-threaded-dev build-essential

    sudo ln -s /usr/bin/apxs2 /usr/bin/apxs
    make compile

    sudo apt-get -y remove libsqlite3-dev apache2-threaded-dev build-essential
    sudo apt-get -y autoremove
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""



