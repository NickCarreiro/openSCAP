#!/bin/bash

# === Configuration ===
PROFILE_ID="xccdf_mil.disa.stig_profile_MAC-3_Public"
SCAP_FILE="/home/everest/openSCAP/openSCAP/stig_content/U_CAN_Ubuntu_22-04_LTS_V2R2_STIG_SCAP_1-3_Benchmark.xml"
TIMESTAMP=$(date +%F_%H-%M-%S)
WORKDIR="/home/everest/openSCAP"
FIX_SCRIPT="${WORKDIR}/stig_remediation_${TIMESTAMP}.sh"
POST_AUDIT_REPORT="${WORKDIR}/stig_post_audit_report_${TIMESTAMP}.html"
POST_AUDIT_RESULTS="${WORKDIR}/stig_post_audit_results_${TIMESTAMP}.xml"
LOG_FILE="${WORKDIR}/stig_remediation_log_${TIMESTAMP}.log"

# === Sanity Checks ===
if [ ! -f "$SCAP_FILE" ]; then
    echo "❌ SCAP file not found at: $SCAP_FILE"
    exit 1
fi

if ! command -v oscap >/dev/null 2>&1; then
    echo "❌ OpenSCAP CLI tool not found. Please install it first."
    exit 1
fi

echo "=== Generating remediation script from SCAP benchmark ==="
oscap xccdf generate fix \
    --profile "$PROFILE_ID" \
    --fix-type bash \
    --output "$FIX_SCRIPT" \
    "$SCAP_FILE"

if [ ! -s "$FIX_SCRIPT" ]; then
    echo "❌ Remediation script generation failed."
    exit 1
fi

chmod +x "$FIX_SCRIPT"
echo "✅ Fix script created at $FIX_SCRIPT"

# === Apply Fixes ===
echo "=== Applying generated remediation script ==="
bash "$FIX_SCRIPT" | tee "$LOG_FILE"
echo "✅ Remediation applied. Output logged to: $LOG_FILE"

# === Post-Remediation Audit ===
echo "=== Performing post-remediation scan ==="
oscap xccdf eval \
    --profile "$PROFILE_ID" \
    --results "$POST_AUDIT_RESULTS" \
    --report "$POST_AUDIT_REPORT" \
    --oval-results \
    --skip-valid \
    "$SCAP_FILE"

echo "✅ Post-remediation report saved:"
echo " - HTML Report: $POST_AUDIT_REPORT"
echo " - XML Results: $POST_AUDIT_RESULTS"

exit 0
