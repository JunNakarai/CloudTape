import SwiftUI

enum AppSettingsKey {
    static let restoreLastPlayback = "restoreLastPlayback"
    static let rescanLibraryOnLaunch = "rescanLibraryOnLaunch"
    static let theme = "theme"
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "自動"
        case .light:
            return "ライト固定"
        case .dark:
            return "ダーク固定"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
