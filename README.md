# SanscriptSwift

A Swift implementation of the [sanscript.js](https://github.com/indic-transliteration/sanscript.js) transliteration library. This library provides transliteration between various Indic scripts and romanization schemes.

## Features

- Transliteration between Brahmic scripts (Devanagari, Tamil, Telugu, etc.)
- Transliteration between Roman schemes (IAST, ITRANS, Harvard-Kyoto, etc.)
- Support for custom transliteration schemes
- Options for skipping SGML/HTML tags, syncope, and preferred alternates
- Wordwise transliteration for script learning
- High-performance implementation with caching
- Uses the same TOML scheme files as the JavaScript implementation

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SanscriptSwift.git", from: "1.0.0")
]
```

## Usage

### Basic Transliteration

```swift
import SanscriptSwift

// Basic transliteration
let devanagariText = "नमस्ते"
let iast = Sanscript.t(devanagariText, from: "devanagari", to: "iast")
print(iast) // Outputs: "namaste"

// Transliteration with options
var options = Sanscript.Defaults()
options.skipSgml = true
options.preferredAlternates = ["iast": ["ṃ": "ṁ"]]

let itransText = "namaste"
let tamil = Sanscript.t(itransText, from: "itrans", to: "tamil", options: options)
```

### Loading Schemes from TOML Files

```swift
// Load all schemes from the common_maps directory
do {
    try Sanscript.shared.loadAllSchemes(baseDirectory: "/path/to/your/project")
} catch {
    print("Error loading schemes: \(error)")
}

// Load schemes from bundle resources
do {
    try Sanscript.shared.loadSchemesFromBundle()
} catch {
    print("Error loading schemes: \(error)")
}
```

### Wordwise Transliteration

```swift
// Transliterate each word separately (useful for learning)
let sentence = "namaste duniya"
let wordwiseResult = Sanscript.shared.transliterateWordwise(data: sentence, from: "itrans", to: "devanagari")

for (original, transliterated) in wordwiseResult {
    print("\(original) -> \(transliterated)")
}
```

### Adding Custom Schemes

```swift
// Add a custom Brahmic scheme
let myCustomScheme: [String: [String: String]] = [
    "vowels": [
        "अ": "a",
        "आ": "A",
        // ...
    ],
    "consonants": [
        "क": "k",
        "ख": "kh",
        // ...
    ],
    // ...
]

Sanscript.shared.addBrahmicScheme(name: "my_custom_scheme", scheme: myCustomScheme)

// Add a custom Roman scheme
let myCustomRomanScheme: [String: [String: String]] = [
    "vowels": [
        "अ": "a",
        "आ": "A",
        // ...
    ],
    "consonants": [
        "क": "k",
        "ख": "kh",
        // ...
    ],
    // ...
]

Sanscript.shared.addRomanScheme(name: "my_custom_roman", scheme: myCustomRomanScheme)
```

## Supported Schemes

### Brahmic Scripts
- Devanagari
- Bengali
- Gujarati
- Gurmukhi
- Kannada
- Malayalam
- Oriya
- Tamil
- Telugu

### Roman Schemes
- IAST
- ITRANS
- Harvard-Kyoto
- SLP1
- WX
- Velthuis

## Implementation Details

This Swift implementation faithfully reproduces the behavior of the original JavaScript library, using the same TOML files for scheme definitions and maintaining the same transliteration logic. Key features include:

- Singleton pattern for easy access
- Caching for improved performance
- Support for all the same options as the JavaScript implementation
- Handling of special cases like toggling transliteration and SGML skipping

## License

MIT License
