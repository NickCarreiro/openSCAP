#!/bin/bash
set -e

echo "Updating package lists..."
sudo apt-get update

echo "Installing rsyslog..."
sudo apt-get install -y rsyslog

echo "Enabling and starting rsyslog service..."
sudo systemctl enable rsyslog.service --now

echo "rsyslog installation and activation completed successfully."
