#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXAMPLE_DIR="$SDK_ROOT/example"

MODE="${1:-clean}"

echo "==> Cleaning example build artifacts"
rm -rf "$EXAMPLE_DIR/build"
rm -rf "$EXAMPLE_DIR/DerivedData"

if [[ "$MODE" == "--nuke" ]]; then
    echo "==> --nuke: removing Pods, Podfile.lock, workspace"
    rm -rf "$EXAMPLE_DIR/Pods"
    rm -f  "$EXAMPLE_DIR/Podfile.lock"
    rm -rf "$EXAMPLE_DIR/EncoreObjCExample.xcworkspace"
    rm -rf "$SDK_ROOT/.build"
    rm -rf "$SDK_ROOT/.swiftpm"
    DERIVED="$HOME/Library/Developer/Xcode/DerivedData"
    if [[ -d "$DERIVED" ]]; then
        find "$DERIVED" -maxdepth 1 -name "EncoreObjCExample-*" -exec rm -rf {} + 2>/dev/null || true
    fi
    echo "Nuke complete."
fi
