#!/bin/bash

echo "Installe le logiciel de cryptage TrueCrypt et le coffre fort à passwords KeePassX"
echo "zf 1200718.2208"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

zURL='http://www.truecrypt.org/download/truecrypt-7.1a-linux-x86.tar.gz'
zFILE=${zURL##*/}
echo $zURL
echo $zFILE

cd ~/Desktop
rm -rf truecrypt
mkdir truecrypt
cd truecrypt
wget $zURL
tar zxf $zFILE
rm $zFILE

./truecrypt-7.1a-setup-x86

cd ..
rm -rf truecrypt

sudo apt-get update > /dev/null
sudo apt-get -y install keepassx

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


