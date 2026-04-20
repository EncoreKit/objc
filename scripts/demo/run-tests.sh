#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXAMPLE_DIR="$SDK_ROOT/example"
WORKSPACE="$EXAMPLE_DIR/EncoreObjCExample.xcworkspace"
SCHEME="${SCHEME:-EncoreObjCExample}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 15}"

bash "$SCRIPT_DIR/setup-example.sh"

echo "==> xcodebuild test ($SCHEME)"
xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    test
