import Foundation

/// Keeps the first known addition date stable across rescans and iCloud downloads.
final class TrackDateAddedStore {
    static let storageKey = "trackDateAddedByPath"
    static let creationDatesStorageKey = "trackCreationDateByPath"
    private let defaults: UserDefaults
    private var dates: [String: Date]
    private var creationDates: [String: Date]

    init(userDefaults: UserDefaults = .standard) {
        defaults = userDefaults
        dates = userDefaults.dictionary(forKey: Self.storageKey) as? [String: Date] ?? [:]
        creationDates = userDefaults.dictionary(forKey: Self.creationDatesStorageKey) as? [String: Date] ?? [:]
    }

    func datesAdded(
        for urls: [URL],
        fileDates: [URL: Date],
        fileCreationDates: [URL: Date] = [:],
        discoveredAt: Date = Date()
    ) -> [URL: Date] {
        var result: [URL: Date] = [:]
        var changed = false
        for url in urls {
            let path = url.standardizedFileURL.path
            let creationDate = fileCreationDates[url]
            let isReplacement = creationDates[path].map { saved in
                creationDate.map { $0 != saved } ?? false
            } ?? false
            if let savedDate = dates[path], !isReplacement {
                result[url] = savedDate
            } else {
                let date = fileDates[url] ?? discoveredAt
                dates[path] = date
                result[url] = date
                changed = true
            }
            if let creationDate, creationDates[path] != creationDate {
                creationDates[path] = creationDate
                changed = true
            }
        }
        if changed {
            defaults.set(dates, forKey: Self.storageKey)
            defaults.set(creationDates, forKey: Self.creationDatesStorageKey)
        }
        return result
    }
}
