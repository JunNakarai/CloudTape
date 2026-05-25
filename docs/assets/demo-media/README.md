# CloudTape Demo Media

These files are synthetic demo assets for CloudTape screenshots. They are not commercial music, subscription audio, YouTube downloads, or third-party copyrighted music.

The track metadata is intentionally short and screenshot-friendly:

- Artist: `CloudTape Demo Studio`
- Album: `CloudTape Sessions`
- Titles: `First Noel`, `Hey Sailor`, `Shaken`

## Files

| File | Source URL | License | Author / Creator | Usage note | Date created |
| --- | --- | --- | --- | --- | --- |
| `cloudtape-session-first-noel.mp3` | Local generation; no external source URL | CC0 1.0 Public Domain Dedication | Generated with `scripts/generate-demo-media.swift` and `ffmpeg` | Screenshot-only MP3 with embedded artwork and metadata | 2026-05-21 |
| `cloudtape-session-hey-sailor.mp3` | Local generation; no external source URL | CC0 1.0 Public Domain Dedication | Generated with `scripts/generate-demo-media.swift` and `ffmpeg` | Screenshot-only MP3 with embedded artwork and metadata | 2026-05-21 |
| `cloudtape-session-shaken.mp3` | Local generation; no external source URL | CC0 1.0 Public Domain Dedication | Generated with `scripts/generate-demo-media.swift` and `ffmpeg` | Screenshot-only MP3 with embedded artwork and metadata | 2026-05-21 |
| `cloudtape-session-*.png` | Local generation; no external source URL | CC0 1.0 Public Domain Dedication | Generated with `scripts/generate-demo-media.swift` | Unified abstract lo-fi album artwork for screenshots | 2026-05-21 |

## Rebuild

From the repository root:

```sh
swift scripts/generate-demo-media.swift docs/assets/demo-media
```
