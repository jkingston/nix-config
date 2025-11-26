#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Find all .nix files (avoids deprecated directory passing)
NIX_FILES=$(find . -name "*.nix" -type f)

if [[ "${1:-}" == "--check" ]]; then
    echo "=== Format Check ==="
    nix run nixpkgs#nixfmt-rfc-style -- --check $NIX_FILES
    echo "Format check passed!"
else
    echo "=== Formatting ==="
    nix run nixpkgs#nixfmt-rfc-style -- $NIX_FILES
    echo "Formatted!"
fi
