import XCTest
@testable import CloudTape

final class TimeFormattingTests: XCTestCase {
    func testFormatTimeHandlesInvalidAndNegativeValues() {
        XCTAssertEqual(formatTime(.nan), "0:00")
        XCTAssertEqual(formatTime(-1), "0:00")
        XCTAssertEqual(formatTime(0), "0:00")
    }

    func testFormatTimeRoundsAndPadsSeconds() {
        XCTAssertEqual(formatTime(65.4), "1:05")
        XCTAssertEqual(formatTime(65.6), "1:06")
        XCTAssertEqual(formatTime(600), "10:00")
    }
}
