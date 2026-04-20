#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$SDK_ROOT"

echo "==> pod lib lint EncoreObjC.podspec"
pod lib lint EncoreObjC.podspec --allow-warnings
