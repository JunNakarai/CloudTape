#!/usr/bin/env bash
set -euo pipefail

SIMULATOR_ID="${SIMULATOR_ID:-192F8B6A-2A39-4C03-AF32-175BB4870033}"

cleanup_serve_sim() {
  npx --yes serve-sim@latest --kill "${SIMULATOR_ID}" >/dev/null 2>&1 || true
}

trap cleanup_serve_sim EXIT INT TERM HUP
cleanup_serve_sim
npx --yes serve-sim@latest "${SIMULATOR_ID}"
