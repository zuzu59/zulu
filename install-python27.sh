#!/bin/bash

echo '[*]'
echo '[*] Install Python 2.7 for Debian Squeeze (stable)'
echo '[*]'

if [ "$USER" != "root" ]; then
    echo '[*] You must be root'
    exit
fi

read -p 'Do you want to install python.27 ? THIS MAY BREAK YOUR SYSTEM: [yes/NO]' confirm
if [ "$(echo $confirm | tr A-Z a-z)" != "yes" ]; then
    echo '[*] Cancelled'
    exit
fi

echo 'deb http://ftp.ch.debian.org/debian/ wheezy main contrib non-free' >> /etc/apt/sources.list
echo 'Package: *
Pin: release n=wheezy
Pin-Priority: -1
' > /etc/apt/preferences.d/python27.pref

apt-get update
apt-get install -t wheezy python2.7

