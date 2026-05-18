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
    let artworkData: Data?

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
            duration: nil,
            artworkData: nil
        )
    }

    func withMetadata(
        title: String?,
        artist: String?,
        album: String?,
        duration: TimeInterval?,
        artworkData: Data?
    ) -> Track {
        let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTitle = trimmedTitle?.isEmpty == false ? trimmedTitle ?? self.title : self.title
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
            duration: duration,
            artworkData: artworkData ?? self.artworkData
        )
    }

    static func metadata(
        for url: URL
    ) async -> (title: String?, artist: String?, album: String?, duration: TimeInterval?, artworkData: Data?) {
        let asset = AVURLAsset(url: url)

        async let metadata = asset.load(.commonMetadata)
        async let duration = asset.load(.duration)

        do {
            let (items, time) = try await (metadata, duration)
            let title = await stringValue(for: .commonIdentifierTitle, commonKey: .commonKeyTitle, in: items)
            let artist = await stringValue(for: .commonIdentifierArtist, commonKey: .commonKeyArtist, in: items)
            let album = await stringValue(for: .commonIdentifierAlbumName, commonKey: .commonKeyAlbumName, in: items)
            let artworkData = await dataValue(for: .commonIdentifierArtwork, commonKey: .commonKeyArtwork, in: items)
            return (
                title,
                artist,
                album,
                time.seconds.isFinite ? time.seconds : nil,
                artworkData
            )
        } catch {
            return (nil, nil, nil, nil, nil)
        }
    }

    private static func stringValue(
        for identifier: AVMetadataIdentifier,
        commonKey: AVMetadataKey,
        in items: [AVMetadataItem]
    ) async -> String? {
        guard let item = items.first(where: { $0.identifier == identifier || $0.commonKey == commonKey }) else {
            return nil
        }
        let value = try? await item.load(.stringValue)
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func dataValue(
        for identifier: AVMetadataIdentifier,
        commonKey: AVMetadataKey,
        in items: [AVMetadataItem]
    ) async -> Data? {
        guard let item = items.first(where: { $0.identifier == identifier || $0.commonKey == commonKey }) else {
            return nil
        }
        return try? await item.load(.dataValue)
    }
}

enum PlaybackMode {
    case ordered
    case shuffled
}
