# Laravel Settler

The scripts that build the Laravel Homestead development environment. 

End result can be found at https://app.vagrantup.com/laravel/boxes/homestead

## Usage

You probably don't want this repo, follow instructions at https://laravel.com/docs/homestead instead.

If you know what you are doing:

* Clone [chef/bento](https://github.com/chef/bento) into same top level folder as this repo.
* Run `./bin/link-to-bento.sh`
* Run `cd ../bento` and work there for the remainder.
* Run `packer init -upgrade ./packer_templates`

# Virtualbox provider(amd64)
* Run `packer build -only=virtualbox-iso.vm -var-file="os_pkrvars/ubuntu/ubuntu-22.04-x86_64.pkrvars.hcl" -var-file="../settler/settler.hcl" ./packer_templates` to build image for virtualbox provider for amd64

# Usage with homestead
You can use a .box file directly with homestead by adding the following to your Homestead.yaml:
* Example:
`provider: libvirt
box: file:///home/csaba/Homestead/ubuntu-22.04-x86_64.libvirt.box
SpeakFriendAndEnter: ''`

In this example the provider is libvirt and the file path is /home/csaba/Homestead/ubuntu-22.04-x86_64.libvirt.box .
