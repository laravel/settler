vagrant up
vagrant package --base `ls ~/VirtualBox\ VMs | grep settler`
ls -lh package.box
vagrant destroy
