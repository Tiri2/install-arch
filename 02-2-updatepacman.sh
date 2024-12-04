#!/bin/bash
pacman -Sy --noconfirm archlinux-keyring reflector
reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

