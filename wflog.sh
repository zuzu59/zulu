#!/bin/bash

echo "Affiche les derniers fichiers modifié"
echo "zf 1200611.1359"

DST=$1 ;if [ "$1" == "" ];then DST=/ ;fi

sudo find -P $DST -mount -mtime -1 -type f -exec ls -al '{}' \; | sort +5 -12
