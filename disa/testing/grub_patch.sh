#!/bin/bash
set -e

echo "Enter the password to secure GRUB:"
read -s GRUB_PASS

echo "Generating PBKDF2 hash..."
HASH=$(grub-mkpasswd-pbkdf2 <<< "$GRUB_PASS"$'\n'"$GRUB_PASS" | grep 'grub.pbkdf2.sha512' | awk '{print $NF}')

if [ -z "$HASH" ]; then
  echo "Failed to generate GRUB password hash"
  exit 1
fi

echo "Backing up current /etc/grub.d/40_custom to /etc/grub.d/40_custom.bak"
sudo cp /etc/grub.d/40_custom /etc/grub.d/40_custom.bak

echo "Adding GRUB superuser and password to /etc/grub.d/40_custom"
sudo sed -i "/set superusers/d" /etc/grub.d/40_custom
sudo sed -i "/password_pbkdf2/d" /etc/grub.d/40_custom

echo -e "\nset superusers=\"root\"\npassword_pbkdf2 root $HASH" | sudo tee -a /etc/grub.d/40_custom > /dev/null

echo "Updating GRUB configuration..."
sudo update-grub

echo "Done! GRUB password is set. Reboot to test."

