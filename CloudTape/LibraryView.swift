import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct LibraryView: View {
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var player: AudioPlayer
    @State private var isImportingFolder = false
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if library.tracks.isEmpty {
                    EmptyLibraryView {
                        isImportingFolder = true
                    }
                } else {
                    List(library.tracks) { track in
                        Button {
                            player.play(track: track, in: library.tracks)
                        } label: {
                            TrackRow(track: track, isCurrent: player.currentTrack == track)
                        }
                    }
                    .listStyle(.plain)
                    .safeAreaPadding(.bottom, 132)
                }

                PlayerBar()
                    .environmentObject(player)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            .navigationTitle("CloudTape")
            .onChange(of: library.tracks) { _, tracks in
                player.restoreLastPlayback(in: tracks)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        player.toggleShuffle()
                    } label: {
                        Image(systemName: player.mode == .shuffled ? "shuffle.circle.fill" : "shuffle")
                    }
                    .disabled(library.tracks.isEmpty)
                    .accessibilityLabel("Shuffle")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        Button {
                            isSearching = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        .disabled(library.tracks.isEmpty)
                        .accessibilityLabel("Search")

                        Button {
                            isImportingFolder = true
                        } label: {
                            Image(systemName: "folder.badge.plus")
                        }
                        .accessibilityLabel("Choose Folder")
                    }
                }
            }
            .fullScreenCover(isPresented: $isSearching) {
                TrackSearchView(
                    tracks: library.tracks,
                    currentTrack: player.currentTrack,
                    close: { isSearching = false },
                    play: { track in
                        player.play(track: track, in: library.tracks)
                    }
                )
            }
            .fileImporter(
                isPresented: $isImportingFolder,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        library.loadFolder(url)
                    }
                case .failure(let error):
                    library.errorMessage = error.localizedDescription
                }
            }
            .alert("読み込みエラー", isPresented: Binding(
                get: { library.errorMessage != nil },
                set: { if !$0 { library.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(library.errorMessage ?? "")
            }
        }
    }
}

private struct TrackSearchView: View {
    let tracks: [Track]
    let currentTrack: Track?
    let close: () -> Void
    let play: (Track) -> Void

    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    TextField("CloudTapeを検索", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isSearchFocused)
                        .submitLabel(.search)

                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .accessibilityLabel("Close Search")
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(.bar)

                if filteredTracks.isEmpty {
                    ContentUnavailableView {
                        Label(emptyTitle, systemImage: "magnifyingglass")
                    } description: {
                        Text(emptyDescription)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredTracks) { track in
                        Button {
                            play(track)
                            close()
                        } label: {
                            TrackRow(track: track, isCurrent: currentTrack == track)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                isSearchFocused = true
            }
        }
    }

    private var filteredTracks: [Track] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        return tracks.filter { track in
            track.title.localizedCaseInsensitiveContains(query)
                || track.subtitle.localizedCaseInsensitiveContains(query)
                || track.artist?.localizedCaseInsensitiveContains(query) == true
                || track.album?.localizedCaseInsensitiveContains(query) == true
        }
    }

    private var emptyTitle: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "検索してみましょう" : "見つかりません"
    }

    private var emptyDescription: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "曲名、アーティスト、アルバムを検索できます。"
            : "別のキーワードを試してください。"
    }
}

private struct EmptyLibraryView: View {
    let chooseFolder: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("音楽フォルダを選択", systemImage: "music.note.list")
        } description: {
            Text("iCloud DriveまたはFiles内のフォルダを選ぶと、対応する音声ファイルを一覧化します。")
        } actions: {
            Button("フォルダを選ぶ", action: chooseFolder)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TrackRow: View {
    let track: Track
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 12) {
            ArtworkThumbnail(track: track, isCurrent: isCurrent, size: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                HStack {
                    Text(track.subtitle)
                        .lineLimit(1)
                    Spacer()
                    if let duration = track.duration, duration > 0 {
                        Text(formatTime(duration))
                            .monospacedDigit()
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct PlayerBar: View {
    @EnvironmentObject private var player: AudioPlayer

    var body: some View {
        VStack(spacing: 10) {
            if player.currentTrack != nil {
                VStack(spacing: 4) {
                    Slider(
                        value: Binding(
                            get: { min(player.currentTime, sliderUpperBound) },
                            set: { player.seek(to: $0) }
                        ),
                        in: 0...sliderUpperBound
                    )
                    HStack {
                        Text(formatTime(player.currentTime))
                        Spacer()
                        Text(formatTime(player.duration))
                    }
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.72))
                }
            }
            HStack(spacing: 14) {
                if let currentTrack = player.currentTrack {
                    ArtworkThumbnail(track: currentTrack, isCurrent: player.isPlaying, size: 44)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(player.currentTrack?.title ?? "未再生")
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                    Text(player.currentTrack?.subtitle ?? "曲を選択してください")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    player.previous()
                } label: {
                    Image(systemName: "backward.fill")
                }
                .disabled(player.currentTrack == nil)

                Button {
                    player.togglePlayPause()
                } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                }
                .disabled(player.currentTrack == nil)

                Button {
                    player.next()
                } label: {
                    Image(systemName: "forward.fill")
                }
                .disabled(player.currentTrack == nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
        }
        .tint(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.black.opacity(0.24),
                                    Color.black.opacity(0.46)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.8)
        }
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.28),
                            Color.white.opacity(0.06),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 30)
                .blendMode(.screen)
                .allowsHitTesting(false)
        }
        .shadow(color: .black.opacity(0.30), radius: 24, x: 0, y: 14)
        .shadow(color: .black.opacity(0.16), radius: 4, x: 0, y: 2)
    }

    private var sliderUpperBound: TimeInterval {
        guard player.duration.isFinite, player.duration > 0 else { return 1 }
        return player.duration
    }
}

private struct ArtworkThumbnail: View {
    let track: Track
    let isCurrent: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            if let artworkData = track.artworkData, let image = UIImage(data: artworkData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.tertiarySystemFill))
                Image(systemName: isCurrent ? "speaker.wave.2.fill" : "music.note")
                    .foregroundStyle(isCurrent ? .blue : .secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color(.separator).opacity(0.35), lineWidth: 0.5)
        }
        .accessibilityHidden(true)
    }
}

private func formatTime(_ seconds: TimeInterval) -> String {
    guard seconds.isFinite, seconds > 0 else { return "0:00" }
    let total = Int(seconds.rounded())
    let minutes = total / 60
    let seconds = total % 60
    return "\(minutes):\(String(format: "%02d", seconds))"
}
