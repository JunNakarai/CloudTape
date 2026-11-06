import XCTest
@testable import CloudTape

final class TrackFileDatesTests: XCTestCase {
    func testDirectoryAdditionDateTakesPriorityOverCreationDate() {
        let added = Date(timeIntervalSince1970: 20)
        let created = Date(timeIntervalSince1970: 10)
        XCTAssertEqual(TrackFileDates(directoryAdditionDate: added, creationDate: created).preferredAdditionDate, added)
    }

    func testCreationDateIsFallbackAndMissingDatesRemainUnknown() {
        let created = Date(timeIntervalSince1970: 10)
        XCTAssertEqual(TrackFileDates(directoryAdditionDate: nil, creationDate: created).preferredAdditionDate, created)
        XCTAssertNil(TrackFileDates(directoryAdditionDate: nil, creationDate: nil).preferredAdditionDate)
    }

    func testReadsLocalFileCreationDateAndHandlesMissingFiles() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp3")
        try Data().write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let expected = try url.resourceValues(forKeys: [.creationDateKey]).creationDate
        XCTAssertNotNil(expected)
        XCTAssertEqual(TrackFileDates.read(from: url).creationDate, expected)
        let missing = url.appendingPathExtension("missing")
        XCTAssertNil(TrackFileDates.read(from: missing).preferredAdditionDate)
    }
}
