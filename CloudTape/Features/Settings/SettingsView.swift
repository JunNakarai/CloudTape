import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppSettingsKey.restoreLastPlayback) private var restoreLastPlayback = false
    @AppStorage(AppSettingsKey.rescanLibraryOnLaunch) private var rescanLibraryOnLaunch = true
    @AppStorage(AppSettingsKey.theme) private var themeRawValue = AppTheme.system.rawValue

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (version, build) {
        case let (version?, build?) where !version.isEmpty && !build.isEmpty:
            return "\(version) (\(build))"
        case let (version?, _) where !version.isEmpty:
            return version
        default:
            return "Unknown"
        }
    }

    private var selectedTheme: Binding<AppTheme> {
        Binding {
            AppTheme(rawValue: themeRawValue) ?? .system
        } set: { newValue in
            themeRawValue = newValue.rawValue
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("再生") {
                    Toggle("前回の再生位置を復元", isOn: $restoreLastPlayback)
                }

                Section("ライブラリ") {
                    Toggle("起動時にライブラリを再スキャン", isOn: $rescanLibraryOnLaunch)
                }

                Section("表示") {
                    Picker("テーマ", selection: selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                }

                Section("その他") {
                    LabeledContent("App Version", value: appVersion)

                    NavigationLink("OSS Licenses") {
                        OSSLicensesView()
                    }

                    Link("Privacy Policy", destination: URL(string: "https://junnakarai.github.io/CloudTape/privacy-policy.html")!)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct OSSLicensesView: View {
    var body: some View {
        Form {
            Section {
                Text("CloudTape does not bundle third-party open source libraries.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("OSS Licenses")
        .navigationBarTitleDisplayMode(.inline)
    }
}
