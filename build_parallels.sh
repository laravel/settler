#!/usr/bin/env bash

vagrant plugin install vagrant-reload
vagrant plugin install nokogiri

time vagrant up --provider parallels 2>&1 | tee parallels-build-output.log
vagrant halt

# Shrink the box size
prl_disk_tool compact --hdd ~/Documents/Parallels/settler_default_*.pvm/harddisk*.hdd

# Remove unnecessary log files
rm -f ~/Documents/Parallels/settler_default_*.pvm/*.log

# Package the box
vagrant package --output parallels.box
vagrant destroy -f
rm -rf .vagrant