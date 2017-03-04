#!/bin/bash

echo "Met à l'heure l'horloge du BIOS"
echo "zf 1200611.1508"

echo "Heure avant:"
sudo hwclock -r

sudo hwclock -w

echo "Heure après:"
sudo hwclock -r

