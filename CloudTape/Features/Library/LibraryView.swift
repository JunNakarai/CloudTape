import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var player: AudioPlayer
    @State private var isImportingFolder = false
    @State private var isSearching = false
    @State private var isPlayerExpanded = false
    @State private var playerDragTranslation: CGFloat = 0
    @State private var playbackMessage: String?

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    libraryContent
                        .blur(radius: 8 * playerExpansionProgress)

                    Color.black
                        .opacity(0.18 * playerExpansionProgress)
                        .ignoresSafeArea()
                        .allowsHitTesting(isPlayerExpanded)

                    PlayerBar(
                        isExpanded: isPlayerExpanded,
                        expansionProgress: playerExpansionProgress,
                        maximumExpandedHeight: max(420, geometry.size.height - 110),
                        toggleExpanded: togglePlayerExpansion
                    )
                    .environmentObject(player)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .offset(y: playerCardOffset)
                    .scaleEffect(playerCardScale, anchor: .bottom)
                    .simultaneousGesture(playerDragGesture)
                    .animation(.spring(response: 0.42, dampingFraction: 0.84), value: isPlayerExpanded)
                    .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.86), value: playerDragTranslation)
                    .accessibilityAction(named: Text(isPlayerExpanded ? "ミニプレイヤーに戻す" : "フルプレイヤーを表示")) {
                        togglePlayerExpansion()
                    }
                }
            }
            .navigationTitle("CloudTape")
            .onChange(of: library.tracks) { _, tracks in
                player.restoreLastPlayback(in: tracks)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        startRandomPlayback(from: library.tracks)
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.headline)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .accessibilityLabel("ランダム再生")
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
                    },
                    playRandom: { tracks in
                        startRandomPlayback(from: tracks)
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
            .alert("再生できません", isPresented: Binding(
                get: { playbackMessage != nil || player.errorMessage != nil },
                set: {
                    if !$0 {
                        playbackMessage = nil
                        player.errorMessage = nil
                    }
                }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(playbackMessage ?? player.errorMessage ?? "")
            }
        }
    }

    @ViewBuilder
    private var libraryContent: some View {
        if library.tracks.isEmpty || library.state == .scanning {
            EmptyLibraryView(state: library.state) {
                isImportingFolder = true
            }
        } else {
            List {
                if case .syncing(let count) = library.state {
                    syncingRow(count: count)
                }

                ForEach(library.tracks) { track in
                    Button {
                        player.play(track: track, in: library.tracks)
                    } label: {
                        TrackRow(track: track, isCurrent: player.currentTrack == track)
                    }
                }
            }
            .listStyle(.plain)
            .safeAreaPadding(.bottom, 132)
        }
    }

    private func syncingRow(count: Int) -> some View {
        Label {
            Text("\(count)曲をiCloudから同期中")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: "icloud.and.arrow.down")
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
    }

    private var playerExpansionProgress: CGFloat {
        let distance: CGFloat = 220
        if isPlayerExpanded {
            return 1 - min(max(playerDragTranslation / distance, 0), 1)
        }
        return min(max(-playerDragTranslation / distance, 0), 1)
    }

    private var playerCardOffset: CGFloat {
        if isPlayerExpanded {
            return max(playerDragTranslation, 0)
        }
        return min(playerDragTranslation * 0.32, 0)
    }

    private var playerCardScale: CGFloat {
        if isPlayerExpanded {
            return 1 - min(max(playerDragTranslation / 620, 0), 0.045)
        }
        return 1 + playerExpansionProgress * 0.018
    }

    private var playerDragGesture: some Gesture {
        DragGesture(minimumDistance: 18)
            .onChanged { value in
                guard player.currentTrack != nil else { return }
                guard isMostlyVertical(value) else { return }
                playerDragTranslation = value.translation.height
            }
            .onEnded { value in
                guard player.currentTrack != nil else { return }
                defer {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                        playerDragTranslation = 0
                    }
                }
                guard isMostlyVertical(value) else { return }

                let translation = value.translation.height
                let predicted = value.predictedEndTranslation.height
                withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                    if isPlayerExpanded {
                        if translation > 90 || predicted > 190 {
                            isPlayerExpanded = false
                        }
                    } else if translation < -80 || predicted < -170 {
                        isPlayerExpanded = true
                    }
                }
            }
    }

    private func isMostlyVertical(_ value: DragGesture.Value) -> Bool {
        abs(value.translation.height) > abs(value.translation.width) * 1.25
    }

    private func togglePlayerExpansion() {
        guard player.currentTrack != nil else { return }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            isPlayerExpanded.toggle()
            playerDragTranslation = 0
        }
    }

    @discardableResult
    private func startRandomPlayback(from tracks: [Track]) -> Bool {
        guard player.playRandom(in: tracks) else {
            playbackMessage = "再生できる曲がありません。"
            return false
        }
        return true
    }
}
