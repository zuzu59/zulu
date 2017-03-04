#!/bin/bash

echo ''
echo "$0 120726.2334"
echo "Efface toutes les données personnelles"
echo ''

sudo killall -9 chromium-browser-sandbox
sudo killall -9 chromium-browser
sudo killall -9 firefox-bin
sudo killall -9 icedove-bin


echo "clear chromium..."
rm -rf ~/.config/chromium/Default/Arch*
rm -rf ~/.config/chromium/Default/Book*
rm -rf ~/.config/chromium/Default/Cook*
rm -rf ~/.config/chromium/Default/Curr*
rm -rf ~/.config/chromium/Default/data*
rm -rf ~/.config/chromium/Default/Fav*
rm -rf ~/.config/chromium/Default/Hist*
rm -rf ~/.config/chromium/Default/Inde*
rm -rf ~/.config/chromium/Default/Last*
rm -rf ~/.config/chromium/Default/Local*
rm -rf ~/.config/chromium/Default/Log*
rm -rf ~/.config/chromium/Default/Net*
rm -rf ~/.config/chromium/Default/Quo*
rm -rf ~/.config/chromium/Default/Shor*
rm -rf ~/.config/chromium/Default/Sync*
rm -rf ~/.config/chromium/Default/Thum*
rm -rf ~/.config/chromium/Default/Top*
rm -rf ~/.config/chromium/Default/Visi*
rm -rf ~/.config/chromium/Default/Web*
rm -rf ~/.cache/chromium

echo "clear iceweasel..."
rm -rf ~/.mozilla/firefox/zulu.default/*
rm -rf ~/.mozilla/extensions/
rm -rf ~/.cache/iceweasel
cp ~/scripts/user.js ~/.mozilla/firefox/zulu.default/

echo "clear icedove"
rm -rf ~/.icedove

echo "clear keyrings..."
rm -rf ~/.gnome2/keyrings/*.keyring

echo "clear trash..."
rm -rf ~/.local/share/Trash

echo "clear zlitebackup..."
rm -rf ~/zlitebackup

echo "clear .ssh..."
rm -rf ~/.ssh

echo "clear Perso"
rm -rf ~/Perso/*

