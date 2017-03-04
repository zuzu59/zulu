#!/bin/bash

echo "Fait un tar.gz du dossier gedit"
echo "zf 1204270923"
echo ""
echo ""
echo "Après pour extraire, il faut faire: "
echo "sudo killall gconfd-2 ; sleep 3 ; tar xzfP gedit-2.tar.gz"
echo ""
echo ""

sudo killall gconfd-2 ;sleep 3
tar cfzP gedit-2.tar.gz ~/.gconf/apps/gedit-2


