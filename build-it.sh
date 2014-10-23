time vagrant up 2>&1 | tee build-output.log
vagrant package --base `ls ~/VirtualBox\ VMs | grep settler`
ls -lh package.box
vagrant destroy
