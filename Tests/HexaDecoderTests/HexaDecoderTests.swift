import XCTest
import struct Foundation.Data
@testable import HexaDecoder

final class HexaDecoderTests: XCTestCase {

    func testValid() throws {
        let hex = "48656c6c6f"
        let data: Data = try hex.hexa()
        XCTAssertEqual(data, Data("Hello".utf8))
        let bytes: [UInt8] = try hex.hexa()
        XCTAssertEqual(bytes, Array("Hello".utf8))
    }

    func testOdd() {
        XCTAssertThrowsError(try "abc".hexa() as Data) { error in
            XCTAssertEqual(error as? String.HexaDecodingError, .oddNumberOfCharacters)
        }
    }

    func testInvalid() {
        XCTAssertThrowsError(try "zz".hexa() as Data) { error in
            XCTAssertEqual(
                error as? String.HexaDecodingError,
                .invalidCharacter("z")
            )
        }
    }

    func testOddLocalizedDescription() {
        XCTAssertThrowsError(try "abc".hexa() as Data) { error in
            XCTAssertEqual(
                error.localizedDescription,
                "Hex string contains an odd number of characters."
            )
        }
    }

    func testInvalidLocalizedDescription() {
        XCTAssertThrowsError(try "zz".hexa() as Data) { error in
            XCTAssertEqual(
                error.localizedDescription,
                "Invalid hex character: z"
            )
        }
    }
}

