#!/usr/bin/env bash
set -euo pipefail

mkdir ~/bp
cd ~/bp

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S --no-confirm tofi grimshot
