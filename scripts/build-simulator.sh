#!/usr/bin/env bash
set -euo pipefail

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/private/tmp/cloudtape-derived}"

xcodegen generate
xcodebuild \
  -project CloudTape.xcodeproj \
  -scheme CloudTape \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  build
