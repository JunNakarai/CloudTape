# Development

CloudTape is a personal SwiftUI iOS app generated with XcodeGen.

## Environment

- macOS with Xcode installed
- XcodeGen
- iOS 17.0 or later deployment target
- Optional: an Apple Developer account or personal Apple ID for device signing

Install XcodeGen:

```sh
brew install xcodegen
```

## XcodeGen

The checked-in source of truth is `project.yml`.

```sh
xcodegen generate
```

Regenerate `CloudTape.xcodeproj` after changing files, build settings, targets, or capabilities.

## Simulator Build

Use the local script:

```sh
./scripts/build-simulator.sh
```

Or run the commands directly:

```sh
xcodegen generate
xcodebuild \
  -project CloudTape.xcodeproj \
  -scheme CloudTape \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/cloudtape-derived \
  build
```

## Device Build

Device builds require signing and a connected trusted device:

```sh
xcodebuild \
  -project CloudTape.xcodeproj \
  -scheme CloudTape \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /private/tmp/cloudtape-device-derived \
  -allowProvisioningUpdates \
  build
```

Install with `xcrun devicectl` or from Xcode.

## DerivedData Location

Do not put DerivedData under iCloud Drive or other File Provider backed folders. Code signing can fail when generated bundles inherit File Provider attributes. Use `/private/tmp/cloudtape-derived` or another local non-iCloud path.

## Useful Commands

```sh
git status --short --branch
xcodegen generate
./scripts/build-simulator.sh
xcrun simctl install <simulator-id> /private/tmp/cloudtape-derived/Build/Products/Debug-iphonesimulator/CloudTape.app
xcrun simctl launch <simulator-id> io.github.junnakarai.cloudtape
```

## Troubleshooting

### Code Signing

Confirm the Xcode account is signed in, the team is selected, and automatic signing can create a development profile. For command line builds, use `-allowProvisioningUpdates`.

### iCloud Drive File Provider Attributes

If signing fails with unexpected bundle or file attribute errors, clean the build output and rebuild with `-derivedDataPath` outside iCloud Drive.

### Simulator File Selection

The simulator can open the Files picker, but it may not have the same iCloud Drive contents as the device. Use a local simulator folder for basic testing and verify iCloud behavior on device.

### Device Developer Mode

On a physical iPhone, enable Developer Mode, trust the Mac, and keep the device unlocked during install and launch. If CoreDevice resets the connection, retry the install once.
