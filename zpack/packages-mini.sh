#!/bin/bash

echo "Mise à jour de la distrib mini ou de base actuelle"
ZVER="1200724.1723.1200728.0014"
echo -e "zf "$ZVER

RED='\033[1;31m'
GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

echo "apt-get update..."
sudo apt-get update > /dev/null
sudo apt-get -y install patch

# configure le journalfs sur la partition actuelle
sudo tune2fs -O has_journal $(mount | grep ' / type ext4' | awk '{print $1}')

# patch le fstab pour autoriser l'éxécution dans /tmp
sudo patch -f /etc/fstab < ./patch.fstab
sudo mount -o remount /tmp

# patch le boot pour avoir un menu de choix du kernel
#./boot_menu_on.sh

# accélère très fortement le shutdown
# pour le remettre comme avant: sudo insserv sendsigs
sudo update-rc.d -f sendsigs remove

# patch le rcS pour les problème de l'horloge du BIOS
sudo patch -f /etc/default/rcS < ./patch.rcS

# patch le default keyring en français
sudo cp ./libgnome-keyring.mo /usr/share/locale/fr/LC_MESSAGES/libgnome-keyring.mo

# configure le cache des browsers
mkdir ~/.cache/chromium
mkdir ~/.cache/iceweasel

# ajoute le pluggin pdf reader de Chrome à Chromium
sudo cp ./libpdf.so /usr/lib/chromium-browser/

# ajoute les paquets manquant
sudo apt-get -y install ntp less

# met la version backport de IceWeasel
sudo apt-get -t squeeze-backports -y install iceweasel iceweasel-l10n-fr libevent-1.4-2 libmozjs10d libnss3 libvpx1 xulrunner-10.0 libcairo2 libnss3-1d libpixman-1-0 libsqlite3-0

# patch le keyring
rm -rf ~/.gnome2/keyring # à cause de l'erreur sans le 's'
mkdir ~/.gnome2/keyrings
cp ./keyring.default ~/.gnome2/keyrings/default

# met à jour les scripts
cp ./clear_privacy.sh ~/scripts
cp ./user.js ~/scripts
cp ./duplicate.sh ~/scripts
cp ./zturbo.sh ~/scripts
cp ./usbbench.sh ~/scripts
cp ./install_sun_jre.sh ~/scripts
cp ./zcpu*.sh ~/scripts
cp ./wflog.sh ~/scripts
cp ./zset_bios_clock.sh ~/scripts
cp ./zchange_hostname.sh ~/scripts
#rm ./zset_bios_clock.sh.sh

# configure le ramfs
sudo service ramfs stop > /dev/null
mkdir -p ~/log/ramfs
sudo cp ./ramfs /etc/init.d/
sudo chown root.root /etc/init.d/ramfs
sudo service ramfs start > /dev/null

ZSTR1=${ZVER%.*.*}
if [ "$(ls ~/.zpack/${0##*/}.$ZSTR1* 2> /dev/null)" != "" ]; then
    echo $0" déjà installé !"
else
    echo $0" pas encore installé !"
    mkdir ~/.zpack 2> /dev/null
    touch ~/.zpack/${0##*/}.$ZSTR1.`date +%Y%m%d.%H%M`

    # configure les shortcuts clavier
    cp ./xfce4-keyboard-shortcuts.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
    sudo pkill -HUP xfconfd

    # patch le thème de slim
    sudo patch -f /usr/share/slim/themes/debian-spacefun/slim.theme < ./patch.slim.theme
    sudo cp ./zulu_logo_640_480_1.png /usr/share/slim/themes/debian-spacefun/background.png

    # patch l'history de basch
    patch -f ~/.bashrc < ./patch.bashrc.history
    
    # patch le keeychain de basch
    patch -f ~/.bashrc < ./patch.bashrc.keychain

    # configure l'éditeur VIM pour l'utilisateur zulu ET root
    cp ./.vimrc ~/
    sudo cp ./.vimrc /root/
fi

# met à jour la version de Zulu
cp ./zulu_version ~/

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

#read -p "Pause..."


