import Foundation
import SanscriptSwift
import Toml

print("SanscriptSwift CLI - Minimal Test")
print("=============================")

// Create a Sanscript instance
let sanscript = Sanscript.shared

// Load schemes from file system path
print("Loading schemes from file system...")
do {
    // Get the path to the resources directory
    let resourcesPath = "/Users/schwark/projects/SanscriptSwift/Sources/SanscriptSwift/Resources/common_maps"
    
    // Get paths to brahmic and roman directories
    let brahmicPath = "\(resourcesPath)/brahmic"
    let romanPath = "\(resourcesPath)/roman"
    
    // Load schemes from these directories
    let fileManager = FileManager.default
    
    // Load Brahmic schemes
    if let brahmicFiles = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: brahmicPath), includingPropertiesForKeys: nil) {
        for fileURL in brahmicFiles where fileURL.pathExtension == "toml" {
            let schemeName = fileURL.deletingPathExtension().lastPathComponent
            do {
                try sanscript.loadSchemeFromTOML(filePath: fileURL.path, isRoman: false)
                print("Loaded Brahmic scheme: \(schemeName)")
            } catch {
                print("Warning: Failed to load Brahmic scheme \(schemeName): \(error)")
            }
        }
    }
    
    // Load Roman schemes
    if let romanFiles = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: romanPath), includingPropertiesForKeys: nil) {
        for fileURL in romanFiles where fileURL.pathExtension == "toml" {
            let schemeName = fileURL.deletingPathExtension().lastPathComponent
            do {
                try sanscript.loadSchemeFromTOML(filePath: fileURL.path, isRoman: true)
                print("Loaded Roman scheme: \(schemeName)")
            } catch {
                print("Warning: Failed to load Roman scheme \(schemeName): \(error)")
            }
        }
    }
    
    // Check if we have the required schemes for our tests
    if sanscript.schemes["devanagari"] != nil && sanscript.schemes["iast"] != nil {
        print("Required schemes loaded successfully")
    } else {
        print("Error: Required schemes 'devanagari' and/or 'iast' were not loaded")
        exit(1)
    }
}
// Print available schemes
print("Available schemes: \(sanscript.schemes.keys.joined(separator: ", "))")

// Perform detailed transliteration tests
print("\nPerforming detailed transliteration tests...")

// Print the schemes for debugging
print("\nDevanagari scheme:")
if let devanagariScheme = sanscript.schemes["devanagari"] {
    for (key, value) in devanagariScheme {
        if let dictValue = value as? [String: String] {
            print("  \(key): \(dictValue.count) entries")
        }
    }
}

print("\nIAST scheme:")
if let iastScheme = sanscript.schemes["iast"] {
    for (key, value) in iastScheme {
        if let dictValue = value as? [String: String] {
            print("  \(key): \(dictValue.count) entries")
        }
    }
}

// Define test cases
let testCases = ["a", "ka", "sa", "ta", "sta", "nama", "namaste"]

// Define specific test cases for consonant clusters
let clusterTestCases = [
    "sta",      // स्त - should have virama between s and t
    "namaste",  // नमस्ते - should have virama between s and t
    "karma",    // कर्म - should have virama between r and m
    "dharma",   // धर्म - should have virama between r and m
    "kṛṣṇa",    // कृष्ण - should handle ṛ vowel and ṣṇ cluster
    "śrī"       // श्री - should handle śr cluster and long ī
]

print("\nCharacter-by-character tests:")
for test in testCases {
    print("\nTesting: '\(test)'")
    let result = Sanscript.t(test, from: "iast", to: "devanagari")
    print("  Result: '\(result)'")
    
    // Print character by character for this test
    print("  Character breakdown:")
    for (i, c) in test.enumerated() {
        let char = String(c)
        let charResult = Sanscript.t(char, from: "iast", to: "devanagari")
        print("    \(i): '\(char)' -> '\(charResult)'")
    }
}

// Test with debugging info
print("\nDetailed tests for consonant clusters:")
for test in clusterTestCases {
    print("\nTesting: '\(test)'")
    let result = Sanscript.t(test, from: "iast", to: "devanagari")
    print("  Result: '\(result)'")
    
    // Print character by character for this test
    print("  Character breakdown:")
    for (i, c) in test.enumerated() {
        let char = String(c)
        let charResult = Sanscript.t(char, from: "iast", to: "devanagari")
        print("    \(i): '\(char)' -> '\(charResult)'")
    }
    
    // Try to test pairs of characters to see how they combine
    if test.count >= 2 {
        print("  Character pairs:")
        for i in 0..<(test.count-1) {
            let startIndex = test.index(test.startIndex, offsetBy: i)
            let endIndex = test.index(test.startIndex, offsetBy: i+2)
            let pair = String(test[startIndex..<endIndex])
            let pairResult = Sanscript.t(pair, from: "iast", to: "devanagari")
            print("    \(i)-\(i+1): '\(pair)' -> '\(pairResult)'")
        }
    }
}

// Test with JavaScript reference output
print("\nComparison with JavaScript reference output (IAST to Devanagari):")
let referenceTests = [
    ("namaste", "नमस्ते"),
    ("saṃskṛta", "संस्कृत"),
    ("śrīmad bhagavad gītā", "श्रीमद् भगवद् गीता"),
    ("kṛṣṇa", "कृष्ण"),
    ("dharma", "धर्म")
]

for (input, expected) in referenceTests {
    print("==== TRANSLITERATE ROMAN DEBUG ====")
    print("Input: \(input)")
    let result = Sanscript.t(input, from: "iast", to: "devanagari")
    print("==== END TRANSLITERATE ROMAN DEBUG ====")
    let matches = result == expected
    print("  '\(input)' -> '\(result)'")
    print("    Expected: '\(expected)'")
    print("    Matches: \(matches ? "✓" : "✗")")
}

// Test with ITRANS to Devanagari
print("\nComparison with JavaScript reference output (ITRANS to Devanagari):")
let itransTests = [
    ("namaste", "नमस्ते"),
    ("saMskRta", "संस्कृत"),
    ("shrImad bhagavad gItA", "श्रीमद् भगवद् गीता"),
    ("kRShNa", "कृष्ण"),
    ("dharma", "धर्म"),
    ("rAma", "राम"),
    ("gaNapati", "गणपति"),
    ("sha.nkara", "शङ्कर"),
    ("shiva", "शिव"),
    ("durgA", "दुर्गा")
]

for (input, expected) in itransTests {
    print("==== TRANSLITERATE ROMAN DEBUG ====")
    print("Input: \(input)")
    let result = Sanscript.t(input, from: "itrans", to: "devanagari")
    print("==== END TRANSLITERATE ROMAN DEBUG ====")
    let matches = result == expected
    print("  '\(input)' -> '\(result)'")
    print("    Expected: '\(expected)'")
    print("    Matches: \(matches ? "✓" : "✗")")
}

print("\nCLI test complete")
