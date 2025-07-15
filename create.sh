#!/bin/bash

# Script: create.sh
# Purpose: Automate DISA STIG remediation for Ubuntu 24.04 LTS using OpenSCAP and the Ubuntu 22.04 STIG SCAP benchmark
# Author: Grok (assisted by xAI)
# Date: July 15, 2025
# Usage: Run as root (sudo -i) from /home/everest/openSCAP/openSCAP
# Prerequisites: Internet access for downloading STIG content
# WARNING: Test in a non-production environment first!

set -e  # Exit immediately on error

# Configuration variables
STIG_URL="https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_CAN_Ubuntu_22-04_LTS_V2R2_STIG_SCAP_1-3_Benchmark.zip"
STIG_DIR="/home/everest/openSCAP/openSCAP/stig_content"
LOG_FILE="/var/log/stig_auto_remediation_$(date +%F_%H-%M-%S).log"
BACKUP_DIR="/home/everest/openSCAP/openSCAP/stig_backup_$(date +%F_%H-%M-%S)"

# Log all output to file and console
exec > >(tee -a "$LOG_FILE") 2>&1
echo "STIG Auto-Remediation Script for Ubuntu 24.04 LTS - Started at $(date)"

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "ERROR: This script must be run as root. Use 'sudo -i'."
        exit 1
    fi
}

download_stig_content() {
    echo "Downloading STIG SCAP content from $STIG_URL..."
    apt-get update -y
    apt-get install -y wget unzip
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install wget and unzip."
        exit 1
    fi

    mkdir -p "$STIG_DIR"
    wget -O "$STIG_DIR/stig_ubuntu_22.04.zip" "$STIG_URL"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to download STIG content from $STIG_URL."
        exit 1
    fi

    echo "Extracting STIG content..."
    unzip -o "$STIG_DIR/stig_ubuntu_22.04.zip" -d "$STIG_DIR"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to extract STIG content."
        exit 1
    fi

    # Dynamically locate the SCAP benchmark file
    SCAP_FILE=$(find "$STIG_DIR" -type f -name '*Benchmark.xml' | head -n1)
    if [ ! -f "$SCAP_FILE" ]; then
        echo "ERROR: SCAP XML not found after extraction."
        exit 1
    fi

    echo "WARNING: You are applying Ubuntu 22.04 STIG SCAP content on a 24.04 system."
    echo "Using SCAP file: $SCAP_FILE"
}

create_backup() {
    echo "Creating system backup..."
    mkdir -p "$BACKUP_DIR"
    cp -r /etc "$BACKUP_DIR/etc"
    cp -r /var/log "$BACKUP_DIR/var_log"
    tar -czf "$BACKUP_DIR/system_backup.tar.gz" /etc /var/log
    if [ $? -ne 0 ]; then
        echo "WARNING: Backup creation encountered issues. Proceeding with caution."
    fi
    echo "Backup created at $BACKUP_DIR."
}

install_openscap() {
    echo "Checking and installing OpenSCAP tools..."
    apt-get install -y openscap-scanner libopenscap8
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install OpenSCAP tools."
        exit 1
    fi
    echo "OpenSCAP tools installed successfully."
}

audit_system() {
    echo "Running initial STIG compliance audit..."
    AUDIT_REPORT="/home/everest/openSCAP/openSCAP/stig_audit_report_$(date +%F_%H-%M-%S).html"
    AUDIT_RESULTS="/home/everest/openSCAP/openSCAP/stig_audit_results_$(date +%F_%H-%M-%S).xml"

    oscap xccdf eval \
        --profile xccdf_org.ssgproject.content_profile_stig \
        --results "$AUDIT_RESULTS" \
        --report "$AUDIT_REPORT" \
        "$SCAP_FILE"
    if [ $? -ne 0 ]; then
        echo "WARNING: Initial audit completed with errors. Check $AUDIT_REPORT for details."
    fi
    echo "Initial audit completed. Report saved to $AUDIT_REPORT."
}

generate_and_apply_remediation() {
    echo "Generating remediation script..."
    REMEDIATION_SCRIPT="/home/everest/openSCAP/openSCAP/stig_remediation_$(date +%F_%H-%M-%S).sh"

    oscap xccdf generate fix \
        --profile xccdf_org.ssgproject.content_profile_stig \
        --fix-type bash \
        --output "$REMEDIATION_SCRIPT" \
        "$AUDIT_RESULTS"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to generate remediation script."
        exit 1
    fi

    if [ ! -f "$REMEDIATION_SCRIPT" ]; then
        echo "ERROR: Remediation script not created at $REMEDIATION_SCRIPT."
        exit 1
    fi

    echo "Applying remediation script..."
    chmod +x "$REMEDIATION_SCRIPT"
    bash "$REMEDIATION_SCRIPT"
    if [ $? -ne 0 ]; then
        echo "WARNING: Remediation script encountered errors. Review $LOG_FILE and $REMEDIATION_SCRIPT."
    fi
    echo "Remediation script applied. Check $REMEDIATION_SCRIPT for applied changes."
}

verify_compliance() {
    echo "Running post-remediation audit..."
    POST_AUDIT_REPORT="/home/everest/openSCAP/openSCAP/stig_post_audit_report_$(date +%F_%H-%M-%S).html"
    POST_AUDIT_RESULTS="/home/everest/openSCAP/openSCAP/stig_post_audit_results_$(date +%F_%H-%M-%S).xml"

    oscap xccdf eval \
        --profile xccdf_org.ssgproject.content_profile_stig \
        --results "$POST_AUDIT_RESULTS" \
        --report "$POST_AUDIT_REPORT" \
        "$SCAP_FILE"
    if [ $? -ne 0 ]; then
        echo "WARNING: Post-remediation audit completed with errors. Check $POST_AUDIT_REPORT."
    fi
    echo "Post-remediation audit completed. Report saved to $POST_AUDIT_REPORT."
}

cleanup() {
    echo "Cleaning up temporary files (optional)..."
    # Uncomment below if you wish to auto-clean
    # rm -f "$STIG_DIR/stig_ubuntu_22.04.zip"
    # rm -f "$REMEDIATION_SCRIPT"
    # rm -f "$AUDIT_RESULTS" "$POST_AUDIT_RESULTS"
    echo "Cleanup completed (temporary files retained for review)."
}

# Main Execution Flow
echo "Starting STIG auto-remediation process for Ubuntu 24.04 LTS..."

check_root
download_stig_content
create_backup
install_openscap
audit_system
generate_and_apply_remediation
verify_compliance
cleanup

echo "STIG auto-remediation process completed at $(date)."
echo "Review the following for compliance status:"
echo "- Initial audit report: $AUDIT_REPORT"
echo "- Remediation script: $REMEDIATION_SCRIPT"
echo "- Post-remediation audit report: $POST_AUDIT_REPORT"
echo "- Log file: $LOG_FILE"
echo "⚠️ Note: Ubuntu 22.04 SCAP was used on Ubuntu 24.04. Manual validation of results is strongly recommended."

exit 0

echo "Manual intervention may be required for non-automated STIG rules."

exit 0
