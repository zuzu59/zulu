#!/bin/bash
VERSION=0.1.120423.1751
echo "[*] Scripts update ($VERSION)"
read -p "    Would you like to overwrite all scripts ? [YES/no]: " confirm

if [ "$(echo $confirm | tr A-Z a-z)" == "no" ]; then
    echo '[*] Nothing to do'
    exit 1
fi

mkdir ~/scripts/
cd ~/scripts/
wget --timestamping --no-directories -l 1 -r https://svn.epfl.ch/svn/cchd-ecran/trunk/scripts/
chmod 755 *.sh

