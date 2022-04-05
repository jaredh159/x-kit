import XCore
import XCTest

final class StringTests: XCTestCase {
  func testSnakeCased() throws {
    XCTAssertEqual("fooBarBaz".snakeCased, "foo_bar_baz")
  }

  func testShoutyCased() throws {
    XCTAssertEqual("fooBarBaz".shoutyCased, "FOO_BAR_BAZ")
  }
}
