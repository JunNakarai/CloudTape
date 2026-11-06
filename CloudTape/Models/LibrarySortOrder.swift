import Foundation

enum LibrarySortOrder: String, CaseIterable, Identifiable {
    case filename
    case newestAdded
    case oldestAdded

    var id: String { rawValue }

    var title: String {
        switch self {
        case .filename: return "ファイル名順"
        case .newestAdded: return "追加日時（新しい順）"
        case .oldestAdded: return "追加日時（古い順）"
        }
    }

    func sorted(_ tracks: [Track]) -> [Track] {
        tracks.sorted { left, right in
            if self != .filename, left.dateAdded != right.dateAdded {
                switch (left.dateAdded, right.dateAdded) {
                case let (leftDate?, rightDate?):
                    return self == .newestAdded ? leftDate > rightDate : leftDate < rightDate
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): break
                }
            }
            let filenameOrder = left.url.lastPathComponent.localizedStandardCompare(right.url.lastPathComponent)
            if filenameOrder != .orderedSame {
                return filenameOrder == .orderedAscending
            }
            return left.url.standardizedFileURL.path < right.url.standardizedFileURL.path
        }
    }
}
