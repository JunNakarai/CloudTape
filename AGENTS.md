# CloudTape Codex Instructions

For every CloudTape UI change, use the Build iOS Apps plugin loop documented in
`docs/ui-review-loop.md`.

Minimum verification:

- Run `build_run_sim` with demo-media launch args.
- Verify the Simulator mirror in the Codex in-app browser.
- Capture screenshots for home, mini player, settings, and empty library.
- Inspect layout, spacing, text clipping, and button hit targets.
- Run `git diff --check` and report the relevant diff summary.

Use the Simulator mirror as the source of truth for Codex in-browser review.
The SwiftUI Preview browser host is out of scope while this project remains an
app target in an `.xcodeproj`.
