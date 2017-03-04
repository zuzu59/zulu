#!/bin/bash

echo "Installe les packs media"
ZVER="1200618.1543.1200728.0051"
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
    sudo apt-get -y install vlc libdvdcss2 brasero

    # Patch le média automount pour les CD audio et DVD vidéo
    if [ -f "~/.config/Thunar/volmanrc" ]; then
        patch -f ~/.config/Thunar/volmanrc < ./patch.media.automount
    else
      cp ./volmanrc ~/.config/Thunar/volmanrc
    fi
fi

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

