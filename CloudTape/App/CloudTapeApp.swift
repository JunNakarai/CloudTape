import SwiftUI

#if DEBUG
struct DemoLaunchOptions {
    let folderURL: URL?
    let autoplay: Bool
    let expandPlayer: Bool

    static let current = DemoLaunchOptions(arguments: ProcessInfo.processInfo.arguments)

    init(arguments: [String]) {
        folderURL = Self.value(after: "-CloudTapeDemoFolder", in: arguments)
            .map { URL(fileURLWithPath: $0, isDirectory: true) }
        autoplay = arguments.contains("-CloudTapeDemoAutoplay")
        expandPlayer = arguments.contains("-CloudTapeDemoExpandPlayer")
    }

    private static func value(after key: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: key) else { return nil }
        let valueIndex = arguments.index(after: index)
        guard arguments.indices.contains(valueIndex) else { return nil }
        return arguments[valueIndex]
    }
}
#endif

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
#if DEBUG
                    if let demoFolderURL = DemoLaunchOptions.current.folderURL {
                        library.loadFolder(demoFolderURL)
                    } else {
                        library.restoreLastFolder()
                    }
#else
                    library.restoreLastFolder()
#endif
                }
        }
    }
}
