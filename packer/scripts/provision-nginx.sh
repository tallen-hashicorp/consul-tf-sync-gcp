#!/bin/bash

# Update system packages
sudo dnf update -y

# Install required packages
sudo dnf install -y nginx

# Start and enable Nginx to start at boot
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify Nginx is running
sudo systemctl status nginx

# Print Nginx version
nginx -v