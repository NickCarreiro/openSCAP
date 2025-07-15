#!/bin/bash
set -e

SCAP_FILE="./disa/content/U_CAN_Ubuntu_22-04_LTS_V2R2_STIG_SCAP_1-3_Benchmark.xml"
PROFILE="xccdf_mil.disa.stig_profile_MAC-3_Public"
TIMESTAMP=$(date +%F_%H-%M-%S)

oscap xccdf eval \
  --profile "$PROFILE" \
  --results "reports/disa_results_$TIMESTAMP.xml" \
  --report "reports/disa_report_$TIMESTAMP.html" \
  --oval-results \
  --skip-valid \
  "$SCAP_FILE"

echo "[+] DISA STIG scan completed. Reports saved."
