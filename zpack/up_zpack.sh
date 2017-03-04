#!/bin/bash

echo "Upgrade zpack"
echo "zf 1200531.0900"
echo ""

#echo "URL complète du zpack"
#echo "Exemple: http://www.zulu-linux.com/distrib/stable/120504/mini/zpack.tar.gz"
#read zURL

zURL='http://www.zulu-linux.com/distrib/stable/120504/mini/zpack.tar.gz'
zFILE=${zURL##*/}
echo $zURL
echo $zFILE

cd ~
rm $zFILE*
wget $zURL
rm -rf zpack
tar zxf $zFILE
rm $zFILE

cd ~/zpack

echo ""
echo "Récupération du nouveau zpack terminée, il faut faire encore ./zpack.sh ou ./package-mini.sh"
echo ""
read -p "Touche ENTER pour lancer le zpack"

./zpack.sh

