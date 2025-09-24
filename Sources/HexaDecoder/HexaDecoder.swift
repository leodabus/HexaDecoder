// The Swift Programming Language
// https://docs.swift.org/swift-book

import protocol Foundation.DataProtocol

extension String {
    enum HexaDecodingError: Error {
        case invalidCharacter(Character), oddNumberOfCharacters
    }
}

extension Collection {
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
    func hexa<D>() throws -> D where D: DataProtocol & RangeReplaceableCollection {
        try .init(self)
    }
}

extension DataProtocol where Self: RangeReplaceableCollection {
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
