import Combine
import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var paths: Set<String>
    private let defaults: UserDefaults
    static let storageKey = "favoriteTrackPaths"

    init(userDefaults: UserDefaults = .standard) {
        defaults = userDefaults
        paths = Set(userDefaults.stringArray(forKey: Self.storageKey) ?? [])
    }

    func contains(_ track: Track) -> Bool {
        paths.contains(track.url.standardizedFileURL.path)
    }

    func toggle(_ track: Track) {
        let path = track.url.standardizedFileURL.path
        if !paths.insert(path).inserted { paths.remove(path) }
        defaults.set(paths.sorted(), forKey: Self.storageKey)
    }

    func favoritesFirst(_ tracks: [Track]) -> [Track] {
        tracks.filter(contains) + tracks.filter { !contains($0) }
    }
}
