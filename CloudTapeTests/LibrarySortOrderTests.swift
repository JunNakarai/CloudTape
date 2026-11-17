import XCTest
@testable import CloudTape

final class LibrarySortOrderTests: XCTestCase {
    func testNewestAndOldestAdditionOrder() {
        let old = track("Old.mp3", date: 10)
        let middle = track("Middle.mp3", date: 20)
        let new = track("New.mp3", date: 30)
        XCTAssertEqual(LibrarySortOrder.newestAdded.sorted([old, new, middle]), [new, middle, old])
        XCTAssertEqual(LibrarySortOrder.oldestAdded.sorted([old, new, middle]), [old, middle, new])
    }

    func testFilenameOrderPreservesNaturalFilenameSortingRegardlessOfMetadata() {
        let two = track("Track 2.mp3", date: 30).withMetadata(title: "Z", artist: nil, album: nil, duration: nil, artworkData: nil)
        let ten = track("Track 10.mp3", date: 10).withMetadata(title: "A", artist: nil, album: nil, duration: nil, artworkData: nil)
        XCTAssertEqual(LibrarySortOrder.filename.sorted([ten, two]), [two, ten])
    }

    func testEqualDatesUseFilenameThenFullPathForDeterministicOrder() {
        let a = track("a/Same.mp3", date: 10)
        let b = track("b/Same.mp3", date: 10)
        let c = track("Track 2.mp3", date: 10)
        let d = track("Track 10.mp3", date: 10)
        for order in LibrarySortOrder.allCases {
            XCTAssertEqual(order.sorted([d, b, c, a]), [a, b, c, d])
        }
    }

    func testUnknownDatesComeLastInEitherDateOrder() {
        let known = track("Z.mp3", date: 10)
        let unknown = track("A.mp3", date: nil)
        XCTAssertEqual(LibrarySortOrder.newestAdded.sorted([unknown, known]), [known, unknown])
        XCTAssertEqual(LibrarySortOrder.oldestAdded.sorted([unknown, known]), [known, unknown])
        XCTAssertEqual(LibrarySortOrder.filename.sorted([known, unknown]), [unknown, known])
    }

    func testEmptyAndSingleTrackLibraries() {
        let only = track("Only.mp3", date: nil)
        for order in LibrarySortOrder.allCases {
            XCTAssertTrue(order.sorted([]).isEmpty)
            XCTAssertEqual(order.sorted([only]), [only])
        }
    }

    @MainActor
    func testFavoritesKeepDateOrderWithinEachGroup() {
        let suite = "CloudTapeSortTests-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let tracks = (1...4).map { track("\($0).mp3", date: Double($0)) }
        let favorites = FavoritesStore(userDefaults: defaults)
        favorites.toggle(tracks[0])
        favorites.toggle(tracks[2])
        XCTAssertEqual(favorites.favoritesFirst(LibrarySortOrder.newestAdded.sorted(tracks)), [tracks[2], tracks[0], tracks[3], tracks[1]])
    }

    func testOrderedPlaybackUsesSortedLibrary() {
        let tracks = [track("A.mp3", date: 10), track("B.mp3", date: 20)]
        let sorted = LibrarySortOrder.newestAdded.sorted(tracks)
        XCTAssertEqual(PlaybackQueueBuilder.queue(for: sorted, startingAt: tracks[1], mode: .ordered), sorted)
    }

    func testSortPreferenceCanBeRestored() {
        let suite = "CloudTapeSortPreferenceTests-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(LibrarySortOrder.oldestAdded.rawValue, forKey: AppSettingsKey.librarySortOrder)
        let restored = UserDefaults(suiteName: suite)!.string(forKey: AppSettingsKey.librarySortOrder)
        XCTAssertEqual(restored.flatMap(LibrarySortOrder.init(rawValue:)), .oldestAdded)
    }

    private func track(_ path: String, date: TimeInterval?) -> Track {
        let root = URL(fileURLWithPath: "/music")
        return Track.from(url: root.appendingPathComponent(path), root: root, dateAdded: date.map(Date.init(timeIntervalSince1970:)))
    }
}
