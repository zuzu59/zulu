#!/bin/bash

# Démarre une connexion SSH à la demande pour Anyterm
echo "WEB SSH, zf1200723.1658"

zclean(){
     echo ${1//[^a-zA-Z0-9.-]/}
}  

read -e -p 'SSH Remote Host:' REMOTE_HOST
read -e -p 'SSH Remote User:' REMOTE_USER

date >>/home/zulu/log/ramfs/apache2/anyterm.log
echo $REMOTE_HOST >>/home/zulu/log/ramfs/apache2/anyterm.log
echo $REMOTE_USER >>/home/zulu/log/ramfs/apache2/anyterm.log

REMOTE_HOST=$(zclean "$REMOTE_HOST" | cut -c 1-128)
REMOTE_USER=$(zclean "$REMOTE_USER" | cut -c 1-32)

echo $REMOTE_HOST >>/home/zulu/log/ramfs/apache2/anyterm.log
echo $REMOTE_USER >>/home/zulu/log/ramfs/apache2/anyterm.log

ssh -o PubkeyAuthentication=no $REMOTE_USER@$REMOTE_HOST

