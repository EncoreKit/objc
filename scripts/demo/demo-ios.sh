#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXAMPLE_DIR="$SDK_ROOT/example"
WORKSPACE="$EXAMPLE_DIR/EncoreObjCExample.xcworkspace"
SCHEME="EncoreObjCExample"
bash "$SCRIPT_DIR/setup-example.sh"

# Pick the first available iPhone simulator (robust across Xcode versions)
if [[ -z "${DESTINATION:-}" ]]; then
    DEVICE_ID=$(xcrun simctl list devices available -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
best = None
for runtime, devices in data['devices'].items():
    if 'iOS' not in runtime: continue
    for d in devices:
        if d.get('isAvailable') and d['name'].startswith('iPhone'):
            best = d['udid']
            break
    if best: break
if best: print(best)
")
    if [[ -z "$DEVICE_ID" ]]; then
        echo "ERROR: no available iOS Simulator found. Install one via Xcode → Settings → Platforms." >&2
        exit 1
    fi
    DESTINATION="platform=iOS Simulator,id=$DEVICE_ID"
    echo "==> Using simulator: $DEVICE_ID"
fi

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
