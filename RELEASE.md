# CloudTape Release Notes

## App Store Connect Device Family

CloudTape is currently prepared as an iPhone-only app.

- `TARGETED_DEVICE_FAMILY` must be `1`.
- Do not add iPad screenshots unless iPad support is intentionally enabled later.
- The iPad-specific orientation key `UISupportedInterfaceOrientations~ipad` is intentionally omitted.

After changing device-family support, upload a new archive to App Store Connect so the supported-device metadata is recalculated for the new build.

Local unsigned archive verification command:

```sh
xcodebuild \
  -project CloudTape.xcodeproj \
  -scheme CloudTape \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath /private/tmp/cloudtape-iphone-only-archives/CloudTape.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  archive
```

For App Store Connect, create or distribute a newly signed Release archive from Xcode Organizer using the existing Apple Distribution setup, then upload that new build. Do not reuse an older uploaded build, because its device-family metadata can still require iPad screenshots.
