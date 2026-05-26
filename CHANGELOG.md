# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1] - 2026-05-26

Maintenance update candidate built from the latest committed app state.

### Changed
- Prepare a new App Store update build after the published 1.0 build.
- Include explicit exempt-encryption declaration in the app bundle metadata.
- Complete delayed optional support transactions when StoreKit reports their updated status.

## [1.0.0] - 2026-05-25

First public App Store release candidate.

### Added
- Folder-based playback from iCloud Drive and the Files app.
- Security-scoped bookmark restore for the previously selected folder.
- Library scan with metadata/artwork extraction for supported audio files.
- Shuffle playback, mini player, expanded Now Playing view, and search.
- Background audio, Lock Screen metadata, Control Center, and headphone controls.
- Optional consumable support purchase (`cloudtape.coffee.small`).
- Bundled sample audio path for App Review verification.

### Notes
- Privacy posture is intentionally minimal: no account system, no analytics SDK, no ads, and no CloudTape backend.
- Public release assets and metadata drafts live under `docs/`.
