#!/bin/bash

echo "Configure le CPU en mode ondemand"
echo "zf 1200530.1523"

sudo cpufreq-set -c 0 -g ondemand
sudo cpufreq-set -c 1 -g ondemand

