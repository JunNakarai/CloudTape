import Foundation

struct TrackFileDates {
    let directoryAdditionDate: Date?
    let creationDate: Date?

    var preferredAdditionDate: Date? {
        directoryAdditionDate ?? creationDate
    }

    static func read(from url: URL) -> TrackFileDates {
        // Query independently: providers can support creation dates but reject addition dates.
        let added = try? url.resourceValues(forKeys: [.addedToDirectoryDateKey]).addedToDirectoryDate
        let created = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
        return TrackFileDates(directoryAdditionDate: added, creationDate: created)
    }
}
