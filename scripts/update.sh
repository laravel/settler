#!/usr/bin/env bash

# Update Package List

apt-get update

# Update Grub Bootloader

echo "set grub-pc/install_devices /dev/sda" | debconf-communicate
apt-get -y remove grub-pc
apt-get -y install grub-pc
grub-install /dev/sda
update-grub

# Upgrade System Packages

apt-get -y upgrade
