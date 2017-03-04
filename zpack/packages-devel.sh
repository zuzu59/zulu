#!/bin/bash

echo "Installe les packs devel"
echo "zf 1200608.1632"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

sudo apt-get update > /dev/null

sudo apt-get -y install idle python-setuptools subversion

sudo easy_install web.py

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

