#!/bin/bash

echo "Configure le CPU en mode powersave"
echo "zf 1200530.1523"

sudo cpufreq-set -c 0 -g powersave
sudo cpufreq-set -c 1 -g powersave

