#!/bin/bash

# Script: create.sh
# Purpose: Apply Ubuntu 22.04 DISA STIG SCAP benchmark using OpenSCAP
# Author: Grok (assisted by xAI)
# Date: July 15, 2025
# Usage: Run as root (sudo -i) from /home/everest/openSCAP/openSCAP
# WARNING: Test in non-production environments first

set -e

# Configuration
STIG_URL="https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_CAN_Ubuntu_22-04_LTS_V2R2_STIG_SCAP_1-3_Benchmark.zip"
STIG_DIR="/home/everest/openSCAP/openSCAP/stig_content"
LOG_FILE="/var/log/stig_auto_remediation_$(date +%F_%H-%M-%S).log"
BACKUP_DIR="/home/everest/openSCAP/openSCAP/stig_backup_$(date +%F_%H-%M-%S)"
PROFILE_ID="xccdf_mil.disa.stig_profile_MAC-3_Public"

# Logging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "=== STIG Auto-Remediation Script for Ubuntu 22.04 ==="
echo "Started at: $(date)"

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "ERROR: This script must be run as root."
        exit 1
    fi
}

download_stig_content() {
    echo "Downloading STIG content from $STIG_URL..."
    apt-get update -y
    apt-get install -y wget unzip
    mkdir -p "$STIG_DIR"
    wget -O "$STIG_DIR/stig_ubuntu_22.04.zip" "$STIG_URL"
    unzip -o "$STIG_DIR/stig_ubuntu_22.04.zip" -d "$STIG_DIR"

    SCAP_FILE=$(find "$STIG_DIR" -type f -name '*Benchmark.xml' | head -n1)
    if [ ! -f "$SCAP_FILE" ]; then
        echo "ERROR: SCAP XML not found after extraction."
        exit 1
    fi

    echo "Using SCAP file: $SCAP_FILE"
}

create_backup() {
    echo "Creating system backup to $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/system_backup.tar.gz" /etc /var/log
    echo "Backup completed."
}

install_openscap() {
    echo "Installing OpenSCAP tools..."
    apt-get install -y openscap-scanner libopenscap25t64 openscap-common
    echo "OpenSCAP tools installed."
}

audit_system() {
    echo "Running initial compliance audit..."
    AUDIT_REPORT="/home/everest/openSCAP/openSCAP/stig_audit_report_$(date +%F_%H-%M-%S).html"
    AUDIT_RESULTS="/home/everest/openSCAP/openSCAP/stig_audit_results_$(date +%F_%H-%M-%S).xml"

    oscap xccdf eval \
        --profile "$PROFILE_ID" \
        --results "$AUDIT_RESULTS" \
        --report "$AUDIT_REPORT" \
        --oval-results \
        --skip-valid \
        "$SCAP_FILE"

    echo "Initial audit complete. Results: $AUDIT_RESULTS"
}

generate_and_apply_remediation() {
    echo "Generating remediation script..."
    REMEDIATION_SCRIPT="/home/everest/openSCAP/openSCAP/stig_remediation_$(date +%F_%H-%M-%S).sh"

    oscap xccdf generate fix \
        --profile "$PROFILE_ID" \
        --fix-type bash \
        --output "$REMEDIATION_SCRIPT" \
        "$SCAP_FILE"

    if [ ! -f "$REMEDIATION_SCRIPT" ]; then
        echo "ERROR: Failed to generate remediation script."
        exit 1
    fi

    echo "Applying remediation script..."
    chmod +x "$REMEDIATION_SCRIPT"
    bash "$REMEDIATION_SCRIPT" || echo "WARNING: Some remediation steps failed."
    echo "Remediation applied. Script saved to $REMEDIATION_SCRIPT"
}

verify_compliance() {
    echo "Running post-remediation audit..."
    POST_AUDIT_REPORT="/home/everest/openSCAP/openSCAP/stig_post_audit_report_$(date +%F_%H-%M-%S).html"
    POST_AUDIT_RESULTS="/home/everest/openSCAP/openSCAP/stig_post_audit_results_$(date +%F_%H-%M-%S).xml"

    oscap xccdf eval \
        --profile "$PROFILE_ID" \
        --results "$POST_AUDIT_RESULTS" \
        --report "$POST_AUDIT_REPORT" \
        --oval-results \
        --skip-valid \
        "$SCAP_FILE"

    echo "Post-remediation audit complete. Report: $POST_AUDIT_REPORT"
}

cleanup() {
    echo "Cleanup: keeping all output files for review."
    # Uncomment below if you want to auto-delete intermediate files
    # rm -f "$STIG_DIR/stig_ubuntu_22.04.zip"
}

# === Main Execution ===
check_root
download_stig_content
create_backup
install_openscap
audit_system
generate_and_apply_remediation
verify_compliance
cleanup

echo "=== STIG Auto-Remediation Completed at $(date) ==="
echo "Review reports and remediation scripts:"
echo "- Initial report:     $AUDIT_REPORT"
echo "- Remediation script: $REMEDIATION_SCRIPT"
echo "- Post audit report:  $POST_AUDIT_REPORT"
echo "- Log file:           $LOG_FILE"

exit 0
