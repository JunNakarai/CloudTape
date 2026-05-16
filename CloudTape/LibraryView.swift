import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var player: AudioPlayer
    @State private var isImportingFolder = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if library.tracks.isEmpty {
                    EmptyLibraryView {
                        isImportingFolder = true
                    }
                } else {
                    List(displayedTracks) { track in
                        Button {
                            player.play(track: track, in: library.tracks)
                        } label: {
                            TrackRow(track: track, isCurrent: player.currentTrack == track)
                        }
                    }
                    .listStyle(.plain)
                }

                PlayerBar()
                    .environmentObject(player)
            }
            .navigationTitle("CloudTape")
            .searchable(text: $searchText, prompt: "曲名、アーティスト、アルバム")
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
                    Button {
                        isImportingFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                    .accessibilityLabel("Choose Folder")
                }
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

    private var displayedTracks: [Track] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return library.tracks }
        return library.tracks.filter { track in
            track.title.localizedCaseInsensitiveContains(query)
                || track.subtitle.localizedCaseInsensitiveContains(query)
                || track.artist?.localizedCaseInsensitiveContains(query) == true
                || track.album?.localizedCaseInsensitiveContains(query) == true
        }
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
            Image(systemName: isCurrent ? "speaker.wave.2.fill" : "music.note")
                .foregroundStyle(isCurrent ? .blue : .secondary)
                .frame(width: 24)

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
            Divider()
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
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
            }
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.currentTrack?.title ?? "未再生")
                        .font(.headline)
                        .lineLimit(1)
                    Text(player.currentTrack?.subtitle ?? "曲を選択してください")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(.bar)
    }

    private var sliderUpperBound: TimeInterval {
        guard player.duration.isFinite, player.duration > 0 else { return 1 }
        return player.duration
    }
}

private func formatTime(_ seconds: TimeInterval) -> String {
    guard seconds.isFinite, seconds > 0 else { return "0:00" }
    let total = Int(seconds.rounded())
    let minutes = total / 60
    let seconds = total % 60
    return "\(minutes):\(String(format: "%02d", seconds))"
}
