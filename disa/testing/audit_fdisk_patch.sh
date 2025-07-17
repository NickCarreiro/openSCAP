#!/bin/bash
set -e

RULES_FILE="/etc/audit/rules.d/stig.rules"
RULE="-w /usr/sbin/fdisk -p x -k fdisk"

echo "Backing up existing audit rules file to ${RULES_FILE}.bak"
sudo cp "$RULES_FILE" "${RULES_FILE}.bak" 2>/dev/null || true

echo "Checking if fdisk audit rule already exists..."
if sudo grep -qF "$RULE" "$RULES_FILE" 2>/dev/null; then
    echo "Audit rule for fdisk already present. No changes made."
else
    echo "Adding audit rule for fdisk to $RULES_FILE"
    echo "$RULE" | sudo tee -a "$RULES_FILE" > /dev/null
fi

echo "Reloading audit rules..."
sudo augenrules --load

echo "Audit rule for fdisk applied and audit rules reloaded."
