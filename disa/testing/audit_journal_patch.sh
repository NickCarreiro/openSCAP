#!/bin/bash
set -e

RULES_FILE="/etc/audit/rules.d/stig.rules"
RULE="-w /var/log/journal -p wa -k systemd_journal"

echo "Backing up existing audit rules file to ${RULES_FILE}.bak"
sudo cp "$RULES_FILE" "${RULES_FILE}.bak" 2>/dev/null || true

echo "Checking if audit rule for /var/log/journal already exists..."
if sudo grep -qF "$RULE" "$RULES_FILE" 2>/dev/null; then
    echo "Audit rule for /var/log/journal already present. No changes made."
else
    echo "Adding audit rule for /var/log/journal to $RULES_FILE"
    echo "$RULE" | sudo tee -a "$RULES_FILE" > /dev/null
fi

echo "Reloading audit rules..."
sudo augenrules --load

echo "Audit rule for /var/log/journal applied and audit rules reloaded."
