#!/bin/bash
set -euo pipefail

# Backup original AIDE config
sudo cp /etc/aide/aide.conf /etc/aide/aide.conf.bak.$(date +%F_%T)

# Append audit tools protection rules
sudo tee -a /etc/aide/aide.conf > /dev/null <<EOF

# Audit Tools
/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512
EOF

echo "AIDE configuration updated to protect audit tools."

