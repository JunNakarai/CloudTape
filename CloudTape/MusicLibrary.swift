import Foundation
import UniformTypeIdentifiers

@MainActor
final class MusicLibrary: ObservableObject {
    @Published private(set) var folderURL: URL?
    @Published private(set) var tracks: [Track] = []
    @Published var errorMessage: String?

    private let bookmarkKey = "selectedMusicFolderBookmark"
    private var accessedFolderURL: URL?
    private let supportedExtensions: Set<String> = [
        "mp3", "m4a", "aac", "alac", "flac", "wav", "aiff", "aif", "m4b"
    ]

    deinit {
        accessedFolderURL?.stopAccessingSecurityScopedResource()
    }

    func restoreLastFolder() {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return }

        do {
            var stale = false
            let url = try URL(
                resolvingBookmarkData: data,
                options: [],
                relativeTo: nil,
                bookmarkDataIsStale: &stale
            )
            if stale {
                saveBookmark(for: url)
            }
            loadFolder(url)
        } catch {
            errorMessage = "前回のフォルダを開けませんでした。もう一度選択してください。"
        }
    }

    func loadFolder(_ url: URL) {
        let didAccess = url.startAccessingSecurityScopedResource()

        do {
            if didAccess {
                accessedFolderURL?.stopAccessingSecurityScopedResource()
                accessedFolderURL = url
            }
            saveBookmark(for: url)
            let urls = try audioFiles(in: url)
            folderURL = url
            tracks = urls.map { Track.from(url: $0, root: url) }
            errorMessage = tracks.isEmpty ? "このフォルダに対応音声ファイルが見つかりませんでした。" : nil
            enrichMetadata()
        } catch {
            errorMessage = "フォルダを読み込めませんでした: \(error.localizedDescription)"
        }
    }

    private func enrichMetadata() {
        let currentTracks = tracks
        Task {
            var enriched: [Track] = []
            for track in currentTracks {
                let metadata = await Track.metadata(for: track.url)
                enriched.append(track.withMetadata(
                    title: metadata.title,
                    artist: metadata.artist,
                    album: metadata.album,
                    duration: metadata.duration,
                    artworkData: metadata.artworkData
                ))
            }

            guard folderURL != nil else { return }
            tracks = enriched
        }
    }

    private func audioFiles(in folder: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: folder,
            includingPropertiesForKeys: [
                .isRegularFileKey,
                .isUbiquitousItemKey,
                .localizedNameKey,
                .ubiquitousItemDownloadingStatusKey
            ],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var urls: [URL] = []
        for case let fileURL as URL in enumerator {
            let resource = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            guard resource.isRegularFile == true else { continue }
            guard supportedExtensions.contains(fileURL.pathExtension.lowercased()) else { continue }
            requestDownloadIfNeeded(fileURL)
            urls.append(fileURL)
        }

        return urls.sorted {
            $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
        }
    }

    private func saveBookmark(for url: URL) {
        do {
            let data = try url.bookmarkData(
                options: [],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(data, forKey: bookmarkKey)
        } catch {
            errorMessage = "フォルダ権限を保存できませんでした。"
        }
    }

    private func requestDownloadIfNeeded(_ url: URL) {
        do {
            let values = try url.resourceValues(forKeys: [
                .isUbiquitousItemKey,
                .ubiquitousItemDownloadingStatusKey
            ])
            guard values.isUbiquitousItem == true else { return }
            guard values.ubiquitousItemDownloadingStatus != .current else { return }
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
        } catch {
            print("iCloud download request failed: \(error)")
        }
    }
}
