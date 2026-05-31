import XCTest
@testable import CloudTape

final class PlaybackQueueBuilderTests: XCTestCase {
    func testOrderedQueuePreservesLibraryOrder() {
        let tracks = makeTracks(count: 3)

        let queue = PlaybackQueueBuilder.queue(
            for: tracks,
            startingAt: tracks[1],
            mode: .ordered
        )

        XCTAssertEqual(queue, tracks)
    }

    func testShuffledQueueKeepsSelectedTrackFirstAndShufflesRemainingTracks() {
        let tracks = makeTracks(count: 4)

        let queue = PlaybackQueueBuilder.queue(
            for: tracks,
            startingAt: tracks[2],
            mode: .shuffled,
            shuffle: { $0.reversed() }
        )

        XCTAssertEqual(queue.first, tracks[2])
        XCTAssertEqual(queue.dropFirst(), [tracks[3], tracks[1], tracks[0]])
        XCTAssertEqual(Set(queue.map(\.id)), Set(tracks.map(\.id)))
    }

    private func makeTracks(count: Int) -> [Track] {
        (0..<count).map { index in
            let url = URL(fileURLWithPath: "/tmp/CloudTape/Track-\(index).mp3")
            return Track(
                id: url,
                url: url,
                title: "Track \(index)",
                subtitle: "CloudTape",
                artist: nil,
                album: nil,
                duration: nil,
                artworkData: nil
            )
        }
    }
}
