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
    @Published var errorMessage: String?

    private var tracks: [Track] = []
    private var queue: [Track] = []
    private var history: [Track] = []
    private var currentIndex = 0
    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?
    private var failedObserver: NSObjectProtocol?
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
        if let failedObserver {
            NotificationCenter.default.removeObserver(failedObserver)
        }
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }

    @discardableResult
    func configureSession() -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            return true
        } catch {
            errorMessage = "バックグラウンド再生の準備ができませんでした。音量や再生設定を確認して、もう一度お試しください。"
            return false
        }
    }

    func play(track: Track, in allTracks: [Track]) {
        tracks = allTracks
        history.removeAll()
        rebuildQueue(startingAt: track)
        playCurrent(autoPlay: true)
    }

    @discardableResult
    func playRandomTrack(in allTracks: [Track]) -> Bool {
        guard !allTracks.isEmpty else { return false }
        tracks = allTracks
        history.removeAll()

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
        guard player != nil else { return }
        if isPlaying {
            pause()
        } else {
            play()
        }
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

    func toggleShuffleMode() {
        setShuffleEnabled(mode == .ordered)
        if let currentTrack {
            rebuildQueue(startingAt: currentTrack)
        }
    }

    func persistCurrentPlaybackState() {
        savePlaybackState()
    }

    private func setShuffleEnabled(_ isEnabled: Bool) {
        mode = isEnabled ? .shuffled : .ordered
        userDefaults.set(isEnabled, forKey: shuffleEnabledKey)
    }

    private func rebuildQueue(startingAt track: Track) {
        queue = PlaybackQueueBuilder.queue(for: tracks, startingAt: track, mode: mode)
        currentIndex = queue.firstIndex(of: track) ?? 0
    }

    private func playCurrent(autoPlay: Bool) {
        guard queue.indices.contains(currentIndex) else { return }
        let track = queue[currentIndex]
        guard prepareForPlayback(track) else { return }

        currentTrack = track
        savePlaybackState()

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        if let failedObserver {
            NotificationCenter.default.removeObserver(failedObserver)
        }
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }

        let item = AVPlayerItem(url: track.url)
        player = AVPlayer(playerItem: item)
        currentTime = 0
        duration = sanitizedDuration(track.duration)
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.nextAfterFinish() }
        }
        failedObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handlePlaybackFailure(notification: notification)
            }
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
            play()
        } else {
            isPlaying = false
            updateNowPlaying()
        }
    }

    private func play() {
        guard let player else { return }
        guard configureSession() else { return }
        player.play()
        isPlaying = true
        updateNowPlaying()
    }

    private func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlaying()
    }

    private func nextAfterFinish() {
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

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.play() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
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

    private func prepareForPlayback(_ track: Track) -> Bool {
        guard FileManager.default.fileExists(atPath: track.url.path) else {
            failPlayback("この曲が見つかりません。iCloud Driveの同期状態を確認するか、フォルダを選び直してください。")
            return false
        }

        do {
            let values = try track.url.resourceValues(forKeys: [
                .isUbiquitousItemKey,
                .ubiquitousItemDownloadingStatusKey
            ])
            if values.isUbiquitousItem == true,
               values.ubiquitousItemDownloadingStatus != .current {
                try? FileManager.default.startDownloadingUbiquitousItem(at: track.url)
                failPlayback("この曲はまだiCloudからダウンロード中です。少し待ってからもう一度再生してください。")
                return false
            }
        } catch {
            failPlayback("この曲を開けませんでした。ファイルの場所やiCloud Driveの状態を確認してください。")
            return false
        }

        return true
    }

    private func handlePlaybackFailure(notification: Notification) {
        pause()
        let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
        if let error {
            failPlayback("再生を続けられませんでした: \(error.localizedDescription)")
        } else {
            failPlayback("再生を続けられませんでした。別の曲を選んでください。")
        }
    }

    private func failPlayback(_ message: String) {
        errorMessage = message
        isPlaying = false
        updateNowPlaying()
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
