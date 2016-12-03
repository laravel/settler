#!/usr/bin/env bash

# install required vagrant plugin to handle reloads during provisioning
vagrant plugin install vagrant-reload

# start with no machines
vagrant destroy -f
rm -rf .vagrant

 time vagrant up --provider vmware_fusion 2>&1 | tee vmware-build-output.log
 vagrant halt

 # defrag disk (assumes running on osx)
 /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -d .vagrant/machines/default/vmware_fusion/*-*-*-*-*/disk.vmdk
 # shrink disk (assumes running on osx)
 /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -k .vagrant/machines/default/vmware_fusion/*-*-*-*-*/disk.vmdk
 # 'vagrant package' does not work with vmware boxes (http://docs.vagrantup.com/v2/vmware/boxes.html)
 cd .vagrant/machines/default/vmware_fusion/*-*-*-*-*/
 rm -f vmware*.log
 tar cvzf ../../../../../vmware_fusion.box *
 cd ../../../../../

 ls -lh vmware_fusion.box
 vagrant destroy -f
 rm -rf .vagrant
