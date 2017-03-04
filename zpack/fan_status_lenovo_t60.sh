#!/bin/bash

echo "Affiche le status de la régulation du ventilateur"
echo "zf 1200612.1446"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

more /proc/acpi/ibm/fan

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

