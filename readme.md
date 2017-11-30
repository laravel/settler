# Laravel Settler

The scripts that build the Laravel Homestead development environment.

## Usage

You probably don't want this repo.

* Run `./bin/copy-to-bento.sh`
* Add `scripts/homestead.sh` to `provisioners.scripts` after `"scripts/hyperv.sh",` in file `ubuntu/ubuntu-16.04-amd64.json`
* Follow normal [Packer](https://www.packer.io/) practice of building `ubuntu/ubuntu-16.04-amd64.json`
