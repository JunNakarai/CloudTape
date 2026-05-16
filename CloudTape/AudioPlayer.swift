import AVFoundation
import MediaPlayer
import SwiftUI

@MainActor
final class AudioPlayer: ObservableObject {
    @Published private(set) var currentTrack: Track?
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var mode: PlaybackMode = .ordered

    private var tracks: [Track] = []
    private var queue: [Track] = []
    private var currentIndex = 0
    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?
    private var timeObserver: Any?
    private let lastTrackPathKey = "lastTrackPath"
    private let lastPlaybackPositionKey = "lastPlaybackPosition"

    init() {
        setupRemoteCommands()
    }

    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
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
        playCurrent(autoPlay: true)
    }

    func restoreLastPlayback(in allTracks: [Track]) {
        guard currentTrack == nil else { return }
        guard let path = UserDefaults.standard.string(forKey: lastTrackPathKey) else { return }
        guard let track = allTracks.first(where: { $0.url.path == path }) else { return }

        tracks = allTracks
        rebuildQueue(startingAt: track)
        playCurrent(autoPlay: false)
        seek(to: UserDefaults.standard.double(forKey: lastPlaybackPositionKey))
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

    func seek(to seconds: TimeInterval) {
        guard let player else { return }
        let safeSeconds = sanitizedTime(seconds)
        let target = CMTime(seconds: safeSeconds, preferredTimescale: 600)
        player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = safeSeconds
                self?.savePlaybackState()
                self?.updateNowPlaying()
            }
        }
    }

    func next() {
        guard !queue.isEmpty else { return }
        currentIndex = min(currentIndex + 1, queue.count - 1)
        playCurrent(autoPlay: true)
    }

    func previous() {
        guard !queue.isEmpty else { return }
        currentIndex = max(currentIndex - 1, 0)
        playCurrent(autoPlay: true)
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

    private func playCurrent(autoPlay: Bool) {
        guard queue.indices.contains(currentIndex) else { return }
        currentTrack = queue[currentIndex]
        savePlaybackState()

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }

        let item = AVPlayerItem(url: queue[currentIndex].url)
        player = AVPlayer(playerItem: item)
        currentTime = 0
        duration = sanitizedDuration(queue[currentIndex].duration)
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.nextAfterFinish() }
        }
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                guard let self else { return }
                self.currentTime = self.sanitizedTime(time.seconds)
                self.duration = self.sanitizedDuration(self.player?.currentItem?.duration.seconds ?? self.duration)
                self.savePlaybackState()
                self.updateNowPlaying()
            }
        }

        if autoPlay {
            player?.play()
        }
        isPlaying = autoPlay
        updateNowPlaying()
    }

    private func nextAfterFinish() {
        guard currentIndex + 1 < queue.count else {
            isPlaying = false
            return
        }
        currentIndex += 1
        playCurrent(autoPlay: true)
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
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor in self?.seek(to: event.positionTime) }
            return .success
        }
    }

    private func updateNowPlaying() {
        guard let currentTrack else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: currentTrack.title,
            MPMediaItemPropertyAlbumTitle: currentTrack.subtitle,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime
        ]
        if duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        if let artist = currentTrack.artist {
            info[MPMediaItemPropertyArtist] = artist
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func savePlaybackState() {
        guard let currentTrack else { return }
        UserDefaults.standard.set(currentTrack.url.path, forKey: lastTrackPathKey)
        UserDefaults.standard.set(currentTime, forKey: lastPlaybackPositionKey)
    }

    private func sanitizedTime(_ seconds: TimeInterval) -> TimeInterval {
        guard seconds.isFinite, seconds > 0 else { return 0 }
        if duration > 0 {
            return min(seconds, duration)
        }
        return seconds
    }

    private func sanitizedDuration(_ seconds: TimeInterval?) -> TimeInterval {
        guard let seconds, seconds.isFinite, seconds > 0 else { return 0 }
        return seconds
    }
}
