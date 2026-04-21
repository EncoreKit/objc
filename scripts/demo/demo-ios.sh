#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXAMPLE_DIR="$SDK_ROOT/example"
WORKSPACE="$EXAMPLE_DIR/EncoreObjCExample.xcworkspace"
SCHEME="EncoreObjCExample"
DESTINATION="${DESTINATION:-platform=iOS Simulator,OS=latest,name=iPhone 17}"

bash "$SCRIPT_DIR/setup-example.sh"

echo "==> xcodebuild build"
xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    build \
    | xcbeautify 2>/dev/null || xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    build

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Build complete."
echo ""
echo "  1. Open $WORKSPACE in Xcode"
echo "  2. Select an iOS Simulator or device"
echo "  3. Press Cmd+R to run"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
