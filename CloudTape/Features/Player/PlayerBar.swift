import SwiftUI
import UIKit

struct PlayerBar: View {
    @EnvironmentObject private var player: AudioPlayer
    let isExpanded: Bool
    let expansionProgress: CGFloat
    let maximumExpandedHeight: CGFloat
    let toggleExpanded: () -> Void
    @State private var collapsedSwipeOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: isExpanded ? 20 : 10) {
            if isExpanded {
                dragHandle
            }

            if isExpanded {
                expandedContent
            } else {
                collapsedContent
            }
        }
        .tint(.white)
        .padding(.horizontal, 16)
        .padding(.top, isExpanded ? 9 : 10)
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
        HStack(spacing: 12) {
            if let currentTrack = player.currentTrack {
                ArtworkThumbnail(track: currentTrack, isCurrent: player.isPlaying, size: 42)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(player.currentTrack?.title ?? "未再生")
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.white)

                HStack(spacing: 7) {
                    Text(formatTime(player.currentTime))
                        .frame(width: 34, alignment: .leading)

                    collapsedProgressBar

                    Text(formatTime(player.duration))
                        .frame(width: 34, alignment: .trailing)
                }
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.76))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                player.togglePlayPause()
            } label: {
                PlayerPlayPauseButton(isPlaying: player.isPlaying, size: 44)
            }
            .buttonStyle(.plain)
            .disabled(player.currentTrack == nil)
            .accessibilityLabel(player.isPlaying ? "一時停止" : "再生")
        }
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .offset(x: collapsedSwipeOffset)
        .gesture(collapsedSwipeGesture)
        .onTapGesture(perform: toggleExpanded)
        .animation(.interactiveSpring(response: 0.24, dampingFraction: 0.82), value: collapsedSwipeOffset)
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

            expandedTransportControls

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

    private var collapsedProgressBar: some View {
        GeometryReader { proxy in
            let progress = collapsedProgress
            Capsule()
                .fill(Color.white.opacity(0.22))
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.86))
                        .frame(width: proxy.size.width * progress)
                }
        }
        .frame(height: 4)
        .accessibilityHidden(true)
    }

    private var collapsedProgress: CGFloat {
        guard player.currentTrack != nil, sliderUpperBound > 0 else { return 0 }
        return min(max(player.currentTime / sliderUpperBound, 0), 1)
    }

    private var collapsedSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 18)
            .onChanged { value in
                guard player.currentTrack != nil else { return }
                guard isMostlyHorizontal(value) else { return }
                collapsedSwipeOffset = max(min(value.translation.width * 0.18, 18), -18)
            }
            .onEnded { value in
                defer {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.84)) {
                        collapsedSwipeOffset = 0
                    }
                }
                guard player.currentTrack != nil else { return }
                guard isMostlyHorizontal(value) else { return }

                if value.translation.width <= -60 {
                    player.next()
                    playSwipeFeedback()
                } else if value.translation.width >= 60 {
                    player.previous()
                    playSwipeFeedback()
                }
            }
    }

    private func isMostlyHorizontal(_ value: DragGesture.Value) -> Bool {
        abs(value.translation.width) > 60
            && abs(value.translation.width) > abs(value.translation.height) * 1.35
    }

    private func playSwipeFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private var shuffleButton: some View {
        Button {
            player.toggleShuffle()
        } label: {
            Image(systemName: player.mode == .shuffled ? "shuffle.circle.fill" : "shuffle")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(player.mode == .shuffled ? Color.cyan : Color.white.opacity(0.58))
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("シャッフル")
        .accessibilityValue(player.mode == .shuffled ? "オン" : "オフ")
    }

    private var expandedTransportControls: some View {
        ZStack {
            transportControls(playButtonSize: 58, spacing: 36)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Spacer()
                shuffleButton
            }
        }
        .frame(maxWidth: .infinity)
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
                PlayerPlayPauseButton(isPlaying: player.isPlaying, size: playButtonSize)
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

private struct PlayerPlayPauseButton: View {
    let isPlaying: Bool
    let size: CGFloat

    private var iconSize: CGFloat {
        max(size * 0.38, 17)
    }

    var body: some View {
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: iconSize, weight: .bold))
            .foregroundStyle(Color.black.opacity(0.86))
            .frame(width: size, height: size)
            .background {
                Circle()
                    .fill(Color.white.opacity(0.96))
                    .shadow(color: .black.opacity(0.24), radius: 8, x: 0, y: 4)
            }
            .contentShape(Circle())
    }
}
