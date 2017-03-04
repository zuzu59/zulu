#!/bin/bash

echo '[*]'
echo '[*] Download splitted files'
echo '[*] jba/zf120511.1756'

if [ $# -lt 3 ]; then
    echo ''
    echo "Usage: $0 <URL> <File> <Number>"
    echo -e "\tURL: Url where are the files"
    echo -e "\tFile: Filename of the parts without the number"
    echo -e "\tNumber: Last part number. Example: 6"
    echo "Example: $0 http://www.zulu-linux.com/distrib/stable/120419/120422.1824/ tutu 06"
    exit
fi

url="$1"
file="$2"
nb=$3

#echo '' > $file

for i in `seq 0 1 $nb`; do
    wget -t 10 -q -c $url/${file}0$i &
done

#cat $file$i >> $file
#md5sum $file
curl --silent $URL/md5sum.txt

