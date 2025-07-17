#!/bin/bash
set -e

SSG_URL="https://github.com/ComplianceAsCode/content/releases/download/v0.1.77/scap-security-guide-0.1.77.tar.gz"
DEST_DIR="./ssg/content"

mkdir -p "$DEST_DIR"
cd "$DEST_DIR"

echo "[*] Downloading SSG..."
wget -O ssg.tar.gz "$SSG_URL"
tar -xf ssg.tar.gz
rm ssg.tar.gz

echo "[+] SSG downloaded to: $DEST_DIR"
