#!/bin/bash
pacman -Sy archlinux-keyring
pacman -Sy reflector
reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

