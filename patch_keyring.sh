#!/bin/bash

echo ''
echo "$0 120423.1734"
echo "Patche le bug du keyring en français !"
echo ''

mv ~/.gnome2/keyrings/par_défaut.keyring ~/.gnome2/keyrings/default.keyring
rm ~/.gnome2/keyrings/default

