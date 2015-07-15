#!/usr/bin/env bash

# install required vagrant plugin to handle reloads during provisioning
vagrant plugin list|grep vagrant-reloada 2>&1 > /dev/null
if [ 0 -eq $? ];then
	vagrant plugin install vagrant-reload
fi

vb() {
	# start with no machines
	vagrant destroy -f
	rm -rf .vagrant
	echo "making virtualbox.box"
	time vagrant up virtualbox --provider virtualbox 2>&1 | tee virtualbox-build-output.log
	vagrant halt
	vagrant package --base `ls ~/VirtualBox\ VMs | grep settler` --output virtualbox.box
	ls -lh virtualbox.box
}

vm() {
	# start with no machines
	vagrant destroy -f
	rm -rf .vagrant
	echo "making vmware_fusion.box"
	time vagrant up vmware_fusion --provider vmware_fusion 2>&1 | tee vmware-build-output.log
	vagrant halt
	# defrag disk (assumes running on osx)
	/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -d .vagrant/machines/vmware_fusion/vmware_fusion/*-*-*-*-*/disk.vmdk
	# shrink disk (assumes running on osx)
	/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -k .vagrant/machines/vmware_fusion/vmware_fusion/*-*-*-*-*/disk.vmdk
	# 'vagrant package' does not work with vmware boxes (http://docs.vagrantup.com/v2/vmware/boxes.html)
	cd .vagrant/machines/vmware_fusion/vmware_fusion/*-*-*-*-*/
	rm -f vmware*.log
	tar cvzf ../../../../../vmware_fusion.box *
	cd ../../../../../
	ls -lh vmware_fusion.box
}

pd() {
	# start with no machines
	vagrant destroy -f
	rm -rf .vagrant
	rm -rf .parallels_temp
	echo "making parallels.box"
	time vagrant up parallels_desktop --provider parallels 2>&1 | tee parallels-build-output.log
	vagrant halt
	prl_disk_tool compact --hdd ~/Documents/Parallels/homestead.pvm/harddisk1.hdd
	mkdir .parallels_temp
	cat > .parallels_temp/Vagrantfile << EOF
	Vagrant.configure('2') do |config|
	  # Configure The Box
      config.vm.hostname = 'homestead'

      # Configure Network
      config.vm.network 'public_network', bridge: 'en0'
      config.vm.network 'private_network', type: 'dhcp'

      # Disabled Default Synced Folder
      config.vm.synced_folder './', '/vagrant', disabled: true
    end
EOF
    cat > .parallels_temp/metadata.json << EOF
    {"provider":"parallels"}
EOF
	rm -f ~/Documents/Parallels/homestead.pvm/*.log
	tar cvzf parallels.box -C .parallels_temp/ Vagrantfile metadata.json -C ~/Documents/Parallels/ homestead.pvm
	rm -rf .parallels_temp
	ls -lh parallels.box
}

case $1 in
	vb | virtualbox)
		vb
		;;
	vm | vmware)
		vm
		;;
	pd | parallels)
		pd
		;;
	all)
		vb
		vm
		pd
		;;
	*)
		echo "How to use"
		echo "$0 vb or virtualbox - to build virtualbox.box"
		echo "$0 vm or vmware - to build vmware_fusion.box"
		echo "$0 pd or parallels - to build parallels.box"
		echo "$0 all - to build all box"
esac
