#!/usr/bin/env bash

# Update Package List

apt-get update

# Upgrade System Packages

apt-get -y upgrade

apt-get install -y linux-headers-$(uname -r) build-essential
