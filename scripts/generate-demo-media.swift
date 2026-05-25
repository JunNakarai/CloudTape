import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Foundation

struct DemoTrack {
    let slug: String
    let title: String
    let frequency: Int
    let colors: [CGColor]
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "docs/assets/demo-media", isDirectory: true)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let tracks = [
    DemoTrack(
        slug: "first-noel",
        title: "First Noel",
        frequency: 220,
        colors: [
            CGColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1),
            CGColor(red: 0.15, green: 0.34, blue: 0.46, alpha: 1),
            CGColor(red: 0.87, green: 0.69, blue: 0.41, alpha: 1)
        ]
    ),
    DemoTrack(
        slug: "hey-sailor",
        title: "Hey Sailor",
        frequency: 277,
        colors: [
            CGColor(red: 0.05, green: 0.12, blue: 0.18, alpha: 1),
            CGColor(red: 0.10, green: 0.45, blue: 0.57, alpha: 1),
            CGColor(red: 0.95, green: 0.49, blue: 0.36, alpha: 1)
        ]
    ),
    DemoTrack(
        slug: "shaken",
        title: "Shaken",
        frequency: 330,
        colors: [
            CGColor(red: 0.12, green: 0.09, blue: 0.13, alpha: 1),
            CGColor(red: 0.43, green: 0.20, blue: 0.35, alpha: 1),
            CGColor(red: 0.70, green: 0.80, blue: 0.74, alpha: 1)
        ]
    )
]

func artworkURL(for track: DemoTrack) -> URL {
    outputDirectory.appendingPathComponent("cloudtape-session-\(track.slug).png")
}

func mp3URL(for track: DemoTrack) -> URL {
    outputDirectory.appendingPathComponent("cloudtape-session-\(track.slug).mp3")
}

func drawArtwork(for track: DemoTrack, to url: URL) throws {
    let size = 1024
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw NSError(domain: "CloudTapeDemoMedia", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create artwork context."])
    }

    let locations: [CGFloat] = [0, 0.56, 1]
    let gradient = CGGradient(colorsSpace: colorSpace, colors: track.colors as CFArray, locations: locations)
    context.drawLinearGradient(
        gradient!,
        start: CGPoint(x: 0, y: 0),
        end: CGPoint(x: CGFloat(size), y: CGFloat(size)),
        options: []
    )

    context.setFillColor(CGColor(gray: 1, alpha: 0.08))
    context.addPath(CGPath(roundedRect: CGRect(x: 92, y: 118, width: 840, height: 788), cornerWidth: 88, cornerHeight: 88, transform: nil))
    context.fillPath()

    context.setFillColor(CGColor(gray: 0, alpha: 0.16))
    context.fillEllipse(in: CGRect(x: -96, y: 552, width: 520, height: 520))
    context.fillEllipse(in: CGRect(x: 590, y: -132, width: 570, height: 570))

    context.setFillColor(track.colors[2].copy(alpha: 0.72) ?? track.colors[2])
    context.fillEllipse(in: CGRect(x: 242, y: 224, width: 540, height: 540))

    context.setStrokeColor(CGColor(gray: 1, alpha: 0.18))
    context.setLineWidth(18)
    context.setLineCap(.round)
    context.beginPath()
    for index in 0..<7 {
        let x = CGFloat(238 + index * 92)
        let top = CGFloat(600 + (index % 2 == 0 ? 52 : -26))
        let bottom = CGFloat(410 + (index % 2 == 0 ? -34 : 44))
        context.move(to: CGPoint(x: x, y: bottom))
        context.addCurve(
            to: CGPoint(x: x + 48, y: top),
            control1: CGPoint(x: x + 18, y: bottom + 80),
            control2: CGPoint(x: x + 30, y: top - 80)
        )
    }
    context.strokePath()

    context.setStrokeColor(CGColor(gray: 1, alpha: 0.30))
    context.setLineWidth(4)
    context.strokeEllipse(in: CGRect(x: 314, y: 296, width: 396, height: 396))

    guard let image = context.makeImage(),
          let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw NSError(domain: "CloudTapeDemoMedia", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create artwork PNG destination."])
    }

    CGImageDestinationAddImage(destination, image, nil)
    if !CGImageDestinationFinalize(destination) {
        throw NSError(domain: "CloudTapeDemoMedia", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not write artwork PNG."])
    }
}

func run(_ command: String, _ arguments: [String]) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
        throw NSError(domain: "CloudTapeDemoMedia", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "\(command) failed."])
    }
}

func ffmpegPath() -> String {
    let candidates = ["/opt/homebrew/bin/ffmpeg", "/usr/local/bin/ffmpeg", "/usr/bin/ffmpeg"]
    return candidates.first { FileManager.default.isExecutableFile(atPath: $0) } ?? "ffmpeg"
}

for (index, track) in tracks.enumerated() {
    let artURL = artworkURL(for: track)
    let outputURL = mp3URL(for: track)
    try drawArtwork(for: track, to: artURL)

    try run(ffmpegPath(), [
        "-nostdin",
        "-y",
        "-f", "lavfi",
        "-i", "sine=frequency=\(track.frequency):duration=74",
        "-i", artURL.path,
        "-map", "0:a",
        "-map", "1:v",
        "-c:a", "libmp3lame",
        "-q:a", "5",
        "-c:v", "mjpeg",
        "-id3v2_version", "3",
        "-metadata", "title=\(track.title)",
        "-metadata", "artist=CloudTape Demo Studio",
        "-metadata", "album=CloudTape Sessions",
        "-metadata", "track=\(index + 1)",
        "-disposition:v", "attached_pic",
        outputURL.path
    ])
}
