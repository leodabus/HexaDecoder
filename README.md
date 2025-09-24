# HexaDecoder

Minimal Swift package to decode hexadecimal strings into `Data` or `[UInt8]`, with strict error handling and localized error messages.

---

## Features

- Convert hex strings → `Data` or `[UInt8]`
- Clear errors for malformed input (`oddNumberOfCharacters`, `invalidCharacter`)
- Localized error descriptions for easier debugging
- Lightweight, protocol-oriented API (just extensions, no wrappers)

---

## Installation

Add **HexaDecoder** to your project using Swift Package Manager:

In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/leodabus/HexaDecoder.git", from: "1.0.0")
]
```

Or in Xcode:  
**File → Add Packages… →** paste the repo URL `https://github.com/leodabus/HexaDecoder.git`.

---

## Usage

```swift
import HexaDecoder
import Foundation

let hex = "48656c6c6f"

// Decode into Data
let data: Data = try hex.hexa()

// Decode into [UInt8]
let bytes: [UInt8] = try hex.hexa()

print(String(decoding: data, as: UTF8.self)) // "Hello"
print(bytes) // [72, 101, 108, 108, 111]
```

### Error handling

```swift
do {
    let _: Data = try "abc".hexa()
} catch {
    print(error.localizedDescription)
    // "Hex string contains an odd number of characters."
}
```

---

## License

[MIT](LICENSE) © 2025 Leonardo Dabus
