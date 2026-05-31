import Foundation

enum PlaybackQueueBuilder {
    static func queue(
        for tracks: [Track],
        startingAt track: Track,
        mode: PlaybackMode,
        shuffle: ([Track]) -> [Track] = { $0.shuffled() }
    ) -> [Track] {
        switch mode {
        case .ordered:
            return tracks
        case .shuffled:
            let remaining = tracks.filter { $0 != track }
            return [track] + shuffle(remaining)
        }
    }
}
