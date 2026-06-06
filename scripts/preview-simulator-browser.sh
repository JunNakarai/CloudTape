#!/usr/bin/env bash
set -euo pipefail

SIMULATOR_ID="${SIMULATOR_ID:-08E79F79-226C-4549-AC2B-A17FFD84DF7C}"

cleanup_serve_sim() {
  npx --yes serve-sim@latest --kill "${SIMULATOR_ID}" >/dev/null 2>&1 || true
}

trap cleanup_serve_sim EXIT INT TERM HUP
cleanup_serve_sim
npx --yes serve-sim@latest "${SIMULATOR_ID}"
