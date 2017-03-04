#!/bin/bash

echo "Installe les packs hacker"
echo "zf 1200608.1632"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

sudo apt-get update > /dev/null

sudo apt-get -y install curl build-essential nmap strace less whois dnsutils ipython wireless-tools tcpdump ngrep dsniff nbtscan tcpick

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

