import Foundation

enum PlaybackQueueBuilder {
    static func queue(
        for tracks: [Track],
        startingAt track: Track,
        mode: PlaybackMode,
        favoritePaths: Set<String> = [],
        shuffle: ([Track]) -> [Track] = { $0.shuffled() }
    ) -> [Track] {
        guard !tracks.isEmpty else { return [] }
        switch mode {
        case .ordered:
            return tracks
        case .shuffled:
            let remaining = tracks.filter { $0 != track }
            return [track] + shuffle(remaining.filter { favoritePaths.contains($0.url.standardizedFileURL.path) })
                + shuffle(remaining.filter { !favoritePaths.contains($0.url.standardizedFileURL.path) })
        }
    }
}
