#!/bin/bash

echo "Installe les packs office"
echo "zf 1200618.1542"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

echo "apt-get update..."
sudo apt-get update > /dev/null

sudo apt-get -y install uno-libs3/squeeze-backports ure/squeeze-backports
sudo apt-get -y install libreoffice libreoffice-help-fr
sudo apt-get -y install gimp gimp-help-fr acroread-l10n-en

sudo apt-get -y autoremove

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

