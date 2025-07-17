#!/bin/bash
set -euo pipefail

# Set enforcing=1 in pwquality.conf (add or update)
sudo sed -i '/^enforcing\s*=/d' /etc/security/pwquality.conf
echo "enforcing = 1" | sudo tee -a /etc/security/pwquality.conf

# Remove existing pam_pwquality.so lines in PAM common-password
sudo sed -i '/pam_pwquality.so/d' /etc/pam.d/common-password

# Insert the correct pam_pwquality line before the first 'password requisite' line
sudo sed -i '/^password\s\+requisite/i password requisite pam_pwquality.so retry=3' /etc/pam.d/common-password

echo "Password complexity enforcement configured successfully."
