import SwiftUI

struct EmptyLibraryView: View {
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
