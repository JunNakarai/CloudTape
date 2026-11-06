import XCTest
@testable import CloudTape

final class TrackDateAddedStoreTests: XCTestCase {
    func testFileAdditionDatesPersistAndDoNotChangeOnRescan() {
        withDefaults { defaults in
            let url = URL(fileURLWithPath: "/music/A.mp3")
            let original = Date(timeIntervalSince1970: 10)
            let store = TrackDateAddedStore(userDefaults: defaults)
            XCTAssertEqual(store.datesAdded(for: [url], fileDates: [url: original])[url], original)
            let restored = TrackDateAddedStore(userDefaults: defaults)
            XCTAssertEqual(restored.datesAdded(for: [url], fileDates: [url: Date(timeIntervalSince1970: 20)])[url], original)
        }
    }

    func testMissingFileDatesUseStableFirstDiscoveryDate() {
        withDefaults { defaults in
            let urls = [URL(fileURLWithPath: "/music/A.mp3"), URL(fileURLWithPath: "/music/B.mp3")]
            let first = Date(timeIntervalSince1970: 10)
            let store = TrackDateAddedStore(userDefaults: defaults)
            XCTAssertEqual(store.datesAdded(for: urls, fileDates: [:], discoveredAt: first), Dictionary(uniqueKeysWithValues: urls.map { ($0, first) }))
            XCTAssertEqual(TrackDateAddedStore(userDefaults: defaults).datesAdded(for: urls, fileDates: [:], discoveredAt: Date(timeIntervalSince1970: 30))[urls[0]], first)
        }
    }

    func testNewlyDiscoveredTracksDoNotResetExistingTracks() {
        withDefaults { defaults in
            let old = URL(fileURLWithPath: "/music/A.mp3")
            let new = URL(fileURLWithPath: "/music/B.mp3")
            let first = Date(timeIntervalSince1970: 10)
            let next = Date(timeIntervalSince1970: 20)
            let store = TrackDateAddedStore(userDefaults: defaults)
            _ = store.datesAdded(for: [old], fileDates: [:], discoveredAt: first)
            XCTAssertEqual(store.datesAdded(for: [old, new], fileDates: [:], discoveredAt: next), [old: first, new: next])
        }
    }

    func testSameFilenameInDifferentFoldersHasIndependentDate() {
        withDefaults { defaults in
            let first = URL(fileURLWithPath: "/music/a/Same.mp3")
            let second = URL(fileURLWithPath: "/music/b/Same.mp3")
            let store = TrackDateAddedStore(userDefaults: defaults)
            let dates = [first: Date(timeIntervalSince1970: 10), second: Date(timeIntervalSince1970: 20)]
            XCTAssertEqual(store.datesAdded(for: [first, second], fileDates: dates), dates)
            _ = store.datesAdded(for: [], fileDates: [:])
            XCTAssertEqual(TrackDateAddedStore(userDefaults: defaults).datesAdded(for: [first, second], fileDates: [:]), dates)
        }
    }

    func testStandardizedPathsReuseTheSameSavedDate() {
        withDefaults { defaults in
            let first = URL(fileURLWithPath: "/music/album/../A.mp3")
            let normalized = URL(fileURLWithPath: "/music/A.mp3")
            let date = Date(timeIntervalSince1970: 10)
            let store = TrackDateAddedStore(userDefaults: defaults)
            _ = store.datesAdded(for: [first], fileDates: [:], discoveredAt: date)
            XCTAssertEqual(store.datesAdded(for: [normalized], fileDates: [:], discoveredAt: Date(timeIntervalSince1970: 20))[normalized], date)
        }
    }

    func testInvalidStoredValueFallsBackWithoutCrashing() {
        withDefaults { defaults in
            defaults.set("invalid", forKey: TrackDateAddedStore.storageKey)
            let url = URL(fileURLWithPath: "/music/A.mp3")
            let date = Date(timeIntervalSince1970: 10)
            XCTAssertEqual(TrackDateAddedStore(userDefaults: defaults).datesAdded(for: [url], fileDates: [:], discoveredAt: date)[url], date)
        }
    }

    func testReplacementAtSamePathGetsNewAdditionDate() {
        withDefaults { defaults in
            let url = URL(fileURLWithPath: "/music/A.mp3")
            let first = Date(timeIntervalSince1970: 10)
            let next = Date(timeIntervalSince1970: 20)
            let store = TrackDateAddedStore(userDefaults: defaults)
            _ = store.datesAdded(for: [url], fileDates: [url: first], fileCreationDates: [url: first])
            _ = store.datesAdded(for: [], fileDates: [:])
            let restored = TrackDateAddedStore(userDefaults: defaults)
            XCTAssertEqual(restored.datesAdded(for: [url], fileDates: [url: next], fileCreationDates: [url: next])[url], next)
        }
    }

    func testTemporaryMetadataLossOrDownloadDoesNotResetDate() {
        withDefaults { defaults in
            let url = URL(fileURLWithPath: "/music/A.mp3")
            let first = Date(timeIntervalSince1970: 10)
            let later = Date(timeIntervalSince1970: 20)
            let store = TrackDateAddedStore(userDefaults: defaults)
            _ = store.datesAdded(for: [url], fileDates: [url: first], fileCreationDates: [url: first])
            XCTAssertEqual(store.datesAdded(for: [url], fileDates: [:], discoveredAt: later)[url], first)
            XCTAssertEqual(store.datesAdded(for: [url], fileDates: [url: later], fileCreationDates: [url: first])[url], first)
        }
    }

    private func withDefaults(_ body: (UserDefaults) -> Void) {
        let suite = "CloudTapeDateAddedTests-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        body(defaults)
    }
}
