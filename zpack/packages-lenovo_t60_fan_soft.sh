#!/bin/bash

echo "Configure la régulation du ventilateur par soft"
echo "zf 1200618.1622"

GREEN='\033[1;32m'
NOCOL='\033[0m'

echo -e ${GREEN}$0 "start..."${NOCOL}

sudo chmod +s /usr/sbin/hddtemp
sudo cp ./fancontrol /etc/
sudo cp ./thinkpad_acpi.conf /etc/modprobe.d/
sudo rmmod thinkpad_acpi
sudo modprobe thinkpad_acpi
sudo service fancontrol restart

echo "On peut tester le ventilateur avec:"
echo "http://www.fossiltoys.com/cpuload.html"
echo "Plus d'info sur:"
echo "http://www.thinkwiki.org/wiki/How_to_control_fan_speed"
echo "Pour contrôler la température et la vitesse du ventilo, on peut aussi utiliser la commande: sensors"

echo ""
echo -e ${GREEN}$0 "end..."${NOCOL}
echo ""

