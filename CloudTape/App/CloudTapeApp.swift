import SwiftUI

@main
struct CloudTapeApp: App {
    @StateObject private var library = MusicLibrary()
    @StateObject private var player = AudioPlayer()

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environmentObject(library)
                .environmentObject(player)
                .onAppear {
                    player.configureSession()
                    library.restoreLastFolder()
                }
        }
    }
}
