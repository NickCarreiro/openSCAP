#!/bin/bash
set -e

STIG_URL="https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_CAN_Ubuntu_22-04_LTS_V2R2_STIG_SCAP_1-3_Benchmark.zip"
DEST_DIR="./disa/content"

mkdir -p "$DEST_DIR"
cd "$DEST_DIR"

echo "[*] Downloading DISA STIG..."
wget -O stig.zip "$STIG_URL"
unzip -o stig.zip
rm stig.zip

echo "[+] DISA STIG benchmark downloaded to: $DEST_DIR"
