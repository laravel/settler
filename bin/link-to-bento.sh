#!/usr/bin/env bash

/bin/ln -f scripts/provision.sh ../bento/ubuntu/scripts/homestead.sh
/bin/ln -f http/preseed.cfg ../bento/ubuntu/http
/bin/ln -f http/preseed-hyperv.cfg ../bento/ubuntu/http

sed -i -e 's/scripts\/cleanup.sh/scripts\/homestead.sh/' ../bento/ubuntu/ubuntu-18.04-amd64.json
sed -i -e 's/"cpus": "1"/"cpus": "4"/' ../bento/ubuntu/ubuntu-18.04-amd64.json
sed -i -e 's/"memory": "1024"/"memory": "4096"/' ../bento/ubuntu/ubuntu-18.04-amd64.json
