import Foundation
import SanscriptSwift

// Example usage of SanscriptSwift

// Initialize Sanscript
let sanscript = Sanscript.shared

// Load schemes from the bundle
do {
    try sanscript.loadSchemesFromBundle()
    print("Successfully loaded schemes from bundle")
} catch {
    print("Error loading schemes from bundle: \(error)")
    print("Loading test schemes instead...")
    
    // Add test schemes if bundle loading fails
    // This is useful when running outside of the package context
    setupTestSchemes(sanscript: sanscript)
}

// Function to set up test schemes
func setupTestSchemes(sanscript: Sanscript) {
    // Add a basic Devanagari scheme
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
    }
    
    // Add a basic IAST scheme
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
    }
    
    sanscript.addBrahmicScheme(name: "devanagari", scheme: devanagariScheme)
    sanscript.addRomanScheme(name: "iast", scheme: iastScheme)
}

// Basic transliteration examples
print("\n--- Basic Transliteration Examples ---")

// Devanagari to IAST
let devanagariText = "नमस्ते"
let iastResult = Sanscript.t(devanagariText, from: "devanagari", to: "iast")
print("Devanagari to IAST: \(devanagariText) -> \(iastResult)")

// IAST to Devanagari
let iastText = "namaste"
let devanagariResult = Sanscript.t(iastText, from: "iast", to: "devanagari")
print("IAST to Devanagari: \(iastText) -> \(devanagariResult)")

// Transliteration with options
print("\n--- Transliteration with Options ---")

// Skip SGML option
var options = Sanscript.Defaults()
options.skipSgml = true
let textWithHTML = "na<b>ma</b>ste"
let resultWithSkipSGML = Sanscript.t(textWithHTML, from: "iast", to: "devanagari", options: options)
print("With skip_sgml=true: \(textWithHTML) -> \(resultWithSkipSGML)")

// Preferred alternates option
options = Sanscript.Defaults()
options.preferredAlternates = ["iast": ["ṃ": "ṁ"]]
let textWithAlternates = "saṃskr̥ta"
let resultWithPreferredAlternates = Sanscript.t(textWithAlternates, from: "iast", to: "iast", options: options)
print("With preferred_alternates: \(textWithAlternates) -> \(resultWithPreferredAlternates)")

// Toggling transliteration
print("\n--- Toggling Transliteration ---")
let textWithToggle = "na##ma##ste"
let resultWithToggle = Sanscript.t(textWithToggle, from: "iast", to: "devanagari")
print("With toggling: \(textWithToggle) -> \(resultWithToggle)")

// Wordwise transliteration
print("\n--- Wordwise Transliteration ---")
let sentence = "namaste duniya"
let wordwiseResult = sanscript.transliterateWordwise(data: sentence, from: "iast", to: "devanagari")
print("Wordwise transliteration:")
for (original, transliterated) in wordwiseResult {
    print("\(original) -> \(transliterated)")
}

// Complex examples
print("\n--- Complex Examples ---")
let complexText = "śrīmadbhagavadgītā"
let complexResult = Sanscript.t(complexText, from: "iast", to: "devanagari")
print("Complex text: \(complexText) -> \(complexResult)")

// Performance test
print("\n--- Performance Test ---")
let start = Date()
let longText = String(repeating: "namaste ", count: 1000)
let _ = Sanscript.t(longText, from: "iast", to: "devanagari")
let end = Date()
let timeInterval = end.timeIntervalSince(start)
print("Transliterated 1000 repetitions in \(timeInterval) seconds")
