import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct LibraryView: View {
    @EnvironmentObject private var library: MusicLibrary
    @EnvironmentObject private var player: AudioPlayer
    @State private var isImportingFolder = false
    @State private var isSearching = false
    @State private var isPlayerExpanded = false
    @State private var playerDragTranslation: CGFloat = 0

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

    @ViewBuilder
    private var libraryContent: some View {
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
    let isExpanded: Bool
    let expansionProgress: CGFloat
    let maximumExpandedHeight: CGFloat
    let toggleExpanded: () -> Void

    var body: some View {
        VStack(spacing: isExpanded ? 20 : 10) {
            dragHandle

            if isExpanded {
                expandedContent
            } else {
                collapsedContent
            }
        }
        .tint(.white)
        .padding(.horizontal, 16)
        .padding(.top, 9)
        .padding(.bottom, isExpanded ? 22 : 12)
        .frame(maxWidth: .infinity)
        .frame(height: isExpanded ? min(maximumExpandedHeight, 620) : nil)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12 + 0.04 * expansionProgress),
                                    Color.black.opacity(0.24 + 0.06 * expansionProgress),
                                    Color.black.opacity(0.46 + 0.12 * expansionProgress)
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
        .accessibilityElement(children: .contain)
        .accessibilityHint("上下にドラッグしてプレイヤーを開閉できます")
    }

    private var sliderUpperBound: TimeInterval {
        guard player.duration.isFinite, player.duration > 0 else { return 1 }
        return player.duration
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color.white.opacity(0.32))
            .frame(width: 38, height: 4)
            .padding(.bottom, isExpanded ? 4 : 0)
            .contentShape(Rectangle())
            .onTapGesture(perform: toggleExpanded)
            .accessibilityHidden(true)
    }

    private var collapsedContent: some View {
        VStack(spacing: 10) {
            progressSlider

            HStack(spacing: 14) {
                if let currentTrack = player.currentTrack {
                    ArtworkThumbnail(track: currentTrack, isCurrent: player.isPlaying, size: 44)
                }

                trackText

                Spacer()

                transportControls(playButtonSize: 36, spacing: 14)
            }
        }
    }

    private var expandedContent: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 0)

            if let currentTrack = player.currentTrack {
                ArtworkThumbnail(track: currentTrack, isCurrent: player.isPlaying, size: 230)
                    .shadow(color: .black.opacity(0.28), radius: 20, x: 0, y: 12)
            }

            VStack(spacing: 6) {
                Text(player.currentTrack?.title ?? "未再生")
                    .font(.title3.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text(player.currentTrack?.subtitle ?? "曲を選択してください")
                    .font(.subheadline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.68))
            }
            .frame(maxWidth: .infinity)

            progressSlider

            transportControls(playButtonSize: 58, spacing: 36)

            Spacer(minLength: 0)
        }
    }

    private var progressSlider: some View {
        Group {
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
        }
    }

    private var trackText: some View {
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
    }

    private func transportControls(playButtonSize: CGFloat, spacing: CGFloat) -> some View {
        HStack(spacing: spacing) {
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
                    .font(.system(size: playButtonSize))
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
