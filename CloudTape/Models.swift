import AVFoundation
import Foundation

struct Track: Identifiable, Equatable {
    let id: URL
    let url: URL
    let title: String
    let subtitle: String
    let artist: String?
    let album: String?
    let duration: TimeInterval?

    static func from(url: URL, root: URL) -> Track {
        let relative = url.path.replacingOccurrences(of: root.path + "/", with: "")
        let folder = url.deletingLastPathComponent().lastPathComponent
        return Track(
            id: url,
            url: url,
            title: url.deletingPathExtension().lastPathComponent,
            subtitle: folder.isEmpty ? relative : folder,
            artist: nil,
            album: nil,
            duration: nil
        )
    }

    func withMetadata(title: String?, artist: String?, album: String?, duration: TimeInterval?) -> Track {
        let resolvedTitle = title?.isEmpty == false ? title! : self.title
        let details = [artist, album]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " - ")

        return Track(
            id: id,
            url: url,
            title: resolvedTitle,
            subtitle: details.isEmpty ? subtitle : details,
            artist: artist,
            album: album,
            duration: duration
        )
    }

    static func metadata(for url: URL) async -> (title: String?, artist: String?, album: String?, duration: TimeInterval?) {
        let asset = AVURLAsset(url: url)

        async let metadata = asset.load(.commonMetadata)
        async let duration = asset.load(.duration)

        do {
            let (items, time) = try await (metadata, duration)
            return (
                stringValue(for: .commonIdentifierTitle, in: items),
                stringValue(for: .commonIdentifierArtist, in: items),
                stringValue(for: .commonIdentifierAlbumName, in: items),
                time.seconds.isFinite ? time.seconds : nil
            )
        } catch {
            return (nil, nil, nil, nil)
        }
    }

    private static func stringValue(for identifier: AVMetadataIdentifier, in items: [AVMetadataItem]) -> String? {
        items.first { $0.commonKey?.rawValue == identifier.rawValue || $0.identifier == identifier }?
            .stringValue?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum PlaybackMode {
    case ordered
    case shuffled
}
