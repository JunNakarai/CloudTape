import SwiftUI

struct StatusRow: View {
    let message: String
    let systemImage: String
    var tint: Color = .blue

    var body: some View {
        Label {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
        }
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
    }
}

#Preview("iCloud Sync") {
    List {
        StatusRow(
            message: "3曲をiCloudから同期中",
            systemImage: "icloud.and.arrow.down"
        )
    }
    .listStyle(.plain)
}

#Preview("Long Status") {
    List {
        StatusRow(
            message: "128曲をiCloudから同期中",
            systemImage: "icloud.and.arrow.down"
        )
    }
    .listStyle(.plain)
}

#Preview("Dark") {
    List {
        StatusRow(
            message: "12曲をiCloudから同期中",
            systemImage: "icloud.and.arrow.down"
        )
    }
    .listStyle(.plain)
    .preferredColorScheme(.dark)
}
