#!/bin/bash
set -euo pipefail

echo "Setting permissions of all files under /var/log to 640 or more restrictive..."

# Find all regular files under /var/log
find /var/log -type f -exec chmod 640 {} +

echo "Permissions updated successfully."
