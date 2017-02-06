#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Update Package List
apt-get update

# Install Kernel Headers

apt-get install -y linux-headers-$(uname -r) build-essential

# Upgrade System Packages

apt-get -y upgrade
