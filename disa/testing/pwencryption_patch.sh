#!/bin/bash
set -euo pipefail

# Remove existing pam_unix.so lines
sudo sed -i '/pam_unix.so/d' /etc/pam.d/common-password

# Insert the required pam_unix.so configuration at the top
sudo sed -i '1ipassword [success=1 default=ignore] pam_unix.so obscure sha512 shadow remember=5 rounds=100000' /etc/pam.d/common-password

echo "Configured encrypted password storage with pam_unix.so in /etc/pam.d/common-password."
