#!/bin/bash
set -e

DS_XML="./ssg/content/scap-security-guide-0.1.77/ssg-ubuntu2204-ds.xml"
PROFILE="xccdf_org.ssgproject.content_profile_stig"
TIMESTAMP=$(date +%F_%H-%M-%S)

oscap xccdf eval \
  --profile "$PROFILE" \
  --results "reports/ssg_scan_results_$TIMESTAMP.xml" \
  --report "reports/ssg_scan_report_$TIMESTAMP.html" \
  --oval-results \
  --skip-valid \
  "$DS_XML"

echo "[+] SSG scan completed. See reports/ directory."
