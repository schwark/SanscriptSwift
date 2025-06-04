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
    .package(url: "https://github.com/schwark/SanscriptSwift.git", from: "1.0.0")
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

### Scheme Loading

Schemes are automatically loaded from the resources directory when the Sanscript singleton is initialized. You don't need to explicitly load schemes unless you want to load custom schemes from a different location.

```swift
// The default initialization automatically loads schemes
let sanscript = Sanscript.shared

// If needed, you can reload schemes or load from a custom path
do {
    try Sanscript.shared.loadSchemesFromResources()
    // Or load from a specific path
    try Sanscript.shared.loadSchemesFromPath(resourcesPath: "/path/to/your/schemes")
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

## Command Line Interface (CLI)

The package includes a command-line interface for quick transliteration tasks:

### Usage

```bash
# Run tests
SanscriptCLI

# Run tests with debug output
SanscriptCLI --debug

# List available schemes
SanscriptCLI --list

# Show help
SanscriptCLI --help

# Transliterate text (positional parameters)
SanscriptCLI "namaste" iast devanagari

# Transliterate text (named parameters)
SanscriptCLI --text="namaste" --from=iast --to=devanagari
```

The CLI automatically loads all schemes from the resources directory, so you don't need to worry about scheme initialization.

### Debug Mode

You can enable debug output by setting the `Sanscript.debug` flag:

```swift
// Enable debug output
Sanscript.debug = true
```

In the CLI, use the `--debug` flag to enable debug output:

```bash
SanscriptCLI --debug
```

This will show detailed information about the transliteration process, including token matching and buffer updates.

## License

MIT License
