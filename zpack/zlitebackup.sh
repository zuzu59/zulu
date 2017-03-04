#!/bin/bash

#ssh-keygen
#ssh-copy-id zulu@localhost

echo "Script de backup économique automatique de Full/Différentiel"
echo "Use: ./zuzu_backup"
echo "zf 1200711.1704"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start...$(date)"${NOCOL}

###########################
# Paramètres à modifier ! #
###########################
# Simplement commenter la ligne SIMULATION pour ne plus simuler le backup !

#SIMULATION='-n'

SOURCE='/home/zulu'
TARGET_MACHINE='zulu@localhost'
TARGET='/home/zulu/zlitebackup'

EXCLUDE='--exclude=**/ImapMail/ --exclude=**/zlitebackup/ --exclude=**/*tmp* --exclude=**/.cache* --exclude=**/cache* --exclude=**/Cache* --exclude=**/lost+found* --exclude=**/*rash*  --exclude=**/mnt/* --exclude=**/.VirtualBox* --exclude=**/VirtualBox* --exclude=**/.evolution* --exclude=**/.mozilla* --exclude=**/.opera* --exclude=**/.macromedia* --exclude=**/.navicat* --exclude=**/google-earth* --exclude=**/.local/share/gvfs* --exclude=**/.thumbnails* --exclude=**/Picasa2/db3* --exclude=**/.gvfs* --exclude=**/.wine* --exclude=**/chromium/*'
###########################

YEAR=`date +%Y` 
MONTH=`date +%m`
DAY=`date +%d`
TIME=`date +%H-%M-%S` 
DIFF='diff/'${YEAR}/${MONTH}/${DAY}/${TIME}
#COMMAND='-r -t -v --progress --stats --size-only --modify-window=1 --delete-excluded'
COMMAND='-r -t -v --progress --stats --checksum --modify-window=1 --delete-excluded'

echo '\nCréé la structure de backup...'
ssh $TARGET_MACHINE mkdir -p $TARGET/full
ssh $TARGET_MACHINE mkdir -p $TARGET/$DIFF 

echo '\nBackup via le rsync...'
rsync $SIMULATION $COMMAND \
$EXCLUDE \
--backup --backup-dir=$TARGET/$DIFF/ \
-e ssh $SOURCE $TARGET_MACHINE:$TARGET/full


#echo '\nBackup /etc via le rsync'
#rsync $SIMULATION $COMMAND \
#$EXCLUDE \
#--backup --backup-dir=$TARGET/diff/${DATE}/ \
#-e ssh '/etc' $TARGET_MACHINE:$TARGET/full

#echo '\nSet les bons privilèges sur la structure de backup'
#ssh $TARGET_MACHINE chown -R zuzu $TARGET
#ssh $TARGET_MACHINE chgrp -R users $TARGET

echo ""
echo -e ${GREEN}$0 "end...$(date)"${NOCOL}
echo ""

echo "
Si jamais pour info:
ssh-keygen
ssh-copy-id zulu@localhost
0 8-19/1 * * 1-5 /home/zulu/Desktop/zlitebackup.sh
"
echo ""


