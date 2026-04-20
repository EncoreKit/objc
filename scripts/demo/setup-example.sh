#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXAMPLE_DIR="$SDK_ROOT/example"

if [[ ! -d "$EXAMPLE_DIR" ]]; then
    echo "ERROR: example/ directory missing at $EXAMPLE_DIR"
    exit 1
fi

cd "$EXAMPLE_DIR"

if [[ -f Podfile.lock ]]; then
    echo "==> pod update EncoreObjC EncoreKit"
    pod update EncoreObjC EncoreKit --repo-update
else
    echo "==> pod install (first run)"
    pod install --repo-update
fi

echo ""
echo "Setup complete."
echo ""
echo "  Open: $EXAMPLE_DIR/EncoreObjCExample.xcworkspace"
