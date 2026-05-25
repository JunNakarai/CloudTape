import SwiftUI

struct EmptyLibraryView: View {
    let state: LibraryState
    let chooseFolder: () -> Void
    let trySampleAudio: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(description)
        } actions: {
            if showsFolderButton {
                Button("フォルダを選ぶ", action: chooseFolder)
                    .buttonStyle(.borderedProminent)

                if let trySampleAudio {
                    Button("サンプル音源を試す", action: trySampleAudio)
                        .buttonStyle(.bordered)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var title: String {
        switch state {
        case .scanning:
            return "ライブラリを確認中"
        case .emptyFolder:
            return "音楽が見つかりません"
        case .syncing:
            return "iCloudから同期中"
        case .error:
            return "フォルダを開けません"
        case .noFolder, .ready:
            return "音楽フォルダを選択"
        }
    }

    private var description: String {
        switch state {
        case .scanning:
            return "選択したフォルダの音楽ファイルを読み込んでいます。"
        case .emptyFolder:
            return "対応している音声ファイルがありません。別のフォルダを選んでください。"
        case .syncing(let count):
            return "\(count)曲をiCloud Driveからダウンロードしています。完了すると再生できます。"
        case .error(let message):
            return message
        case .noFolder, .ready:
            return "iCloud DriveまたはFiles内のフォルダを選ぶと、すぐに再生できます。"
        }
    }

    private var systemImage: String {
        switch state {
        case .scanning:
            return "waveform"
        case .emptyFolder:
            return "folder"
        case .syncing:
            return "icloud.and.arrow.down"
        case .error:
            return "exclamationmark.icloud"
        case .noFolder, .ready:
            return "music.note.list"
        }
    }

    private var showsFolderButton: Bool {
        state != .scanning
    }
}
