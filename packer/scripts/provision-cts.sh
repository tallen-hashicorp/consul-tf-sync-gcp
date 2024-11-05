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
wget --no-clobber -q "https://releases.hashicorp.com/consul-terraform-sync/${CTS_VERSION}/consul-terraform-sync_${CTS_VERSION}_linux_amd64.zip"
unzip consul-terraform-sync_${CTS_VERSION}_linux_amd64.zip
chmod +x consul-terraform-sync
sudo chown root:root consul-terraform-sync
sudo mv consul-terraform-sync /usr/bin/consul-terraform-sync
consul-terraform-sync --version

# Set SELinux Context
sudo chcon -t bin_t /usr/bin/consul-terraform-sync

# Copy TF firewall modules
sudo mv /tmp/cts-firewall-module /opt/cts-firewall-module
sudo chown -R root:root /opt/cts-firewall-module
sudo chmod -R 755 /opt/cts-firewall-module

# Copy LB firewall modules
sudo mv /tmp/cts-lb-module /opt/cts-lb-module
sudo chown -R root:root /opt/cts-lb-module
sudo chmod -R 755 /opt/cts-lb-module

# Move config file
sudo mkdir -p /etc/cts
sudo mv /tmp/cts-config.hcl /etc/cts/cts-config.hcl

# Move and configure service
sudo mkdir -p /etc/cts
sudo mv /tmp/consul-terraform-sync.service /etc/systemd/system/consul-terraform-sync.service
sudo systemctl daemon-reload
sudo systemctl enable consul-terraform-sync