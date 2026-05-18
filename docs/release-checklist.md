# CloudTape v1.0 Release Checklist

## Build

- Confirm `MARKETING_VERSION` is `1.0.0`.
- Confirm `CURRENT_PROJECT_VERSION` is incremented for each upload.
- Generate the Xcode project after `project.yml` edits.
- Build Debug for simulator.
- Build Release for generic iOS device.
- Archive in Xcode with automatic signing.
- Validate archive before upload.

## First Launch

- Launch with no previous folder selected.
- Confirm the no-folder state is calm and actionable.
- Choose an iCloud Drive music folder.
- Quit and relaunch.
- Confirm folder access restores from the security-scoped bookmark.
- Move or revoke folder access and confirm the app asks the user to choose again.

## Library States

- Empty folder shows an intentional empty state.
- Folder with unsupported files only shows an intentional empty state.
- Folder with Japanese filenames scans and sorts correctly.
- Folder with very long filenames does not break row layout.
- Large folder opens without UI freeze severe enough to feel broken.
- Search works with title, artist, album, Japanese text, and partial matches.

## iCloud Behavior

- Select a folder containing files already downloaded locally.
- Select a folder containing iCloud files not yet downloaded.
- Confirm CloudTape requests downloads and shows syncing context.
- Try playback before a file finishes downloading and confirm the failure state is graceful.
- Disable network temporarily and confirm unavailable iCloud files do not crash playback.
- Confirm already-downloaded files still play offline.

## Playback

- Start shuffle playback from the main play button.
- Start playback from a selected track.
- Pause and resume from the mini player.
- Use next and previous controls.
- Seek within a track.
- Let a track finish and confirm the next track starts.
- Confirm playback failure does not crash the app.
- Confirm missing files show a useful message.

## Background Audio

- Start playback, lock the device, and confirm audio continues.
- Confirm Lock Screen metadata updates.
- Confirm Lock Screen play, pause, next, previous, and seek controls work.
- Confirm Control Center controls work.
- Confirm AirPods or headphone play/pause controls work.
- Confirm app returns cleanly from background to foreground.
- Confirm playback state remains accurate after interruption.

## Devices And Layout

- Test a small iPhone.
- Test a large iPhone.
- Test iPad portrait.
- Test iPad landscape.
- Test Dark Mode.
- Test Light Mode.
- Confirm mini player and expanded player do not cover important content.
- Confirm touch targets feel comfortable.

## Performance

- Test a small library under 50 tracks.
- Test a medium library around 500 tracks.
- Test a large library above 2,000 tracks if available.
- Watch memory during scan and playback.
- Watch battery during 30 minutes of background playback.
- Confirm artwork loading does not cause repeated hangs.

## Privacy

- Confirm no Firebase dependency.
- Confirm no analytics framework.
- Confirm no advertising SDK.
- Confirm no account system.
- Confirm no app-initiated network requests for tracking, analytics, ads, or recommendations.
- Confirm App Privacy answers are "Data Not Collected".
- Publish `docs/privacy-policy.md` through the support or GitHub Pages URL.

## App Store Connect

- App name: CloudTape.
- Subtitle: Music from iCloud Drive.
- Primary category: Music.
- Age rating: 4+.
- Price: Free for initial release.
- Add privacy policy URL.
- Add support URL.
- Upload screenshots for required iPhone sizes.
- Add iPad screenshots if iPad is supported.
- Add TestFlight beta notes focused on folder selection, shuffle playback, background playback, and iCloud sync delays.

## TestFlight Notes

Ask testers to verify:

- They can select an iCloud Drive music folder.
- Shuffle starts quickly.
- Background playback continues after locking the phone.
- AirPods and Lock Screen controls work.
- iCloud-only files either play after syncing or fail gracefully.
- The app feels simple and calm.
