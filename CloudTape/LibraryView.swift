import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var player: AudioPlayer
    @State private var isImportingFolder = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                }

                PlayerBar()
                    .environmentObject(player)
            }
            .navigationTitle("CloudTape")
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
                Text(track.subtitle)
                    .font(.caption)
                    .lineLimit(1)
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
}
