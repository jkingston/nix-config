#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== Statix (linter) ==="
nix run nixpkgs#statix -- check .

echo ""
echo "=== Deadnix (dead code) ==="
nix run nixpkgs#deadnix -- --fail .

echo ""
echo "All lints passed!"
