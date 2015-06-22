#!/usr/bin/env bash

# Vmware Tools

echo "answer AUTO_KMODS_ENABLED yes" | sudo tee -a /etc/vmware-tools/locations || true

/usr/bin/vmware-config-tools.pl -d || true
