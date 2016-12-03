#!/usr/bin/env bash

# Update Package List

apt-get update

# Install Kernel Headers

apt-get install -y linux-headers-$(uname -r) build-essential

# Upgrade System Packages

apt-get -y upgrade
