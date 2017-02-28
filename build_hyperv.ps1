$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

# install required vagrant plugin to handle reloads during provisioning
vagrant plugin install vagrant-reload

# start with no machines
vagrant destroy -f
Remove-Item -Path .vagrant -Recurse

vagrant up --provider hyperv
vagrant halt

vagrant package --output hyperv.box