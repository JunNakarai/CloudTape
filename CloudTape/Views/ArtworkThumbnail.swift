import SwiftUI
import UIKit

struct ArtworkThumbnail: View {
    let track: Track
    let isCurrent: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            if let artworkData = track.artworkData, let image = UIImage(data: artworkData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.tertiarySystemFill))
                Image(systemName: isCurrent ? "speaker.wave.2.fill" : "music.note")
                    .foregroundStyle(isCurrent ? .blue : .secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color(.separator).opacity(0.35), lineWidth: 0.5)
        }
        .accessibilityHidden(true)
    }
}
