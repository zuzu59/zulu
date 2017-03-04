#!/bin/bash

echo "Configure le CPU en mode performance"
echo "zf 1200530.1523"

sudo cpufreq-set -c 0 -g performance
sudo cpufreq-set -c 1 -g performance

