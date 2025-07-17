#!/bin/bash
set -euo pipefail

# Remove existing Ciphers setting
sudo sed -i '/^Ciphers /d' /etc/ssh/sshd_config

# Add FIPS-approved Ciphers
echo "Ciphers aes256-ctr,aes256-gcm@openssh.com,aes192-ctr,aes128-ctr,aes128-gcm@openssh.com" | sudo tee -a /etc/ssh/sshd_config

# Restart SSH daemon to apply changes
sudo systemctl restart sshd.service

echo "SSH ciphers set to FIPS-approved list and sshd restarted successfully."
