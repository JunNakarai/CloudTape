#!/usr/bin/env python3
"""Verify the preserved build 9 source inputs, without changing any files."""
import hashlib
import json
import sys
from pathlib import Path


def main():
    repository = Path(__file__).resolve().parents[1]
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else repository
    manifest = json.loads((repository / "docs/releases/build9-source-manifest.json").read_text())
    failures = []
    for relative, expected in manifest["files"].items():
        path = root / relative
        if not path.is_file():
            failures.append(f"Missing: {relative}")
        elif hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            failures.append(f"Changed: {relative}")
    input_folders = ("CloudTape", "CloudTapeTests", "Configuration")
    expected_inputs = {p for p in manifest["files"] if p.split("/")[0] in input_folders}
    actual_inputs = {
        str(p.relative_to(root))
        for folder in input_folders
        for p in (root / folder).rglob("*")
        if p.is_file() and p.name != ".DS_Store"
    }
    failures.extend(f"Added build input: {p}" for p in sorted(actual_inputs - expected_inputs))
    if failures:
        print("Build 9 source verification failed:", file=sys.stderr)
        print("\n".join(failures), file=sys.stderr)
        return 1
    print(f"Verified {len(manifest['files'])} preserved build 9 inputs at {root}")
    print("This verifies source hashes, not bit-for-bit signed-IPA reproducibility or live StoreKit behavior.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
