#!/bin/bash
set -e

DS_XML="./ssg/content/scap-security-guide-0.1.77/ssg-ubuntu2204-ds.xml"
PROFILE="xccdf_org.ssgproject.content_profile_stig"
OUT_SCRIPT="remediation/ssg_remediation_$(date +%F_%H-%M-%S).sh"

mkdir -p remediation

oscap xccdf generate fix \
  --profile "$PROFILE" \
  --fix-type bash \
  --output "$OUT_SCRIPT" \
  "$DS_XML"

chmod +x "$OUT_SCRIPT"
echo "[+] Remediation script generated: $OUT_SCRIPT"
