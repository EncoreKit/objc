#!/usr/bin/env bash
# Check if EncoreKit on CocoaPods trunk is newer than the pin in
# config/sdk-versions.json. If so, update the file + Package.swift and
# stage changes (or open a PR when run in CI).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSIONS_FILE="$SDK_ROOT/config/sdk-versions.json"
PACKAGE_SWIFT="$SDK_ROOT/Package.swift"

CURRENT=$(python3 -c "import json; print(json.load(open('$VERSIONS_FILE'))['ios']['EncoreKit'])")
echo "Current EncoreKit pin: $CURRENT"

LATEST=$(pod trunk info EncoreKit 2>/dev/null \
    | awk '/^[[:space:]]+- [0-9]+\.[0-9]+\.[0-9]+/ {gsub(/[^0-9.]/,""); print; exit}')

if [[ -z "${LATEST:-}" ]]; then
    echo "ERROR: Could not parse latest EncoreKit version from CocoaPods trunk" >&2
    exit 1
fi
echo "Latest EncoreKit on trunk: $LATEST"

vercmp () {
    [[ "$1" == "$2" ]] && { echo 0; return; }
    local a b ra rb
    IFS='.' read -ra a <<< "$1"
    IFS='.' read -ra b <<< "$2"
    for i in 0 1 2; do
        ra="${a[$i]:-0}"; rb="${b[$i]:-0}"
        if (( ra > rb )); then echo 1; return; fi
        if (( ra < rb )); then echo -1; return; fi
    done
    echo 0
}

cmp=$(vercmp "$LATEST" "$CURRENT")
if [[ "$cmp" -le 0 ]]; then
    echo "Pin is up to date."
    exit 0
fi

echo ""
echo "==> Updating EncoreKit pin: $CURRENT -> $LATEST"

python3 - "$VERSIONS_FILE" "$LATEST" <<'PY'
import json, sys
path, latest = sys.argv[1], sys.argv[2]
with open(path) as f: data = json.load(f)
data['ios']['EncoreKit'] = latest
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
PY

sed -i.bak "s|exact: \"[0-9.]*\"|exact: \"$LATEST\"|" "$PACKAGE_SWIFT"
rm "$PACKAGE_SWIFT.bak"

echo "Updated:"
echo "  $VERSIONS_FILE"
echo "  $PACKAGE_SWIFT"
echo ""
echo "Review with: git diff"
