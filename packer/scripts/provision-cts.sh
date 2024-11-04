#!/bin/bash

export CTS_VERSION="0.7.1+ent"

# Update system packages
sudo dnf update -y

# Install required packages
sudo dnf install -y unzip curl wget bind-utils

# Add HashiCorp's official RPM repository
curl -fsSL https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo | sudo tee /etc/yum.repos.d/hashicorp.repo

# Install Terraform CLI
sudo dnf install -y terraform

# Upgrade Consul to ent
wget -q "https://releases.hashicorp.com/consul-terraform-sync/${CTS_VERSION}/consul-terraform-sync_${CTS_VERSION}_linux_amd64.zip"
unzip consul-terraform-sync_${CTS_VERSION}_linux_amd64.zip
chmod +x consul-terraform-sync
sudo chown root:root consul-terraform-sync
sudo mv consul-terraform-sync /usr/bin/consul-terraform-sync
consul-terraform-sync --version

# Set SELinux Context
sudo chcon -t bin_t /usr/bin/consul-terraform-sync
