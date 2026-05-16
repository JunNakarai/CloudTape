import Foundation

struct Track: Identifiable, Equatable {
    let id: URL
    let url: URL
    let title: String
    let subtitle: String

    static func from(url: URL, root: URL) -> Track {
        let relative = url.path.replacingOccurrences(of: root.path + "/", with: "")
        let folder = url.deletingLastPathComponent().lastPathComponent
        return Track(
            id: url,
            url: url,
            title: url.deletingPathExtension().lastPathComponent,
            subtitle: folder.isEmpty ? relative : folder
        )
    }
}

enum PlaybackMode {
    case ordered
    case shuffled
}
