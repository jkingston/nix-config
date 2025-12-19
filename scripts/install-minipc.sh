#!/usr/bin/env bash
set -euo pipefail

# Install script for minipc (Beelink SER5 Pro)
# Run from the NixOS minimal installer

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (sudo)"
    exit 1
fi

REPO_URL="https://github.com/jkingston/nix-config.git"
HOST="minipc"

echo "=== NixOS Installation for $HOST ==="
echo ""
echo "WARNING: This will ERASE the NVMe drive!"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read -r

echo "Cloning configuration..."
nix-shell -p git --run "git clone $REPO_URL /tmp/nix-config"
cd /tmp/nix-config

echo "Running disko (partition + format + mount)..."
nix run github:nix-community/disko -- --mode disko --flake ".#$HOST"

echo "Installing NixOS..."
nixos-install --flake ".#$HOST" --no-root-passwd

echo ""
echo "=== Installation complete! ==="
echo "Run 'reboot' to boot into NixOS"
