#!/bin/bash

echo "Installe anyterm qui permet d'avoir une console WEB SSH"
ZVER="1200720.2109.1200728.0051"
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

    sudo mkdir /usr/share/anyterm
    sudo cp ./anytermd /usr/share/anyterm/
    sudo chmod +x /usr/share/anyterm/anytermd
    sudo cp ./run_ssh.sh /usr/share/anyterm/
    sudo chmod +x /usr/share/anyterm/run_ssh.sh
    sudo ln -s /usr/share/anyterm/anytermd /usr/bin/anytermd
    #sudo adduser --system --group --no-create-home anyterm

    sudo cp ./anyterm /etc/init.d/
    sudo update-rc.d anyterm defaults
    sudo service anyterm restart
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

echo "ATTENTION: pour être pleinement opérationel, si ce n'est pas déjà fait, il faut installer aussi le package-appache2_proxy.sh"
echo ""



