import AVFoundation
import MediaPlayer
import SwiftUI
import UIKit

@MainActor
final class AudioPlayer: ObservableObject {
    @Published private(set) var currentTrack: Track?
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var mode: PlaybackMode

    private var tracks: [Track] = []
    private var queue: [Track] = []
    private var history: [Track] = []
    private var currentIndex = 0
    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?
    private var timeObserver: Any?
    private let userDefaults: UserDefaults
    private let shuffleEnabledKey = "shuffleEnabled"
    private let lastTrackPathKey = "lastTrackPath"
    private let lastPlaybackPositionKey = "lastPlaybackPosition"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let savedShuffle = userDefaults.object(forKey: shuffleEnabledKey) as? Bool {
            mode = savedShuffle ? .shuffled : .ordered
        } else {
            mode = .shuffled
            userDefaults.set(true, forKey: shuffleEnabledKey)
        }
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
        history.removeAll()
        rebuildQueue(startingAt: track)
        playCurrent(autoPlay: true)
    }

    @discardableResult
    func playRandom(in allTracks: [Track]) -> Bool {
        guard !allTracks.isEmpty else { return false }
        tracks = allTracks
        history.removeAll()
        setShuffleEnabled(true)

        guard let track = allTracks.randomElement() else { return false }
        rebuildQueue(startingAt: track)
        playCurrent(autoPlay: true)
        return true
    }

    func restoreLastPlayback(in allTracks: [Track]) {
        guard currentTrack == nil else { return }
        guard let path = userDefaults.string(forKey: lastTrackPathKey) else { return }
        guard let track = allTracks.first(where: { $0.url.path == path }) else { return }

        tracks = allTracks
        rebuildQueue(startingAt: track)
        playCurrent(autoPlay: false)
        seek(to: userDefaults.double(forKey: lastPlaybackPositionKey))
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
        guard currentIndex + 1 < queue.count else {
            isPlaying = false
            updateNowPlaying()
            return
        }
        if let currentTrack {
            history.append(currentTrack)
        }
        currentIndex += 1
        playCurrent(autoPlay: true)
    }

    func previous() {
        guard !queue.isEmpty else { return }
        if let previousTrack = history.popLast(), let previousIndex = queue.firstIndex(of: previousTrack) {
            currentIndex = previousIndex
            playCurrent(autoPlay: true)
            return
        }
        currentIndex = max(currentIndex - 1, 0)
        playCurrent(autoPlay: true)
    }

    func toggleShuffle() {
        setShuffleEnabled(mode == .ordered)
        if let currentTrack {
            rebuildQueue(startingAt: currentTrack)
        }
    }

    private func setShuffleEnabled(_ isEnabled: Bool) {
        mode = isEnabled ? .shuffled : .ordered
        userDefaults.set(isEnabled, forKey: shuffleEnabledKey)
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
        if let currentTrack {
            history.append(currentTrack)
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
        if let artworkData = currentTrack.artworkData, let image = UIImage(data: artworkData) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in
                image
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func savePlaybackState() {
        guard let currentTrack else { return }
        userDefaults.set(currentTrack.url.path, forKey: lastTrackPathKey)
        userDefaults.set(currentTime, forKey: lastPlaybackPositionKey)
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
