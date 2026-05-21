#!/usr/bin/env bash
set -euo pipefail

SCHEME="${SCHEME:-CloudTape}"
CONFIGURATION="${CONFIGURATION:-Debug}"
BUNDLE_ID="${BUNDLE_ID:-io.github.junnakarai.cloudtape}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/private/tmp/cloudtape-screenshot-derived}"
OUTPUT_DIR="${OUTPUT_DIR:-docs/screenshots}"
DEMO_MEDIA_DIR="${DEMO_MEDIA_DIR:-docs/assets/demo-media}"
APP_STORE_DEVICE_NAME="${DEVICE_NAME:-CloudTape App Store 6.5 iPhone 11 Pro Max}"
APP_STORE_DEVICE_TYPE="${DEVICE_TYPE:-iPhone 11 Pro Max}"
REQUESTED_DEVICE_ID="${DEVICE_ID:-}"
SCREENSHOT_SETTLE_SECONDS="${SCREENSHOT_SETTLE_SECONDS:-8}"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '==> %s\n' "$*"
}

command -v ffmpeg >/dev/null || die "ffmpeg is not available."
command -v swift >/dev/null || die "swift is not available."
command -v sips >/dev/null || die "sips is not available."
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

device_id_by_name() {
  local name="$1"
  xcrun simctl list devices available | awk -v name="$name" '
    index($0, name " (") > 0 {
      print
      exit
    }
  ' | sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/'
}

select_device() {
  if [[ -n "$REQUESTED_DEVICE_ID" ]]; then
    DEVICE_ID="$REQUESTED_DEVICE_ID"
    DEVICE_DESTINATION="id=$DEVICE_ID"
    SIMCTL_TARGET="$DEVICE_ID"
    DEVICE_NAME="$REQUESTED_DEVICE_ID"
    return
  fi

  DEVICE_ID="$(device_id_by_name "$APP_STORE_DEVICE_NAME")"
  if [[ -z "$DEVICE_ID" ]]; then
    DEVICE_ID="$(device_id_by_name "$APP_STORE_DEVICE_TYPE")"
  fi

  if [[ -z "$DEVICE_ID" ]]; then
    local runtime type_id
    runtime="$(latest_ios_runtime)"
    [[ -n "$runtime" ]] || die "No available iOS Simulator runtimes found."
    type_id="$(device_type_id "$APP_STORE_DEVICE_TYPE")"
    [[ -n "$type_id" ]] || die "Could not find Simulator device type: $APP_STORE_DEVICE_TYPE"
    DEVICE_ID="$(xcrun simctl create "$APP_STORE_DEVICE_NAME" "$type_id" "$runtime")"
    DEVICE_NAME="$APP_STORE_DEVICE_NAME"
  else
    DEVICE_NAME="$APP_STORE_DEVICE_TYPE"
  fi

  DEVICE_DESTINATION="id=$DEVICE_ID"
  SIMCTL_TARGET="$DEVICE_ID"
}

generate_demo_media() {
  info "Generating App Store demo media"
  mkdir -p "$DEMO_MEDIA_DIR"
  swift scripts/generate-demo-media.swift "$DEMO_MEDIA_DIR"
}

launch_app() {
  local args=("$@")
  xcrun simctl terminate "$SIMCTL_TARGET" "$BUNDLE_ID" >/dev/null 2>&1 || true
  if [[ "${#args[@]}" -gt 0 ]]; then
    xcrun simctl launch "$SIMCTL_TARGET" "$BUNDLE_ID" --args "${args[@]}"
  else
    xcrun simctl launch "$SIMCTL_TARGET" "$BUNDLE_ID"
  fi
}

capture_state() {
  local filename="$1"
  shift
  local path="$OUTPUT_DIR/$filename"

  info "Launching state for $filename"
  launch_app "$@"
  sleep "$SCREENSHOT_SETTLE_SECONDS"

  info "Capturing screenshot: $path"
  xcrun simctl io "$SIMCTL_TARGET" screenshot "$path"
}

validate_size() {
  local path="$1"
  local width height
  width="$(sips -g pixelWidth "$path" | awk '/pixelWidth/ { print $2 }')"
  height="$(sips -g pixelHeight "$path" | awk '/pixelHeight/ { print $2 }')"

  case "${width}x${height}" in
    1242x2688|2688x1242|1284x2778|2778x1284)
      printf '%s %sx%s OK\n' "$path" "$width" "$height"
      ;;
    *)
      printf '%s %sx%s INVALID\n' "$path" "$width" "$height"
      return 1
      ;;
  esac
}

select_device
generate_demo_media

info "Scheme: $SCHEME"
info "Simulator: $DEVICE_NAME ($SIMCTL_TARGET)"
info "Bundle ID: $BUNDLE_ID"
info "DerivedData: $DERIVED_DATA_PATH"
info "Output: $OUTPUT_DIR"

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

DATA_CONTAINER="$(xcrun simctl get_app_container "$SIMCTL_TARGET" "$BUNDLE_ID" data)"
DEMO_CONTAINER_DIR="$DATA_CONTAINER/Documents/CloudTapeDemo"
EMPTY_CONTAINER_DIR="$DATA_CONTAINER/Documents/CloudTapeEmpty"
rm -rf "$DEMO_CONTAINER_DIR" "$EMPTY_CONTAINER_DIR"
mkdir -p "$DEMO_CONTAINER_DIR" "$EMPTY_CONTAINER_DIR"
find "$DEMO_MEDIA_DIR" -maxdepth 1 -type f -name 'cloudtape-session-*.mp3' -exec cp {} "$DEMO_CONTAINER_DIR/" \;

if ! find "$DEMO_CONTAINER_DIR" -maxdepth 1 -type f -name '*.mp3' | grep -q .; then
  die "No App Store demo MP3 files were copied into the Simulator container."
fi

BASE_ARGS=(-CloudTapeDemoFolder "$DEMO_CONTAINER_DIR")

capture_state "iphone-01-library.png" "${BASE_ARGS[@]}"
capture_state "iphone-02-mini-player.png" "${BASE_ARGS[@]}" -CloudTapeDemoAutoplay
capture_state "iphone-03-full-player.png" "${BASE_ARGS[@]}" -CloudTapeDemoAutoplay -CloudTapeDemoExpandPlayer
capture_state "iphone-04-search.png" "${BASE_ARGS[@]}" -CloudTapeDemoShowSearch -CloudTapeDemoSearchQuery "Sailor"
capture_state "iphone-05-folder-state.png" -CloudTapeDemoFolder "$EMPTY_CONTAINER_DIR"

info "Validating App Store screenshot sizes"
for screenshot in "$OUTPUT_DIR"/iphone-*.png; do
  validate_size "$screenshot"
done

info "Done"
