import XCTest

@testable import heka

final class hekaTests: XCTestCase {
  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    XCTAssertEqual(heka().text, "Hello, World!")
  }
}
