#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXAMPLE_DIR="$SDK_ROOT/example"
WORKSPACE="$EXAMPLE_DIR/EncoreObjCExample.xcworkspace"
SCHEME="${SCHEME:-EncoreObjCExample}"

bash "$SCRIPT_DIR/setup-example.sh"

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
        echo "ERROR: no available iOS Simulator found." >&2
        exit 1
    fi
    DESTINATION="platform=iOS Simulator,id=$DEVICE_ID"
    echo "==> Using simulator: $DEVICE_ID"
fi

echo "==> xcodebuild test ($SCHEME)"
xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    test
