import SwiftUI

#if DEBUG
struct DemoLaunchOptions {
    let folderURL: URL?
    let autoplay: Bool
    let expandPlayer: Bool
    let showSearch: Bool
    let searchQuery: String

    static let current = DemoLaunchOptions(arguments: ProcessInfo.processInfo.arguments)

    init(arguments: [String]) {
        folderURL = Self.value(after: "-CloudTapeDemoFolder", in: arguments)
            .map { URL(fileURLWithPath: $0, isDirectory: true) }
        autoplay = arguments.contains("-CloudTapeDemoAutoplay")
        expandPlayer = arguments.contains("-CloudTapeDemoExpandPlayer")
        showSearch = arguments.contains("-CloudTapeDemoShowSearch")
        searchQuery = Self.value(after: "-CloudTapeDemoSearchQuery", in: arguments) ?? ""
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
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppSettingsKey.restoreLastPlayback) private var restoreLastPlayback = false
    @AppStorage(AppSettingsKey.rescanLibraryOnLaunch) private var rescanLibraryOnLaunch = true
    @AppStorage(AppSettingsKey.theme) private var themeRawValue = AppTheme.system.rawValue
    @StateObject private var library = MusicLibrary()
    @StateObject private var player = AudioPlayer()

    private var preferredColorScheme: ColorScheme? {
        (AppTheme(rawValue: themeRawValue) ?? .system).colorScheme
    }

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environmentObject(library)
                .environmentObject(player)
                .preferredColorScheme(preferredColorScheme)
                .onAppear {
                    player.configureSession()
#if DEBUG
                    if let demoFolderURL = DemoLaunchOptions.current.folderURL {
                        library.loadFolder(demoFolderURL)
                    } else if rescanLibraryOnLaunch {
                        library.restoreLastFolder()
                    }
#else
                    if rescanLibraryOnLaunch {
                        library.restoreLastFolder()
                    }
#endif
                }
                .onChange(of: scenePhase) { _, phase in
                    guard restoreLastPlayback else { return }
                    if phase == .inactive || phase == .background {
                        player.persistCurrentPlaybackState()
                    }
                }
        }
    }
}
