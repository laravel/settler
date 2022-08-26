#!/usr/bin/env bash

/bin/ln -f scripts/amd64.sh ../bento/packer_templates/ubuntu/scripts/homestead.sh
/bin/ln -f scripts/arm.sh ../bento/packer_templates/ubuntu/scripts/homestead-arm.sh
/bin/ln -f http/preseed.cfg ../bento/packer_templates/ubuntu/http
/bin/ln -f http/preseed-hyperv.cfg ../bento/packer_templates/ubuntu/http

sed -i '' 's/{{template_dir}}\/scripts\/cleanup.sh/scripts\/homestead.sh/' ../bento/packer_templates/ubuntu/ubuntu-22.04-amd64.json
sed -i '' 's/"cpus": "1"/"cpus": "2"/' ../bento/packer_templates/ubuntu/ubuntu-22.04-amd64.json
sed -i '' 's/"boot_wait": "5s"/"boot_wait": "3s"/' ../bento/packer_templates/ubuntu/ubuntu-22.04-amd64.json
sed -i '' 's/"memory": "1024"/"memory": "2048"/' ../bento/packer_templates/ubuntu/ubuntu-22.04-amd64.json
sed -i '' 's/"disk_size": "65536"/"disk_size": "524288"/' ../bento/packer_templates/ubuntu/ubuntu-22.04-amd64.json
sed -i '' '/\/_common\/motd.sh/d' ../bento/packer_templates/ubuntu/ubuntu-22.04-amd64.json

# Run for ARM
sed -i '' 's/cleanup.sh/homestead-arm.sh/' ../bento/packer_templates/ubuntu/ubuntu-22.04-arm64.json
sed -i '' 's/"boot_wait": "5s"/"boot_wait": "3s"/' ../bento/packer_templates/ubuntu/ubuntu-22.04-arm64.json
sed -i '' 's/"memory": "1024"/"memory": "2048"/' ../bento/packer_templates/ubuntu/ubuntu-22.04-arm64.json
sed -i '' 's/"disk_size": "65536"/"disk_size": "524288"/' ../bento/packer_templates/ubuntu/ubuntu-22.04-arm64.json
sed -i '' '/\/_common\/motd.sh/d' ../bento/packer_templates/ubuntu/ubuntu-22.04-arm64.json
