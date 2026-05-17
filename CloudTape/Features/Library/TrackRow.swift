import SwiftUI

struct TrackRow: View {
    let track: Track
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 12) {
            ArtworkThumbnail(track: track, isCurrent: isCurrent, size: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                HStack {
                    Text(track.subtitle)
                        .lineLimit(1)
                    Spacer()
                    if let duration = track.duration, duration > 0 {
                        Text(formatTime(duration))
                            .monospacedDigit()
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
