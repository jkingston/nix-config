#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== Nix Flake Check ==="
nix flake check --no-build

echo ""
echo "=== Build Dry-Run ==="
nix build .#nixosConfigurations.framework12.config.system.build.toplevel --dry-run

echo ""
echo "All checks passed!"
