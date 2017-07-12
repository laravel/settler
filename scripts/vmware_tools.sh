#!/usr/bin/env bash

# Vmware Tools
# Currently vmware-install.pl is Missing from Ubuntu 16.04
# So we must install VMWareTools manually

echo "answer AUTO_KMODS_ENABLED yes" | tee -a /etc/vmware-tools/locations || true

mkdir /tmp/iso
mount /home/vagrant/linux.iso /tmp/iso
cp -r /tmp/iso/*.tar.gz /root/.
cd /root
tar -zxvf `ls *.tar.gz | grep VMware`
rm -rf /etc/vmware-tools/
perl /root/vmware-tools-distrib/vmware-install.pl -d || true

umount /tmp/iso
rm -rf /tmp/iso
rm -rf /root/VMwareTools-*.tar.gz
rm -rf /root/vmware-tools-distrib
rm -rf /home/vagrant/linux.iso