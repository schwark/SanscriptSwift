import XCTest
@testable import SanscriptSwift

final class SanscriptTests: XCTestCase {
    let sanscript = Sanscript.shared
    
    override func setUp() {
        super.setUp()
        
        // Create test schemes for testing without loading from files
        setupTestSchemes()
    }
    
    func setupTestSchemes() {
        // Add a basic Devanagari scheme for testing
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
        
        // Add a basic IAST scheme for testing
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
        
        // Add a basic ITRANS scheme for testing
        let itransScheme: [String: [String: String]] = [
            "vowels": [
                "अ": "a",
                "आ": "A",
                "इ": "i",
                "ई": "I",
                "उ": "u",
                "ऊ": "U",
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
                "ङ": "G",
                "च": "ch",
                "छ": "Ch",
                "ज": "j",
                "झ": "jh",
                "ञ": "J",
                "ट": "T",
                "ठ": "Th",
                "ड": "D",
                "ढ": "Dh",
                "ण": "N",
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
                "श": "sh",
                "ष": "Sh",
                "स": "s",
                "ह": "h"
            ],
            "virama": [
                "्": ""
            ],
            "yogavaahas": [
                "ं": "M",
                "ः": "H"
            ],
            "isRomanScheme": [
                "true": "true"
            ]
        ]
        
        sanscript.addBrahmicScheme(name: "devanagari", scheme: devanagariScheme)
        sanscript.addRomanScheme(name: "iast", scheme: iastScheme)
        sanscript.addRomanScheme(name: "itrans", scheme: itransScheme)
    }
    
    func testDevanagariToIAST() {
        // Test basic transliteration from Devanagari to IAST
        let devanagariText = "नमस्ते"
        let expectedIAST = "namaste"
        
        let result = Sanscript.t(devanagariText, from: "devanagari", to: "iast")
        XCTAssertEqual(result, expectedIAST, "Devanagari to IAST transliteration failed")
    }
    
    func testIASTToDevanagari() {
        // Test basic transliteration from IAST to Devanagari
        let iastText = "namaste"
        let expectedDevanagari = "नमस्ते"
        
        let result = Sanscript.t(iastText, from: "iast", to: "devanagari")
        XCTAssertEqual(result, expectedDevanagari, "IAST to Devanagari transliteration failed")
    }
    
    func testITRANSToDevanagari() {
        // Test basic transliteration from ITRANS to Devanagari
        let itransText = "namaste"
        let expectedDevanagari = "नमस्ते"
        
        let result = Sanscript.t(itransText, from: "itrans", to: "devanagari")
        XCTAssertEqual(result, expectedDevanagari, "ITRANS to Devanagari transliteration failed")
    }
    
    func testWithSkipSGMLOption() {
        // Test transliteration with skip_sgml option
        let textWithHTML = "na<b>ma</b>ste"
        let expectedWithSkip = "न<b>म</b>स्ते"
        let expectedWithoutSkip = "न<ब्>म</ब्>स्ते"
        
        var options = Sanscript.Defaults()
        options.skipSgml = true
        
        let resultWithSkip = Sanscript.t(textWithHTML, from: "iast", to: "devanagari", options: options)
        XCTAssertEqual(resultWithSkip, expectedWithSkip, "Transliteration with skip_sgml=true failed")
        
        options.skipSgml = false
        let resultWithoutSkip = Sanscript.t(textWithHTML, from: "iast", to: "devanagari", options: options)
        XCTAssertEqual(resultWithoutSkip, expectedWithoutSkip, "Transliteration with skip_sgml=false failed")
    }
    
    func testWithSyncopeOption() {
        // Test transliteration with syncope option
        let text = "namaskara"
        let expectedWithSyncope = "नमस्कर"
        let expectedWithoutSyncope = "नमस्कर"
        
        var options = Sanscript.Defaults()
        options.syncope = true
        
        let resultWithSyncope = Sanscript.t(text, from: "iast", to: "devanagari", options: options)
        XCTAssertEqual(resultWithSyncope, expectedWithSyncope, "Transliteration with syncope=true failed")
        
        options.syncope = false
        let resultWithoutSyncope = Sanscript.t(text, from: "iast", to: "devanagari", options: options)
        XCTAssertEqual(resultWithoutSyncope, expectedWithoutSyncope, "Transliteration with syncope=false failed")
    }
    
    func testWithPreferredAlternates() {
        // Test transliteration with preferred_alternates option
        let text = "gaṃgā"
        let expectedWithPreferred = "gaṁgā"
        let expectedWithoutPreferred = "gaṃgā"
        
        var options = Sanscript.Defaults()
        options.preferredAlternates = ["iast": ["ṃ": "ṁ"]]
        
        let resultWithPreferred = Sanscript.t(text, from: "iast", to: "iast", options: options)
        XCTAssertEqual(resultWithPreferred, expectedWithPreferred, "Transliteration with preferred_alternates failed")
        
        options.preferredAlternates = [:]
        let resultWithoutPreferred = Sanscript.t(text, from: "iast", to: "iast", options: options)
        XCTAssertEqual(resultWithoutPreferred, expectedWithoutPreferred, "Transliteration without preferred_alternates failed")
    }
    
    func testTogglingTransliteration() {
        // Test toggling transliteration with ## markers
        let text = "na##ma##ste"
        let expectedDevanagari = "नमस्ते"
        
        let result = Sanscript.t(text, from: "iast", to: "devanagari")
        XCTAssertEqual(result, expectedDevanagari, "Toggling transliteration failed")
    }
    
    func testWordwiseTransliteration() {
        // Test wordwise transliteration
        let sentence = "namaste duniya"
        let expectedWords = [("namaste", "नमस्ते"), ("duniya", "दुनिय")]
        
        let result = sanscript.transliterateWordwise(data: sentence, from: "iast", to: "devanagari")
        XCTAssertEqual(result.count, expectedWords.count, "Wordwise transliteration returned wrong number of words")
        
        for (index, (original, transliterated)) in result.enumerated() {
            XCTAssertEqual(original, expectedWords[index].0, "Original word at index \(index) doesn't match")
            XCTAssertEqual(transliterated, expectedWords[index].1, "Transliterated word at index \(index) doesn't match")
        }
    }
    
    func testPerformance() {
        // Test performance of transliteration
        let longText = String(repeating: "namaste ", count: 1000)
        
        measure {
            _ = Sanscript.t(longText, from: "iast", to: "devanagari")
        }
    }
    
    func testTOMLLoading() {
        // This test requires the TOML files to be present
        // It should be skipped if running in a CI environment without the files
        
        // Create a temporary directory with test TOML files
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("sanscript-test-\(UUID().uuidString)")
        let brahmicDir = tempDir.appendingPathComponent("Sources/SanscriptSwift/Resources/common_maps/brahmic")
        let romanDir = tempDir.appendingPathComponent("Sources/SanscriptSwift/Resources/common_maps/roman")
        
        do {
            try FileManager.default.createDirectory(at: brahmicDir, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: romanDir, withIntermediateDirectories: true)
            
            // Create a simple Devanagari TOML file
            let devanagariTOML = """
            [vowels]
            "अ" = "a"
            "आ" = "ā"
            "इ" = "i"
            "ई" = "ī"
            
            [consonants]
            "क" = "ka"
            "ख" = "kha"
            "ग" = "ga"
            "घ" = "gha"
            
            [virama]
            "्" = ""
            """
            
            try devanagariTOML.write(to: brahmicDir.appendingPathComponent("devanagari.toml"), atomically: true, encoding: .utf8)
            
            // Create a simple IAST TOML file
            let iastTOML = """
            [vowels]
            "अ" = "a"
            "आ" = "ā"
            "इ" = "i"
            "ई" = "ī"
            
            [consonants]
            "क" = "k"
            "ख" = "kh"
            "ग" = "g"
            "घ" = "gh"
            
            [virama]
            "्" = ""
            
            [alternates]
            "ā" = "aa"
            
            [isRomanScheme]
            "true" = "true"
            """
            
            try iastTOML.write(to: romanDir.appendingPathComponent("iast.toml"), atomically: true, encoding: .utf8)
            
            // Test loading the schemes
            let testSanscript = Sanscript()
            try testSanscript.loadAllSchemes(baseDirectory: tempDir.path)
            
            // Verify that the schemes were loaded
            XCTAssertNotNil(testSanscript.schemes["devanagari"], "Devanagari scheme not loaded")
            XCTAssertNotNil(testSanscript.schemes["iast"], "IAST scheme not loaded")
            
            // Test transliteration with the loaded schemes
            let result = testSanscript.t(data: "का", from: "devanagari", to: "iast")
            XCTAssertEqual(result, "kā", "Transliteration with loaded schemes failed")
            
            // Clean up
            try FileManager.default.removeItem(at: tempDir)
        } catch {
            XCTFail("TOML loading test failed: \(error)")
        }
    }
    
    func testComparisonWithJavaScript() {
        // This test compares the Swift implementation with known JavaScript results
        // These test cases should match the output of the JavaScript implementation exactly
        
        let testCases: [(input: String, from: String, to: String, expected: String)] = [
            // Basic transliteration
            ("नमस्ते", "devanagari", "iast", "namaste"),
            ("namaste", "iast", "devanagari", "नमस्ते"),
            
            // With virama
            ("नमस्कार", "devanagari", "iast", "namaskāra"),
            
            // With yogavaahas
            ("संस्कृत", "devanagari", "iast", "saṃskr̥ta"),
            
            // Complex cases
            ("श्रीमद्भगवद्गीता", "devanagari", "iast", "śrīmadbhagavadgītā"),
            ("śrīmadbhagavadgītā", "iast", "devanagari", "श्रीमद्भगवद्गीता")
        ]
        
        for (index, testCase) in testCases.enumerated() {
            let result = Sanscript.t(testCase.input, from: testCase.from, to: testCase.to)
            XCTAssertEqual(result, testCase.expected, "Test case \(index) failed: \(testCase.input) from \(testCase.from) to \(testCase.to)")
        }
    }
}
