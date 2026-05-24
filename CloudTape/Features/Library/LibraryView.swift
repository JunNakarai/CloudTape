import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var player: AudioPlayer
    @AppStorage(AppSettingsKey.restoreLastPlayback) private var restoreLastPlayback = false
    @State private var isImportingFolder = false
    @State private var isSettingsPresented = false
    @State private var isSupportPresented = false
    @State private var isSearchPresented = false
    @State private var searchText = ""
    @State private var isPlayerExpanded = false
    @State private var playerDragTranslation: CGFloat = 0
    @State private var playbackMessage: String?
    @State private var informationMessage: String?
    @State private var didRestoreLastPlayback = false
#if DEBUG
    @State private var didStartDemoPlayback = false
    @State private var didShowDemoSearch = false
#endif

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

                    if player.currentTrack != nil {
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
                .overlay(alignment: .bottomTrailing) {
                    floatingPlaybackButton
                        .padding(.trailing, 24)
                        .padding(.bottom, floatingButtonBottomPadding)
                        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: player.currentTrack?.id)
                }
            }
            .navigationTitle("CloudTape")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: library.tracks) { _, tracks in
                restorePlaybackIfNeeded(from: tracks)
#if DEBUG
                startDemoPlaybackIfNeeded(from: tracks)
                showDemoSearchIfNeeded(from: tracks)
#endif
            }
            .onChange(of: isSearchPresented) { _, isPresented in
                if !isPresented {
                    searchText = ""
                }
            }
            .modifier(LibrarySearchModifier(searchText: $searchText, isPresented: $isSearchPresented))
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        isSearchPresented = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibilityLabel("検索")

                    libraryMenu
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
            .alert("CloudTape", isPresented: Binding(
                get: { informationMessage != nil },
                set: { if !$0 { informationMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(informationMessage ?? "")
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
            .sheet(isPresented: $isSupportPresented) {
                SupportDevelopmentView()
            }
        }
    }

    @ViewBuilder
    private var libraryContent: some View {
        if library.tracks.isEmpty || library.state == .scanning {
            EmptyLibraryView(
                state: library.state,
                chooseFolder: {
                    isImportingFolder = true
                },
                trySampleAudio: playSampleAudio
            )
        } else {
            List {
                if case .syncing(let count) = library.state {
                    syncingRow(count: count)
                }

                if displayedTracks.isEmpty {
                    noSearchResultsRow
                } else {
                    ForEach(displayedTracks) { track in
                        Button {
                            player.play(track: track, in: library.tracks)
                        } label: {
                            TrackRow(track: track, isCurrent: player.currentTrack == track)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .safeAreaPadding(.bottom, contentBottomPadding)
        }
    }

    private var contentBottomPadding: CGFloat {
        player.currentTrack == nil ? 108 : 168
    }

    @ViewBuilder
    private var floatingPlaybackButton: some View {
        if !library.tracks.isEmpty && library.state != .scanning {
            if player.currentTrack == nil {
                floatingActionButton(
                    systemName: "play.fill",
                    size: 64,
                    iconSize: 25,
                    accessibilityLabel: "ランダム再生"
                ) {
                    startRandomPlayback(from: library.tracks)
                }
                .transition(.scale(scale: 0.82, anchor: .bottomTrailing).combined(with: .opacity))
            } else if !isPlayerExpanded {
                floatingActionButton(
                    systemName: "shuffle",
                    size: 52,
                    iconSize: 20,
                    accessibilityLabel: player.mode == .shuffled ? "シャッフルをオフ" : "シャッフルをオン",
                    isActive: player.mode == .shuffled
                ) {
                    player.toggleShuffle()
                }
                .transition(.scale(scale: 0.82, anchor: .bottomTrailing).combined(with: .opacity))
            }
        }
    }

    private var floatingButtonBottomPadding: CGFloat {
        player.currentTrack == nil ? 28 : 112
    }

    private func floatingActionButton(
        systemName: String,
        size: CGFloat,
        iconSize: CGFloat,
        accessibilityLabel: String,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(isActive ? Color.white : Color.black.opacity(0.88))
                .frame(width: size, height: size)
                .background {
                    Circle()
                        .fill(isActive ? Color.accentColor : Color.white.opacity(0.96))
                        .shadow(color: .black.opacity(0.24), radius: 14, x: 0, y: 7)
                        .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 1)
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var libraryMenu: some View {
        Menu {
            Button {
                isImportingFolder = true
            } label: {
                Label("フォルダを追加", systemImage: "folder.badge.plus")
            }

            Divider()

            Button {
                isSupportPresented = true
            } label: {
                Label("開発を応援する", systemImage: "cup.and.saucer")
            }

            Button {
                isSettingsPresented = true
            } label: {
                Label("設定", systemImage: "gearshape")
            }

            Button {
                informationMessage = "CloudTapeは、フォルダ内の音楽をすぐランダム再生できるローカルプレイヤーです。"
            } label: {
                Label("このアプリについて", systemImage: "info.circle")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.headline)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel("ライブラリメニュー")
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

    private var noSearchResultsRow: some View {
        ContentUnavailableView {
            Label("見つかりません", systemImage: "magnifyingglass")
        } description: {
            Text("別のキーワードを試してください。")
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .listRowSeparator(.hidden)
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

    private func restorePlaybackIfNeeded(from tracks: [Track]) {
        guard restoreLastPlayback else { return }
        guard !didRestoreLastPlayback, !tracks.isEmpty else { return }
        didRestoreLastPlayback = true
        player.restoreLastPlayback(in: tracks)
    }

    private func playSampleAudio() {
        guard let url = Bundle.main.url(forResource: "CloudTape-Demo-Audio", withExtension: "m4a") else {
            playbackMessage = "サンプル音源を読み込めませんでした。"
            return
        }

        let track = Track(
            id: url,
            url: url,
            title: "CloudTape Demo Audio",
            subtitle: "App Review Demo",
            artist: "CloudTape",
            album: "App Review Demo",
            duration: 10,
            artworkData: nil
        )
        player.play(track: track, in: [track])
    }

#if DEBUG
    private func startDemoPlaybackIfNeeded(from tracks: [Track]) {
        guard DemoLaunchOptions.current.autoplay else { return }
        guard !didStartDemoPlayback, !tracks.isEmpty else { return }
        guard tracks.contains(where: { $0.artworkData != nil }) else { return }

        didStartDemoPlayback = true
        if startRandomPlayback(from: tracks), DemoLaunchOptions.current.expandPlayer {
            isPlayerExpanded = true
        }
    }

    private func showDemoSearchIfNeeded(from tracks: [Track]) {
        guard DemoLaunchOptions.current.showSearch else { return }
        guard !didShowDemoSearch, !tracks.isEmpty else { return }

        didShowDemoSearch = true
        isSearchPresented = true
        searchText = DemoLaunchOptions.current.searchQuery
    }
#endif
}

private struct LibrarySearchModifier: ViewModifier {
    @Binding var searchText: String
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        if isPresented {
            content.searchable(
                text: $searchText,
                isPresented: $isPresented,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "CloudTapeを検索"
            )
        } else {
            content
        }
    }
}
