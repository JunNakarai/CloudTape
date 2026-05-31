import XCTest
@testable import CloudTape

final class TrackTests: XCTestCase {
    func testTrackFromURLUsesRelativeFolderAsSubtitle() {
        let root = URL(fileURLWithPath: "/tmp/CloudTape")
        let url = root.appendingPathComponent("Albums/Track One.mp3")

        let track = Track.from(url: url, root: root)

        XCTAssertEqual(track.id, url)
        XCTAssertEqual(track.title, "Track One")
        XCTAssertEqual(track.subtitle, "Albums")
        XCTAssertNil(track.artist)
        XCTAssertNil(track.album)
    }

    func testWithMetadataPrefersNonEmptyTitleAndArtistAlbumSubtitle() {
        let url = URL(fileURLWithPath: "/tmp/CloudTape/Track One.mp3")
        let track = Track.from(url: url, root: URL(fileURLWithPath: "/tmp/CloudTape"))

        let enriched = track.withMetadata(
            title: "  Metadata Title  ",
            artist: "Artist",
            album: "Album",
            duration: 123,
            artworkData: Data([0x01, 0x02])
        )

        XCTAssertEqual(enriched.title, "Metadata Title")
        XCTAssertEqual(enriched.subtitle, "Artist - Album")
        XCTAssertEqual(enriched.duration, 123)
        XCTAssertEqual(enriched.artworkData, Data([0x01, 0x02]))
    }

    func testWithMetadataKeepsFilenameTitleWhenMetadataTitleIsBlank() {
        let url = URL(fileURLWithPath: "/tmp/CloudTape/Track One.mp3")
        let track = Track.from(url: url, root: URL(fileURLWithPath: "/tmp/CloudTape"))

        let enriched = track.withMetadata(
            title: "   ",
            artist: nil,
            album: nil,
            duration: nil,
            artworkData: nil
        )

        XCTAssertEqual(enriched.title, "Track One")
        XCTAssertEqual(enriched.subtitle, track.subtitle)
    }
}
