#!/bin/bash
set -euo pipefail

# Files to process
files=(
  "/etc/pam.d/common-auth"
  "/etc/pam.d/common-password"
)

echo "Removing 'nullok' option from PAM configuration files..."

for file in "${files[@]}"; do
  if [[ -f "$file" ]]; then
    echo "Processing $file"
    # Use sed to remove 'nullok' as a standalone word, preserving other content
    sudo sed -i 's/\bnullok\b//g; s/  / /g; s/ *$//g' "$file"
  else
    echo "Warning: $file does not exist, skipping."
  fi
done

echo "Cleanup complete. 'nullok' options removed from PAM configuration."
