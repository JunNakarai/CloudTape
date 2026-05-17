import Foundation

func formatTime(_ seconds: TimeInterval) -> String {
    guard seconds.isFinite, seconds > 0 else { return "0:00" }
    let total = Int(seconds.rounded())
    let minutes = total / 60
    let seconds = total % 60
    return "\(minutes):\(String(format: "%02d", seconds))"
}
