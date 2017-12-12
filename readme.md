# Laravel Settler

The scripts that build the Laravel Homestead development environment.

## Usage

You probably don't want this repo.

* Clone [chef/bento](https://github.com/chef/bento) into same top level folder as this repo.
* Run `./bin/copy-to-bento.sh`
* Replace `scripts/cleanup.sh` with `scripts/homestead.sh` in file `ubuntu/ubuntu-16.04-amd64.json`
* Follow normal [Packer](https://www.packer.io/) practice of building `ubuntu/ubuntu-16.04-amd64.json`

## Box Builds

[Box Builder](https://github.com/Artistan/box-builder) can automate much of the tasks of ..

* building a local settler box
* customizing scripts for your settler box
* using it with laravel/homestead
