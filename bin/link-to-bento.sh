#!/usr/bin/env bash

/bin/ln -f scripts/amd64.sh ../bento/packer_templates/scripts/ubuntu/homestead_amd64.sh
/bin/ln -f scripts/arm.sh ../bento/packer_templates/scripts/ubuntu/homestead_arm.sh

echo " " > ../bento/packer_templates/scripts/_common/motd.sh
sed -i 's/${var.os_name}\/cleanup_${var.os_name}.sh/ubuntu\/homestead_amd64.sh/' ../bento/packer_templates/pkr-builder.pkr.hcl
# Set disk_size
sed -i 's/65536/524288/' ../bento/packer_templates/pkr-variables.pkr.hcl



#sed -i 's/scripts\/cleanup.sh/scripts\/homestead.sh/' ../packer_templates/pkr-builder.pkr.hcl
#sed -i 's/"cpus": "1"/"cpus": "2"/' ../bento/packer_templates/ubuntu/ubuntu-20.04-amd64.json
#sed -i 's/"boot_wait": "5s"/"boot_wait": "3s"/' ../bento/packer_templates/ubuntu/ubuntu-20.04-amd64.json
#sed -i 's/"memory": "1024"/"memory": "2048"/' ../bento/packer_templates/ubuntu/ubuntu-20.04-amd64.json
#sed -i 's/"disk_size": "65536"/"disk_size": "524288"/' ../bento/packer_templates/ubuntu/ubuntu-20.04-amd64.json
#sed -i '/\/_common\/motd.sh/d' ../bento/packer_templates/ubuntu/ubuntu-20.04-amd64.json

## Run for ARM
#sed -i 's/scripts\/cleanup.sh/scripts\/homestead-arm.sh/' ../bento/packer_templates/ubuntu/ubuntu-20.04-arm64.json
#sed -i 's/"boot_wait": "5s"/"boot_wait": "3s"/' ../bento/packer_templates/ubuntu/ubuntu-20.04-arm64.json
#sed -i 's/"memory": "1024"/"memory": "2048"/' ../bento/packer_templates/ubuntu/ubuntu-20.04-arm64.json
#sed -i 's/"disk_size": "65536"/"disk_size": "524288"/' ../bento/packer_templates/ubuntu/ubuntu-20.04-arm64.json
#sed -i '/\/_common\/motd.sh/d' ../bento/packer_templates/ubuntu/ubuntu-20.04-arm64.json
