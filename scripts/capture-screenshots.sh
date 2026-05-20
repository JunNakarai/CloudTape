#!/usr/bin/env bash
set -euo pipefail

SCHEME="${SCHEME:-CloudTape}"
CONFIGURATION="${CONFIGURATION:-Debug}"
BUNDLE_ID="${BUNDLE_ID:-io.github.junnakarai.cloudtape}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/private/tmp/cloudtape-screenshot-derived}"
OUTPUT_DIR="${OUTPUT_DIR:-docs/assets/screenshots}"
SCREENSHOT_NAME="${SCREENSHOT_NAME:-cloudtape-home.png}"
DEMO_MEDIA_DIR="${DEMO_MEDIA_DIR:-docs/assets/demo-media}"
DEMO_ENABLED="${DEMO_ENABLED:-1}"
REQUESTED_DEVICE_NAME="${DEVICE_NAME:-}"
REQUESTED_DEVICE_ID="${DEVICE_ID:-}"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '==> %s\n' "$*"
}

command -v xcodebuild >/dev/null || die "xcodebuild is not available."
command -v xcrun >/dev/null || die "xcrun is not available."

if [[ ! -d "CloudTape.xcodeproj" ]]; then
  die "Run this script from the CloudTape repository root."
fi

PROJECT_ARGS=(-project "CloudTape.xcodeproj")
EXTERNAL_WORKSPACE="$(find . -maxdepth 2 -name '*.xcworkspace' -not -path './*.xcodeproj/*' -print -quit)"
if [[ -n "$EXTERNAL_WORKSPACE" ]]; then
  PROJECT_ARGS=(-workspace "$EXTERNAL_WORKSPACE")
fi

latest_ios_runtime() {
  xcrun simctl list runtimes | awk '
    /^iOS / && $0 !~ /unavailable/ {
      runtime=$NF
    }
    END {
      if (runtime != "") print runtime
    }
  '
}

device_type_id() {
  local name="$1"
  xcrun simctl list devicetypes | awk -v name="$name" '
    index($0, name " (") == 1 {
      line=$0
      sub(/^.*\(/, "", line)
      sub(/\)$/, "", line)
      print line
      exit
    }
  '
}

select_device() {
  if [[ -n "$REQUESTED_DEVICE_ID" ]]; then
    DEVICE_ID="$REQUESTED_DEVICE_ID"
    DEVICE_DESTINATION="id=$DEVICE_ID"
    SIMCTL_TARGET="$DEVICE_ID"
    return
  fi

  local devices
  devices="$(xcrun simctl list devices available)"

  if [[ -n "$REQUESTED_DEVICE_NAME" ]] && grep -q "^[[:space:]]*$REQUESTED_DEVICE_NAME (" <<<"$devices"; then
    DEVICE_NAME="$REQUESTED_DEVICE_NAME"
    DEVICE_DESTINATION="name=$DEVICE_NAME"
    SIMCTL_TARGET="$DEVICE_NAME"
    return
  fi

  local preferred fallback_name runtime type_id created_name
  for preferred in "iPhone 16 Pro" "iPhone 15 Pro" "iPhone 15"; do
    if grep -q "^[[:space:]]*$preferred (" <<<"$devices"; then
      DEVICE_NAME="$preferred"
      DEVICE_DESTINATION="name=$DEVICE_NAME"
      SIMCTL_TARGET="$DEVICE_NAME"
      return
    fi
  done

  fallback_name="$(awk '/^[[:space:]]+iPhone / {
    line=$0
    sub(/^[[:space:]]+/, "", line)
    sub(/[[:space:]]+\(.*/, "", line)
    print line
    exit
  }' <<<"$devices")"

  if [[ -n "$fallback_name" ]]; then
    DEVICE_NAME="$fallback_name"
    DEVICE_DESTINATION="name=$DEVICE_NAME"
    SIMCTL_TARGET="$DEVICE_NAME"
    return
  fi

  runtime="$(latest_ios_runtime)"
  [[ -n "$runtime" ]] || die "No available iOS Simulator runtimes found. Install an iOS Simulator runtime in Xcode Settings > Platforms, then rerun this script."

  for preferred in "${REQUESTED_DEVICE_NAME:-}" "iPhone 16 Pro" "iPhone 15 Pro" "iPhone 15"; do
    [[ -n "$preferred" ]] || continue
    type_id="$(device_type_id "$preferred")"
    if [[ -n "$type_id" ]]; then
      created_name="CloudTape $preferred"
      DEVICE_ID="$(xcrun simctl create "$created_name" "$type_id" "$runtime")"
      DEVICE_NAME="$created_name"
      DEVICE_DESTINATION="id=$DEVICE_ID"
      SIMCTL_TARGET="$DEVICE_ID"
      return
    fi
  done

  die "Could not find a usable iPhone Simulator device type."
}

DEVICE_NAME=""
DEVICE_ID=""
DEVICE_DESTINATION=""
SIMCTL_TARGET=""
select_device
[[ -n "$SIMCTL_TARGET" ]] || die "Could not select an iPhone Simulator."

info "Scheme: $SCHEME"
info "Simulator: $DEVICE_NAME"
info "Bundle ID: $BUNDLE_ID"
info "DerivedData: $DERIVED_DATA_PATH"

mkdir -p "$OUTPUT_DIR"

info "Building for iOS Simulator"
xcodebuild \
  "${PROJECT_ARGS[@]}" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "platform=iOS Simulator,$DEVICE_DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="$DERIVED_DATA_PATH/Build/Products/${CONFIGURATION}-iphonesimulator/${SCHEME}.app"
if [[ ! -d "$APP_PATH" ]]; then
  APP_PATH="$(find "$DERIVED_DATA_PATH/Build/Products/${CONFIGURATION}-iphonesimulator" -maxdepth 1 -name "${SCHEME}.app" -type d -print -quit 2>/dev/null || true)"
fi
[[ -n "$APP_PATH" && -d "$APP_PATH" ]] || die "Built app was not found under $DERIVED_DATA_PATH."

info "Booting Simulator"
xcrun simctl boot "$SIMCTL_TARGET" 2>/dev/null || true
xcrun simctl bootstatus "$SIMCTL_TARGET" -b
open -a Simulator

info "Installing app"
xcrun simctl install "$SIMCTL_TARGET" "$APP_PATH"

LAUNCH_ARGS=()
if [[ "$DEMO_ENABLED" == "1" && -d "$DEMO_MEDIA_DIR" ]]; then
  DATA_CONTAINER="$(xcrun simctl get_app_container "$SIMCTL_TARGET" "$BUNDLE_ID" data)"
  DEMO_CONTAINER_DIR="$DATA_CONTAINER/Documents/CloudTapeDemo"
  mkdir -p "$DEMO_CONTAINER_DIR"
  find "$DEMO_CONTAINER_DIR" -maxdepth 1 -type f -name '*.mp3' -delete
  find "$DEMO_MEDIA_DIR" -maxdepth 1 -type f -name '*.mp3' ! -name '*source*' -exec cp {} "$DEMO_CONTAINER_DIR/" \;

  if find "$DEMO_CONTAINER_DIR" -maxdepth 1 -type f -name '*.mp3' | grep -q .; then
    info "Copied demo media to: $DEMO_CONTAINER_DIR"
    LAUNCH_ARGS=(-CloudTapeDemoFolder "$DEMO_CONTAINER_DIR" -CloudTapeDemoAutoplay)
  else
    info "No demo MP3 files found in $DEMO_MEDIA_DIR; launching without demo media"
  fi
fi

launch_app() {
  if [[ "$#" -gt 0 ]]; then
    xcrun simctl launch "$SIMCTL_TARGET" "$BUNDLE_ID" --args "$@"
  else
    xcrun simctl launch "$SIMCTL_TARGET" "$BUNDLE_ID"
  fi
}

info "Launching app"
launch_app "${LAUNCH_ARGS[@]}"
sleep 6

SCREENSHOT_PATH="$OUTPUT_DIR/$SCREENSHOT_NAME"
info "Capturing screenshot: $SCREENSHOT_PATH"
xcrun simctl io "$SIMCTL_TARGET" screenshot "$SCREENSHOT_PATH"

if [[ "${#LAUNCH_ARGS[@]}" -gt 0 ]]; then
  LIBRARY_SCREENSHOT_PATH="$OUTPUT_DIR/cloudtape-library.png"
  info "Capturing library screenshot: $LIBRARY_SCREENSHOT_PATH"
  xcrun simctl io "$SIMCTL_TARGET" screenshot "$LIBRARY_SCREENSHOT_PATH"

  info "Relaunching app with expanded player"
  xcrun simctl terminate "$SIMCTL_TARGET" "$BUNDLE_ID" >/dev/null 2>&1 || true
  launch_app "${LAUNCH_ARGS[@]}" -CloudTapeDemoExpandPlayer
  sleep 6

  NOW_PLAYING_SCREENSHOT_PATH="$OUTPUT_DIR/cloudtape-now-playing.png"
  info "Capturing now playing screenshot: $NOW_PLAYING_SCREENSHOT_PATH"
  xcrun simctl io "$SIMCTL_TARGET" screenshot "$NOW_PLAYING_SCREENSHOT_PATH"
fi

info "Done"
printf '%s\n' "$SCREENSHOT_PATH"
