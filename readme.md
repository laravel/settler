# Laravel Settler

The scripts that build the Laravel Homestead development environment. 

End result can be found at https://app.vagrantup.com/laravel/boxes/homestead

## Usage

You probably don't want this repo, follow instructions at https://laravel.com/docs/homestead instead.

If you know what you are doing:

* Clone [chef/bento](https://github.com/chef/bento) into same top level folder as this repo.
* Run `./bin/link-to-bento.sh`
* Run `cd ../bento` and work there for the remainder.
* Follow normal [Packer](https://www.packer.io/) practice of building `ubuntu/ubuntu-18.04-amd64.json`

## Versioning

Ubuntu 20.04 can be found in the branch `20.04` 
Ubuntu 18.04 can be found in the branch `master`

| Ubuntu LTS | Settler Version | Homestead Version | Branch
| -----------| -----------     | -----------       | -----------
| 18.04      | 10.x            | 11.x              | `master`
| 20.04      | 9.x             | 10.x              | `20.04`
