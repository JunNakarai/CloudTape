# CloudTape App Review Demo Audio

This folder contains a synthetic demo audio file for Apple App Review:

- `CloudTape-Demo-Audio.m4a`

The file is a locally generated 10-second confirmation tone. It does not contain third-party music, commercial music, downloaded music, or copyrighted source material.

## App Review Usage

1. Download or save `CloudTape-Demo-Audio.m4a` to the Files app, preferably in iCloud Drive.
2. Launch CloudTape.
3. Tap the folder button and select the folder containing `CloudTape-Demo-Audio.m4a`.
4. Select the demo audio file to verify playback.
5. Mini player, lock screen controls, and background playback can be verified after playback starts.

CloudTape does not require an account.

## Rebuild

From the repository root:

```sh
ffmpeg -y -f lavfi -i sine=frequency=880:duration=10 -af afade=t=in:st=0:d=0.2,afade=t=out:st=9.6:d=0.4 -c:a aac -b:a 128k -metadata title="CloudTape Demo Audio" -metadata artist="CloudTape" -metadata album="App Review Demo" docs/review-assets/CloudTape-Demo-Audio.m4a
```
