import Foundation
import UniformTypeIdentifiers

@MainActor
final class MusicLibrary: ObservableObject {
    @Published private(set) var folderURL: URL?
    @Published private(set) var tracks: [Track] = []
    @Published private(set) var state: LibraryState = .noFolder
    @Published private(set) var pendingDownloadCount = 0
    @Published var errorMessage: String?

    private let bookmarkKey = "selectedMusicFolderBookmark"
    private var accessedFolderURL: URL?
    private var scanTask: Task<Void, Never>?
    private let supportedExtensions: Set<String> = [
        "mp3", "m4a", "aac", "alac", "flac", "wav", "aiff", "aif", "m4b"
    ]

    deinit {
        scanTask?.cancel()
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
            updateError("前回のフォルダを開けませんでした。もう一度選択してください。")
        }
    }

    func loadFolder(_ url: URL) {
        let didAccess = url.startAccessingSecurityScopedResource()
        scanTask?.cancel()
        state = .scanning
        errorMessage = nil
        folderURL = url
        tracks = []
        pendingDownloadCount = 0

        if didAccess {
            accessedFolderURL?.stopAccessingSecurityScopedResource()
            accessedFolderURL = url
        }

        saveBookmark(for: url)

        scanTask = Task {
            do {
                let extensions = supportedExtensions
                let scan = try await Task.detached(priority: .userInitiated) {
                    try Self.audioFiles(in: url, supportedExtensions: extensions)
                }.value
                guard !Task.isCancelled, folderURL == url else { return }

                tracks = scan.urls.map { Track.from(url: $0, root: url) }
                pendingDownloadCount = scan.pendingDownloadCount
                state = resolvedState(trackCount: tracks.count, pendingCount: scan.pendingDownloadCount)
                enrichMetadata()
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled, folderURL == url else { return }
                updateError("フォルダを読み込めませんでした: \(error.localizedDescription)")
            }
        }
    }

    private func enrichMetadata() {
        let currentTracks = tracks
        let currentFolderURL = folderURL
        Task {
            let enrichedTracks = await Self.enrichedTracks(for: currentTracks)

            guard folderURL == currentFolderURL else { return }
            tracks = enrichedTracks
        }
    }

    nonisolated private static func enrichedTracks(for tracks: [Track]) async -> [Track] {
        var enriched: [Track] = []
        for track in tracks {
            let metadata = await Track.metadata(for: track.url)
            enriched.append(track.withMetadata(
                title: metadata.title,
                artist: metadata.artist,
                album: metadata.album,
                duration: metadata.duration,
                artworkData: metadata.artworkData
            ))
        }
        return enriched
    }

    nonisolated private static func audioFiles(
        in folder: URL,
        supportedExtensions: Set<String>
    ) throws -> (urls: [URL], pendingDownloadCount: Int) {
        try Task.checkCancellation()
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
            return ([], 0)
        }

        var urls: [URL] = []
        var pendingDownloadCount = 0
        for case let fileURL as URL in enumerator {
            try Task.checkCancellation()
            let resource = try fileURL.resourceValues(forKeys: [
                .isRegularFileKey,
                .isUbiquitousItemKey,
                .ubiquitousItemDownloadingStatusKey
            ])
            guard resource.isRegularFile == true else { continue }
            guard supportedExtensions.contains(fileURL.pathExtension.lowercased()) else { continue }
            if requestDownloadIfNeeded(fileURL, resourceValues: resource) {
                pendingDownloadCount += 1
            }
            urls.append(fileURL)
        }

        return (urls.sorted {
            $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
        }, pendingDownloadCount)
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
            updateError("フォルダ権限を保存できませんでした。")
        }
    }

    nonisolated private static func requestDownloadIfNeeded(_ url: URL, resourceValues values: URLResourceValues) -> Bool {
        do {
            guard values.isUbiquitousItem == true else { return false }
            guard values.ubiquitousItemDownloadingStatus != .current else { return false }
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
            return true
        } catch {
            return false
        }
    }

    private func resolvedState(trackCount: Int, pendingCount: Int) -> LibraryState {
        if trackCount == 0 {
            return .emptyFolder
        }
        if pendingCount > 0 {
            return .syncing(pendingCount)
        }
        return .ready
    }

    private func updateError(_ message: String) {
        errorMessage = message
        state = .error(message)
    }
}

enum LibraryState: Equatable {
    case noFolder
    case scanning
    case ready
    case emptyFolder
    case syncing(Int)
    case error(String)
}
