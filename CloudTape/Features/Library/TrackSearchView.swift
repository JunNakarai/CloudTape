import SwiftUI

struct TrackSearchView: View {
    let tracks: [Track]
    let currentTrack: Track?
    let initialSearchText: String
    let close: () -> Void
    let play: (Track) -> Void
    let playRandom: ([Track]) -> Bool

    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button {
                        let source = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? tracks : filteredTracks
                        if playRandom(source) {
                            close()
                        }
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .accessibilityLabel("ランダム再生")

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
                if searchText.isEmpty {
                    searchText = initialSearchText
                }
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
