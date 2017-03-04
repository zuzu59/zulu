#!/bin/bash

echo "Compile et installe les drivers nvidia pour la zbox"
echo "zf 1200608.1851"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

zURL='http://us.download.nvidia.com/XFree86/Linux-x86/295.53/NVIDIA-Linux-x86-295.53.run'
zFILE=${zURL##*/}
echo $zURL
echo $zFILE

cd ~/Desktop
cd nvidia
sudo service slim stop
sudo ./$zFILE





echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""


