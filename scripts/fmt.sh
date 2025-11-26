#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ "${1:-}" == "--check" ]]; then
    echo "=== Format Check ==="
    nix run nixpkgs#nixfmt-rfc-style -- --check .
    echo "Format check passed!"
else
    echo "=== Formatting ==="
    nix run nixpkgs#nixfmt-rfc-style -- .
    echo "Formatted!"
fi
