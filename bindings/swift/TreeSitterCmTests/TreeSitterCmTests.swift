import XCTest
import SwiftTreeSitter
import TreeSitterCm

final class TreeSitterCmTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_cm())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading C(m) grammar")
    }
}
