import SwiftUI

struct PlayerBar: View {
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
