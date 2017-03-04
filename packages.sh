#!/bin/bash

PKG_PATH='/home/zulu/scripts/conf/packages-'

echo '[*]'
echo '[*] Install additional packages'
echo '[*]'

if [ "$USER" != "root" ]; then
    echo '[*] You must be root'
    exit
fi


while true; do
    echo
    j=1
    for i in $(ls $PKG_PATH*); do
        echo "    $j) ${i#*-}"
        j=$(echo "$j+1" | bc)
    done
    echo 
    read -p '[+] Choose packages group name to install: ' pkg
    if [ -f "$PKG_PATH$pkg" ]; then
        apt-get -y install $(cat "$PKG_PATH$pkg" | tr '\n' ' ')
    else
        echo -e '[*] \033[0;31mInvalid package name\033[0m'
    fi
done

