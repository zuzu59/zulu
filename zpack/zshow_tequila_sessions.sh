#!/bin/bash

echo "Affiche les logs des sessions de Tequila"
echo "zf 1200724.1706"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

cd /home/zulu/log/ramfs/apache2/Tequila/Sessions/
for i in $(ls -tr); do echo; ls -l $i | cut -d' ' -f6-8; sudo cat $i; done

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


