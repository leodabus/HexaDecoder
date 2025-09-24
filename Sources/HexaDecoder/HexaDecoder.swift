// The Swift Programming Language
// https://docs.swift.org/swift-book

import protocol Foundation.DataProtocol
import protocol Foundation.LocalizedError

extension String {
    /// Errors that can occur when decoding a hexadecimal string.
    enum HexaDecodingError: Error, Equatable {
        /// Found a character that is not a valid hexadecimal digit.
        case invalidCharacter(Character)
        /// The string contains an odd number of characters (hex needs pairs of digits).
        case oddNumberOfCharacters
    }
}

/// Provides localized error descriptions for hex decoding errors.
///
/// Conforming `HexaDecodingError` to `LocalizedError` allows the errors to
/// present user-friendly messages when printed or surfaced to higher layers
/// (for example, in logs or UI).
extension String.HexaDecodingError: LocalizedError {
    /// A localized message describing what error occurred.
    ///
    /// - `.oddNumberOfCharacters`:
    ///   Returns `"Hex string contains an odd number of characters."`
    ///
    /// - `.invalidCharacter(let c)`:
    ///   Returns `"Invalid hex character: <character>"`
    public var errorDescription: String? {
        switch self {
        case .oddNumberOfCharacters:
            return "Hex string contains an odd number of characters."
        case .invalidCharacter(let c):
            return "Invalid hex character: \(c)"
        }
    }
}

extension Collection {
    /// Splits the collection into consecutive subsequences of at most `maxLength` elements.
    ///
    /// - Parameter maxLength: Maximum length of each emitted subsequence.
    /// - Returns: A sequence yielding non-overlapping slices until the collection ends.
    ///
    /// This is used to iterate over pairs of hex digits efficiently.
    func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence,Index> {
        sequence(state: startIndex) { lowerBound in
            guard lowerBound < endIndex else { return nil }
            let upperBound = index(
                lowerBound,
                offsetBy: maxLength,
                limitedBy: endIndex
            ) ?? endIndex
            defer { lowerBound = upperBound }
            return self[lowerBound..<upperBound]
        }
    }
}

extension StringProtocol {
    /// Decodes the receiver as hexadecimal into a byte-collection type.
    ///
    /// This generic helper lets you choose the output type:
    /// ```swift
    /// let data: Data = try "48656c6c6f".hexa()
    /// let bytes: [UInt8] = try "48656c6c6f".hexa()
    /// ```
    ///
    /// - Returns: A value of type `D` filled with the decoded bytes.
    /// - Throws: `String.HexaDecodingError` if the string is malformed.
    func hexa<D>() throws -> D where D: DataProtocol & RangeReplaceableCollection {
        try .init(self)
    }
}

extension DataProtocol where Self: RangeReplaceableCollection {
    /// Creates a byte collection by decoding a hexadecimal string.
    ///
    /// Each two hex digits (0–9, a–f, A–F) form one byte.
    ///
    /// - Parameter hexa: A string of even length containing only hex digits.
    /// - Throws:
    ///   - `String.HexaDecodingError.oddNumberOfCharacters` when `hexa` length is odd.
    ///   - `String.HexaDecodingError.invalidCharacter` when a non-hex character is found.
    ///
    /// - Example:
    /// ```swift
    /// let d: Data = try .init("48656c6c6f") // "Hello"
    /// let a: [UInt8] = try .init("48656c6c6f")
    /// ```
    init<S: StringProtocol>(_ hexa: S) throws {
        guard hexa.count.isMultiple(of: 2) else {
            throw String.HexaDecodingError.oddNumberOfCharacters
        }
        self = .init()
        reserveCapacity(hexa.utf8.count/2)
        for pair in hexa.unfoldSubSequences(limitedTo: 2) {
            guard let byte = UInt8(pair, radix: 16) else {
                for character in pair where !character.isHexDigit {
                    throw String.HexaDecodingError.invalidCharacter(character)
                }
                continue
            }
            append(byte)
        }
    }
}
