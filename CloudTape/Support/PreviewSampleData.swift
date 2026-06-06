import Foundation

#if DEBUG
enum PreviewSampleData {
    static let tracks: [Track] = [
        Track(
            id: URL(fileURLWithPath: "/CloudTape Preview/City Lights.m4a"),
            url: URL(fileURLWithPath: "/CloudTape Preview/City Lights.m4a"),
            title: "City Lights",
            subtitle: "Night Walk - Tape 01",
            artist: "CloudTape",
            album: "Night Walk",
            duration: 181,
            artworkData: nil
        ),
        Track(
            id: URL(fileURLWithPath: "/CloudTape Preview/Weekend Drive.mp3"),
            url: URL(fileURLWithPath: "/CloudTape Preview/Weekend Drive.mp3"),
            title: "Weekend Drive",
            subtitle: "Road Mix - Tape 02",
            artist: "CloudTape",
            album: "Road Mix",
            duration: 244,
            artworkData: nil
        ),
        Track(
            id: URL(fileURLWithPath: "/CloudTape Preview/Rain Notes.wav"),
            url: URL(fileURLWithPath: "/CloudTape Preview/Rain Notes.wav"),
            title: "Rain Notes",
            subtitle: "Room Session - Tape 03",
            artist: "CloudTape",
            album: "Room Session",
            duration: 206,
            artworkData: nil
        )
    ]

    static var currentTrack: Track {
        tracks[0]
    }

    @MainActor
    static func library(state: LibraryState = .ready) -> MusicLibrary {
        let library = MusicLibrary()
        library.loadPreview(tracks: tracks, state: state)
        return library
    }

    @MainActor
    static func player(isPlaying: Bool = true) -> AudioPlayer {
        let player = AudioPlayer(userDefaults: UserDefaults(suiteName: "CloudTapePreview") ?? .standard)
        player.loadPreviewTrack(currentTrack, in: tracks, isPlaying: isPlaying)
        return player
    }
}
#endif
