#!/bin/bash
# Remediation script for disabling and masking ctrl-alt-del.target

set -euo pipefail

echo "Disabling ctrl-alt-del.target..."
sudo systemctl disable ctrl-alt-del.target

echo "Masking ctrl-alt-del.target..."
sudo systemctl mask ctrl-alt-del.target

echo "Reloading systemd daemon to apply changes..."
sudo systemctl daemon-reload

echo "Remediation complete."
