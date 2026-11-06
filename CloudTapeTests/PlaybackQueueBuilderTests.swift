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

    func testEmptyLibraryProducesNoQueue() {
        XCTAssertTrue(PlaybackQueueBuilder.queue(for: [], startingAt: makeTracks(count: 1)[0], mode: .shuffled).isEmpty)
    }

    func testFavoritesAreShuffledBeforeOtherTracks() {
        let tracks = makeTracks(count: 20)
        let favorites = Set(tracks.prefix(10).map { $0.url.standardizedFileURL.path })
        let queue = PlaybackQueueBuilder.queue(
            for: tracks, startingAt: tracks[3], mode: .shuffled,
            favoritePaths: favorites, shuffle: { $0.reversed() }
        )
        XCTAssertEqual(queue.first, tracks[3])
        XCTAssertTrue(queue.prefix(10).allSatisfy { favorites.contains($0.url.path) })
        XCTAssertTrue(queue.dropFirst(10).allSatisfy { !favorites.contains($0.url.path) })
        XCTAssertEqual(queue.count, tracks.count)
        XCTAssertEqual(Set(queue.map(\.id)), Set(tracks.map(\.id)))
    }

    func testAllFavoriteAndNoFavoriteQueuesContainEveryTrackOnce() {
        let tracks = makeTracks(count: 5)
        for favorites: Set<String> in [[], Set(tracks.map { $0.url.path })] {
            let queue = PlaybackQueueBuilder.queue(
                for: tracks, startingAt: tracks[2], mode: .shuffled,
                favoritePaths: favorites, shuffle: { $0.reversed() }
            )
            XCTAssertEqual(queue.count, tracks.count)
            XCTAssertEqual(Set(queue.map(\.id)), Set(tracks.map(\.id)))
        }
    }

    func testExplicitNonFavoriteSelectionRemainsFirst() {
        let tracks = makeTracks(count: 4)
        let queue = PlaybackQueueBuilder.queue(
            for: tracks, startingAt: tracks[3], mode: .shuffled,
            favoritePaths: Set([tracks[1].url.path]), shuffle: { $0 }
        )
        XCTAssertEqual(queue, [tracks[3], tracks[1], tracks[0], tracks[2]])
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
