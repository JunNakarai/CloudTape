import AVFoundation
import MediaPlayer
import SwiftUI

@MainActor
final class AudioPlayer: ObservableObject {
    @Published private(set) var currentTrack: Track?
    @Published private(set) var isPlaying = false
    @Published var mode: PlaybackMode = .ordered

    private var tracks: [Track] = []
    private var queue: [Track] = []
    private var currentIndex = 0
    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    init() {
        setupRemoteCommands()
    }

    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }

    func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session failed: \(error)")
        }
    }

    func play(track: Track, in allTracks: [Track]) {
        tracks = allTracks
        rebuildQueue(startingAt: track)
        playCurrent()
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
        updateNowPlaying()
    }

    func next() {
        guard !queue.isEmpty else { return }
        currentIndex = min(currentIndex + 1, queue.count - 1)
        playCurrent()
    }

    func previous() {
        guard !queue.isEmpty else { return }
        currentIndex = max(currentIndex - 1, 0)
        playCurrent()
    }

    func toggleShuffle() {
        mode = mode == .ordered ? .shuffled : .ordered
        if let currentTrack {
            rebuildQueue(startingAt: currentTrack)
        }
    }

    private func rebuildQueue(startingAt track: Track) {
        switch mode {
        case .ordered:
            queue = tracks
        case .shuffled:
            let remaining = tracks.filter { $0 != track }.shuffled()
            queue = [track] + remaining
        }
        currentIndex = queue.firstIndex(of: track) ?? 0
    }

    private func playCurrent() {
        guard queue.indices.contains(currentIndex) else { return }
        currentTrack = queue[currentIndex]

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }

        let item = AVPlayerItem(url: queue[currentIndex].url)
        player = AVPlayer(playerItem: item)
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.nextAfterFinish() }
        }

        player?.play()
        isPlaying = true
        updateNowPlaying()
    }

    private func nextAfterFinish() {
        guard currentIndex + 1 < queue.count else {
            isPlaying = false
            return
        }
        currentIndex += 1
        playCurrent()
    }

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.togglePlayPause() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.togglePlayPause() }
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.next() }
            return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.previous() }
            return .success
        }
    }

    private func updateNowPlaying() {
        guard let currentTrack else { return }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: currentTrack.title,
            MPMediaItemPropertyAlbumTitle: currentTrack.subtitle,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
    }
}
