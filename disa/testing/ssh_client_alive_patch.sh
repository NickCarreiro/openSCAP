#!/bin/bash
set -euo pipefail

# Remove existing ClientAliveCountMax setting if exists
sudo sed -i '/^ClientAliveCountMax /d' /etc/ssh/sshd_config

# Add ClientAliveCountMax 1 setting
echo "ClientAliveCountMax 1" | sudo tee -a /etc/ssh/sshd_config

# Restart SSH daemon to apply changes
sudo systemctl restart sshd.service

echo "SSH ClientAliveCountMax set to 1 and sshd restarted successfully."
