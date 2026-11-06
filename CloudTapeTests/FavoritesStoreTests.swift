import XCTest
@testable import CloudTape

@MainActor
final class FavoritesStoreTests: XCTestCase {
    func testPersistenceRemovalAndStableDisplayOrder() {
        let suite = "CloudTapeFavoritesTests-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let tracks = (0..<4).map { Track.from(url: URL(fileURLWithPath: "/music/\($0).mp3"), root: URL(fileURLWithPath: "/music")) }
        let store = FavoritesStore(userDefaults: defaults)
        XCTAssertEqual(store.favoritesFirst(tracks), tracks)
        store.toggle(tracks[2])
        store.toggle(tracks[0])
        let restored = FavoritesStore(userDefaults: defaults)
        XCTAssertTrue(restored.contains(tracks[2]))
        XCTAssertEqual(restored.favoritesFirst(tracks), [tracks[0], tracks[2], tracks[1], tracks[3]])
        restored.toggle(tracks[2])
        XCTAssertFalse(FavoritesStore(userDefaults: defaults).contains(tracks[2]))
    }
}
