scripts= [
"./packer_templates/scripts/ubuntu/update_ubuntu.sh",
"./packer_templates/scripts/_common/sshd.sh",
"./packer_templates/scripts/ubuntu/networking_ubuntu.sh",
"./packer_templates/scripts/ubuntu/sudoers_ubuntu.sh",
"./packer_templates/scripts/_common/vagrant.sh",
"./packer_templates/scripts/ubuntu/systemd_ubuntu.sh",
"./packer_templates/scripts/_common/virtualbox.sh",
"./packer_templates/scripts/_common/vmware_debian_ubuntu.sh",
"./packer_templates/scripts/_common/parallels.sh",
"./packer_templates/scripts/ubuntu/hyperv_ubuntu.sh",
"../settler/scripts/amd64.sh",
"./packer_templates/scripts/ubuntu/cleanup_ubuntu.sh",
"./packer_templates/scripts/_common/minimize.sh"]
memory=2048
disk_size=524288
cpus=2
