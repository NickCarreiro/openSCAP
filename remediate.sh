#!/bin/bash

# === Metadata ===
# Script Name: remediate_stig.sh
# Purpose: Generate and apply remediation based on DISA STIG SCAP benchmark
# OS: Ubuntu 22.04
# Tools: OpenSCAP
# Author: Rabies + xAI
# Date: July 15, 2025

set -euo pipefail

# === Paths and Config ===
PROFILE_ID="xccdf_mil.disa.stig_profile_MAC-3_Public"
SCAP_FILE="/home/everest/openSCAP/openSCAP/stig_content/U_CAN_Ubuntu_22-04_LTS_V2R2_STIG_SCAP_1-3_Benchmark.xml"

TIMESTAMP=$(date +%F_%H-%M-%S)
WORKDIR="/home/everest/openSCAP"
FIX_SCRIPT="${WORKDIR}/stig_remediation_${TIMESTAMP}.sh"
POST_AUDIT_REPORT="${WORKDIR}/stig_post_audit_report_${TIMESTAMP}.html"
POST_AUDIT_RESULTS="${WORKDIR}/stig_post_audit_results_${TIMESTAMP}.xml"
LOG_FILE="${WORKDIR}/stig_remediation_log_${TIMESTAMP}.log"

# === Prerequisite Check ===
command -v oscap >/dev/null 2>&1 || { echo "❌ OpenSCAP is not installed."; exit 1; }

if [ ! -f "$SCAP_FILE" ]; then
    echo "❌ SCAP benchmark file not found: $SCAP_FILE"
    exit 1
fi

# === Step 1: Generate Remediation ===
echo "Generating remediation script for profile: $PROFILE_ID"
oscap xccdf generate fix \
    --profile "$PROFILE_ID" \
    --fix-type bash \
    --output "$FIX_SCRIPT" \
    "$SCAP_FILE"

if [ ! -s "$FIX_SCRIPT" ]; then
    echo "❌ Failed to generate fix script."
    exit 1
fi

chmod +x "$FIX_SCRIPT"
echo "✅ Remediation script saved to: $FIX_SCRIPT"

# === Step 2: Apply Remediation ===
echo "Applying remediation script..."
bash "$FIX_SCRIPT" | tee "$LOG_FILE"
echo "✅ Remediation applied. Log saved to: $LOG_FILE"

# === Step 3: Post-Remediation Audit ===
echo "Running post-remediation audit..."
oscap xccdf eval \
    --profile "$PROFILE_ID" \
    --results "$POST_AUDIT_RESULTS" \
    --report "$POST_AUDIT_REPORT" \
    --oval-results \
    --skip-valid \
    "$SCAP_FILE"

echo "✅ Post-audit complete."
echo "Report: $POST_AUDIT_REPORT"
echo "Results: $POST_AUDIT_RESULTS"
