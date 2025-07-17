#!/bin/bash
set -e

RULES_FILE="/etc/audit/rules.d/stig.rules"
RULE="-a always,exit -F path=/bin/su -F perm=x -F auid>=1000 -F auid!=unset -k privileged-priv_change"

echo "Backing up existing audit rules file to ${RULES_FILE}.bak"
sudo cp "$RULES_FILE" "${RULES_FILE}.bak" 2>/dev/null || true

echo "Checking if su audit rule already exists..."
if sudo grep -qF "$RULE" "$RULES_FILE" 2>/dev/null; then
    echo "Audit rule for su already present. No changes made."
else
    echo "Adding audit rule for su to $RULES_FILE"
    echo "$RULE" | sudo tee -a "$RULES_FILE" > /dev/null
fi

echo "Reloading audit rules..."
sudo augenrules --load

echo "Audit rule for su applied and audit rules reloaded."
