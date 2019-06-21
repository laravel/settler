#!/usr/bin/env bash

/bin/ln -f scripts/provision.sh ../bento/packer_templates/ubuntu/scripts/homestead.sh
/bin/ln -f http/preseed.cfg ../bento/packer_templates/ubuntu/http
/bin/ln -f http/preseed-hyperv.cfg ../bento/packer_templates/ubuntu/http

sed -i -e 's/scripts\/cleanup.sh/scripts\/homestead.sh/' ../bento/packer_templates/ubuntu/ubuntu-18.04-amd64.json
sed -i -e 's/"cpus": "1"/"cpus": "4"/' ../bento/packer_templates/ubuntu/ubuntu-18.04-amd64.json
sed -i -e 's/"memory": "1024"/"memory": "4096"/' ../bento/packer_templates/ubuntu/ubuntu-18.04-amd64.json
sed -i -e 's/"disk_size": "65536"/"disk_size": "131072"/' ../bento/packer_templates/ubuntu/ubuntu-18.04-amd64.json
