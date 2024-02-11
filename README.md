# dotfiles

These are my dotfiles and Arch Linux instructions.

```
git clone https://github.com/Krowemoh/dotfiles.git 
```

## Arch

I use pacmanfile to get a declarative packaging system on Arch. This requires paru and so I need git and rust installed as part of the base system. I also have vim, openssh and networkmanager as I think those are too useful to skip.

Install the base system:

```
base
linux
linux-firmware
efibootmgr
grub
vim
openssh
networkmanager
base-devel
linux-headers
git
rust
sudo
```

Create a user:

```
useradd -m -G wheel -s /bin/bash username
```

Install paru:

```
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

Install pacmanfile:

```
paru pacmanfile
```

For use with stow:

```
cd ~/dotfiles
stow fish
stow sway
stow foot
stow vim
```
