import XCTest
@testable import CloudTape

final class DemoLaunchOptionsTests: XCTestCase {
    func testDemoLaunchOptionsParseScreenshotArguments() {
        let options = DemoLaunchOptions(arguments: [
            "CloudTape",
            "-CloudTapeDemoFolder",
            "/tmp/CloudTapeDemo",
            "-CloudTapeDemoAutoplay",
            "-CloudTapeDemoExpandPlayer",
            "-CloudTapeDemoShowSearch",
            "-CloudTapeDemoSearchQuery",
            "Sailor"
        ])

        XCTAssertEqual(options.folderURL?.path, "/tmp/CloudTapeDemo")
        XCTAssertTrue(options.autoplay)
        XCTAssertTrue(options.expandPlayer)
        XCTAssertTrue(options.showSearch)
        XCTAssertEqual(options.searchQuery, "Sailor")
    }

    func testDemoLaunchOptionsUseSafeDefaults() {
        let options = DemoLaunchOptions(arguments: ["CloudTape"])

        XCTAssertNil(options.folderURL)
        XCTAssertFalse(options.autoplay)
        XCTAssertFalse(options.expandPlayer)
        XCTAssertFalse(options.showSearch)
        XCTAssertEqual(options.searchQuery, "")
    }
}
