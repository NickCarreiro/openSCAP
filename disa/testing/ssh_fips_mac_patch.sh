#!/bin/bash
set -euo pipefail

# Remove existing MACs config line
sudo sed -i '/^MACs /d' /etc/ssh/sshd_config

# Add FIPS-approved MACs
echo "MACs hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com" | sudo tee -a /etc/ssh/sshd_config

# Reload SSH daemon to apply changes without disconnecting sessions
sudo systemctl reload sshd.service

echo "SSH MACs set to FIPS-approved hashes and sshd reloaded successfully."
