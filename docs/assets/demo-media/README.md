# CloudTape Demo Media

These files are local demo assets for CloudTape screenshots. They are not commercial music, subscription audio, YouTube audio, or third-party copyrighted music.

## Files

| File | Source URL | License | Author / Creator | Usage note | Date created |
| --- | --- | --- | --- | --- | --- |
| `demo-track-01.mp3` | Local generation; no external source URL | CC0 1.0 Public Domain Dedication | Generated for CloudTape demo screenshots with `ffmpeg` lavfi sine/noise sources | Short synthetic ambient demo track with embedded artwork and metadata | 2026-05-20 |
| `demo-artwork-01.png` | Local generation; no external source URL | CC0 1.0 Public Domain Dedication | Generated for CloudTape demo screenshots with `ffmpeg` color/drawbox filters | Abstract square artwork embedded into `demo-track-01.mp3` | 2026-05-20 |

## Generation Commands

```sh
ffmpeg -hide_banner -y \
  -f lavfi -i "color=c=0x111827:s=1024x1024" \
  -vf "drawbox=x=120:y=120:w=784:h=784:color=0x2563eb@0.88:t=fill,drawbox=x=180:y=180:w=664:h=664:color=0x38bdf8@0.28:t=20,drawbox=x=250:y=610:w=520:h=34:color=0xffffff@0.86:t=fill,drawbox=x=250:y=680:w=350:h=34:color=0xffffff@0.62:t=fill,drawbox=x=646:y=304:w=72:h=360:color=0xffffff@0.88:t=fill,drawbox=x=646:y=304:w=190:h=72:color=0xffffff@0.88:t=fill,drawbox=x=574:y=626:w=144:h=144:color=0xffffff@0.88:t=fill" \
  -frames:v 1 \
  docs/assets/demo-media/demo-artwork-01.png

ffmpeg -hide_banner -y \
  -f lavfi -i "sine=frequency=220:duration=75" \
  -f lavfi -i "sine=frequency=277.18:duration=75" \
  -f lavfi -i "sine=frequency=329.63:duration=75" \
  -f lavfi -i "anoisesrc=color=pink:duration=75:amplitude=0.018" \
  -filter_complex "[0:a]volume=0.12[a0];[1:a]volume=0.09[a1];[2:a]volume=0.07[a2];[3:a]volume=0.32,lowpass=f=1200[a3];[a0][a1][a2][a3]amix=inputs=4:duration=first,afade=t=in:st=0:d=4,afade=t=out:st=70:d=5[a]" \
  -map "[a]" \
  -c:a libmp3lame \
  -q:a 3 \
  /private/tmp/cloudtape-demo-track-01-source.mp3

ffmpeg -hide_banner -y \
  -i /private/tmp/cloudtape-demo-track-01-source.mp3 \
  -i docs/assets/demo-media/demo-artwork-01.png \
  -map 0:a -map 1:v \
  -c copy \
  -id3v2_version 3 \
  -metadata title="Morning Tape" \
  -metadata artist="CloudTape Demo" \
  -metadata album="CloudTape Demo Library" \
  -metadata comment="Original CC0 demo audio generated for CloudTape screenshots" \
  -disposition:v attached_pic \
  docs/assets/demo-media/demo-track-01.mp3
```
