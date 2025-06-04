import Foundation
import SanscriptSwift

print("SanscriptSwift CLI - Minimal Test")
print("=============================")

// Create a simple test with hardcoded values
let sanscript = Sanscript.shared

// Add minimal schemes directly
print("Adding minimal schemes...")

// Add a basic Devanagari scheme with just a few characters
// Make sure to include all necessary components for proper transliteration
let devanagariScheme: [String: [String: String]] = [
        "vowels": [
            "अ": "a",
            "आ": "ā",
            "इ": "i",
            "ई": "ī",
            "उ": "u",
            "ऊ": "ū",
            "ए": "e",
            "ऐ": "ai",
            "ओ": "o",
            "औ": "au"
        ],
        "vowel_marks": [
            "ा": "ā",
            "ि": "i",
            "ी": "ī",
            "ु": "u",
            "ू": "ū",
            "े": "e",
            "ै": "ai",
            "ो": "o",
            "ौ": "au"
        ],
        "consonants": [
            "क": "ka",
            "ख": "kha",
            "ग": "ga",
            "घ": "gha",
            "ङ": "ṅa",
            "च": "ca",
            "छ": "cha",
            "ज": "ja",
            "झ": "jha",
            "ञ": "ña",
            "ट": "ṭa",
            "ठ": "ṭha",
            "ड": "ḍa",
            "ढ": "ḍha",
            "ण": "ṇa",
            "त": "ta",
            "थ": "tha",
            "द": "da",
            "ध": "dha",
            "न": "na",
            "प": "pa",
            "फ": "pha",
            "ब": "ba",
            "भ": "bha",
            "म": "ma",
            "य": "ya",
            "र": "ra",
            "ल": "la",
            "व": "va",
            "श": "śa",
            "ष": "ṣa",
            "स": "sa",
            "ह": "ha"
        ],
        "virama": [
            "्": ""
        ],
        "yogavaahas": [
            "ं": "ṃ",
            "ः": "ḥ"
        ]
    ]
    
// Add a basic IAST scheme with just a few characters
// Make sure to properly identify this as a Roman scheme
let iastScheme: [String: [String: String]] = [

        "vowels": [
            "अ": "a",
            "आ": "ā",
            "इ": "i",
            "ई": "ī",
            "उ": "u",
            "ऊ": "ū",
            "ए": "e",
            "ऐ": "ai",
            "ओ": "o",
            "औ": "au"
        ],
        "consonants": [
            "क": "k",
            "ख": "kh",
            "ग": "g",
            "घ": "gh",
            "ङ": "ṅ",
            "च": "c",
            "छ": "ch",
            "ज": "j",
            "झ": "jh",
            "ञ": "ñ",
            "ट": "ṭ",
            "ठ": "ṭh",
            "ड": "ḍ",
            "ढ": "ḍh",
            "ण": "ṇ",
            "त": "t",
            "थ": "th",
            "द": "d",
            "ध": "dh",
            "न": "n",
            "प": "p",
            "फ": "ph",
            "ब": "b",
            "भ": "bh",
            "म": "m",
            "य": "y",
            "र": "r",
            "ल": "l",
            "व": "v",
            "श": "ś",
            "ष": "ṣ",
            "स": "s",
            "ह": "h"
        ],
        "virama": [
            "्": ""
        ],
        "yogavaahas": [
            "ं": "ṃ",
            "ः": "ḥ"
        ],
        "alternates": [
            "ṃ": "ṁ",
            "ṛ": "r̥",
            "ṝ": "r̥̄",
            "ḷ": "l̥",
            "ḹ": "l̥̄"
        ],
        "isRomanScheme": [
            "true": "true"
        ]
    ]
    
// Add the schemes to Sanscript
print("Adding schemes to Sanscript...")
sanscript.addBrahmicScheme(name: "devanagari", scheme: devanagariScheme)
sanscript.addRomanScheme(name: "iast", scheme: iastScheme)
print("Schemes added successfully")

// Print available schemes
print("Available schemes: \(sanscript.schemes.keys.joined(separator: ", "))")

// Perform detailed transliteration tests
print("\nPerforming detailed transliteration tests...")

// Print the schemes for debugging
print("\nDevanagari scheme:")
for (key, value) in devanagariScheme {
    print("  \(key): \(value.count) entries")
}

print("\nIAST scheme:")
for (key, value) in iastScheme {
    print("  \(key): \(value.count) entries")
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
print("\nComparison with JavaScript reference output:")
let referenceTests = [
    ("namaste", "नमस्ते"),
    ("saṃskṛta", "संस्कृत"),
    ("śrīmad bhagavad gītā", "श्रीमद् भगवद् गीता"),
    ("kṛṣṇa", "कृष्ण"),
    ("dharma", "धर्म")
]

for (input, expected) in referenceTests {
    let result = Sanscript.t(input, from: "iast", to: "devanagari")
    let matches = result == expected
    print("  '\(input)' -> '\(result)'")
    print("    Expected: '\(expected)'")
    print("    Matches: \(matches ? "✓" : "✗")")
}

print("\nCLI test complete")
