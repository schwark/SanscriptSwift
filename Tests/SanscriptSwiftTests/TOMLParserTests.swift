import XCTest
@testable import SanscriptSwift

final class TOMLParserTests: XCTestCase {
    
    func testBasicTOMLParsing() throws {
        // Create a simple TOML string
        let tomlString = """
        [section1]
        key1 = "value1"
        key2 = "value2"
        
        [section2]
        key3 = "value3"
        key4 = "value4"
        """
        
        // Parse the TOML string
        let result = try TOMLParser.parse(string: tomlString)
        
        // Verify the result
        XCTAssertEqual(result.count, 2)
        XCTAssertNotNil(result["section1"])
        XCTAssertNotNil(result["section2"])
        
        XCTAssertEqual(result["section1"]?["key1"] as? String, "value1")
        XCTAssertEqual(result["section1"]?["key2"] as? String, "value2")
        XCTAssertEqual(result["section2"]?["key3"] as? String, "value3")
        XCTAssertEqual(result["section2"]?["key4"] as? String, "value4")
    }
    
    func testArrayParsing() throws {
        // Create a TOML string with arrays
        let tomlString = """
        [alternates]
        "ā" = ["aa", "A"]
        "ī" = ["ii", "I"]
        """
        
        // Parse the TOML string
        let result = try TOMLParser.parse(string: tomlString)
        
        // Verify the result
        XCTAssertNotNil(result["alternates"])
        
        let alternates = result["alternates"]!
        XCTAssertEqual((alternates["ā"] as? [String])?.count, 2)
        XCTAssertEqual((alternates["ā"] as? [String])?[0], "aa")
        XCTAssertEqual((alternates["ā"] as? [String])?[1], "A")
        
        XCTAssertEqual((alternates["ī"] as? [String])?.count, 2)
        XCTAssertEqual((alternates["ī"] as? [String])?[0], "ii")
        XCTAssertEqual((alternates["ī"] as? [String])?[1], "I")
    }
    
    func testCommaSeparatedArrayParsing() throws {
        // Create a TOML string with comma-separated values that should be parsed as arrays
        let tomlString = """
        [alternates]
        "ā" = "aa,A"
        "ī" = "ii,I"
        """
        
        // Parse the TOML string
        let result = try TOMLParser.parse(string: tomlString)
        
        // Verify the result
        XCTAssertNotNil(result["alternates"])
        
        let alternates = result["alternates"]!
        
        // In our implementation, these should be strings that will be processed by Sanscript
        XCTAssertEqual(alternates["ā"] as? String, "aa,A")
        XCTAssertEqual(alternates["ī"] as? String, "ii,I")
    }
    
    func testCommentHandling() throws {
        // Create a TOML string with comments
        let tomlString = """
        # This is a comment
        [section1] # This is a section comment
        key1 = "value1" # This is a value comment
        
        # Another comment
        [section2]
        key2 = "value2"
        """
        
        // Parse the TOML string
        let result = try TOMLParser.parse(string: tomlString)
        
        // Verify the result
        XCTAssertEqual(result.count, 2)
        XCTAssertNotNil(result["section1"])
        XCTAssertNotNil(result["section2"])
        
        XCTAssertEqual(result["section1"]?["key1"] as? String, "value1")
        XCTAssertEqual(result["section2"]?["key2"] as? String, "value2")
    }
    
    func testEmptyLinesHandling() throws {
        // Create a TOML string with empty lines
        let tomlString = """
        
        [section1]
        
        key1 = "value1"
        
        [section2]
        key2 = "value2"
        
        """
        
        // Parse the TOML string
        let result = try TOMLParser.parse(string: tomlString)
        
        // Verify the result
        XCTAssertEqual(result.count, 2)
        XCTAssertNotNil(result["section1"])
        XCTAssertNotNil(result["section2"])
        
        XCTAssertEqual(result["section1"]?["key1"] as? String, "value1")
        XCTAssertEqual(result["section2"]?["key2"] as? String, "value2")
    }
    
    func testInvalidSyntax() {
        // Create a TOML string with invalid syntax
        let tomlString = """
        [section1]
        key1 = "value1"
        invalid_line
        key2 = "value2"
        """
        
        // Verify that parsing throws an error
        XCTAssertThrowsError(try TOMLParser.parse(string: tomlString)) { error in
            guard case TOMLParserError.invalidSyntax = error else {
                XCTFail("Expected invalidSyntax error, got \(error)")
                return
            }
        }
    }
    
    func testKeyValueOutsideSection() {
        // Create a TOML string with key-value outside of section
        let tomlString = """
        key1 = "value1"
        
        [section1]
        key2 = "value2"
        """
        
        // Verify that parsing throws an error
        XCTAssertThrowsError(try TOMLParser.parse(string: tomlString)) { error in
            guard case TOMLParserError.invalidSyntax = error else {
                XCTFail("Expected invalidSyntax error, got \(error)")
                return
            }
        }
    }
    
    func testCaching() throws {
        // Create a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("test.toml")
        
        let tomlString = """
        [section1]
        key1 = "value1"
        key2 = "value2"
        """
        
        try tomlString.write(to: tempFile, atomically: true, encoding: .utf8)
        
        // Clear the cache
        TOMLCache.shared.clearCache()
        
        // Parse the file for the first time
        let _ = try TOMLParser.parse(filePath: tempFile.path)
        
        // Modify the file
        let newTomlString = """
        [section1]
        key1 = "modified"
        key2 = "value2"
        """
        
        try newTomlString.write(to: tempFile, atomically: true, encoding: .utf8)
        
        // Parse the file again (should use cache)
        let result = try TOMLParser.parse(filePath: tempFile.path)
        
        // Verify that we got the cached result, not the modified file
        XCTAssertEqual(result["section1"]?["key1"] as? String, "value1")
        
        // Clean up
        try FileManager.default.removeItem(at: tempFile)
    }
    
    func testParallelParsing() throws {
        // Create temporary files
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile1 = tempDir.appendingPathComponent("test1.toml")
        let tempFile2 = tempDir.appendingPathComponent("test2.toml")
        
        let tomlString1 = """
        [section1]
        key1 = "value1"
        """
        
        let tomlString2 = """
        [section2]
        key2 = "value2"
        """
        
        try tomlString1.write(to: tempFile1, atomically: true, encoding: .utf8)
        try tomlString2.write(to: tempFile2, atomically: true, encoding: .utf8)
        
        // Clear the cache
        TOMLCache.shared.clearCache()
        
        // Parse multiple files in parallel
        let results = try TOMLParser.parseMultiple(filePaths: [tempFile1.path, tempFile2.path])
        
        // Verify the results
        XCTAssertEqual(results.count, 2)
        XCTAssertNotNil(results[tempFile1.path])
        XCTAssertNotNil(results[tempFile2.path])
        
        XCTAssertEqual(results[tempFile1.path]?["section1"]?["key1"] as? String, "value1")
        XCTAssertEqual(results[tempFile2.path]?["section2"]?["key2"] as? String, "value2")
        
        // Clean up
        try FileManager.default.removeItem(at: tempFile1)
        try FileManager.default.removeItem(at: tempFile2)
    }
    
    func testSanscriptIntegration() throws {
        // Create temporary scheme files
        let tempDir = FileManager.default.temporaryDirectory
        let brahmicDir = tempDir.appendingPathComponent("Sources/SanscriptSwift/Resources/common_maps/brahmic")
        let romanDir = tempDir.appendingPathComponent("Sources/SanscriptSwift/Resources/common_maps/roman")
        
        try FileManager.default.createDirectory(at: brahmicDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: romanDir, withIntermediateDirectories: true)
        
        // Create a simple Devanagari TOML file
        let devanagariTOML = """
        [vowels]
        "अ" = "a"
        "आ" = "ā"
        
        [consonants]
        "क" = "ka"
        "ख" = "kha"
        
        [virama]
        "्" = ""
        """
        
        // Create a simple IAST TOML file
        let iastTOML = """
        [vowels]
        "अ" = "a"
        "आ" = "ā"
        
        [consonants]
        "क" = "k"
        "ख" = "kh"
        
        [virama]
        "्" = ""
        
        [alternates]
        "ā" = "aa,A"
        
        [isRomanScheme]
        "true" = "true"
        """
        
        try devanagariTOML.write(to: brahmicDir.appendingPathComponent("devanagari.toml"), atomically: true, encoding: .utf8)
        try iastTOML.write(to: romanDir.appendingPathComponent("iast.toml"), atomically: true, encoding: .utf8)
        
        // Create a Sanscript instance and load the schemes
        let sanscript = Sanscript()
        try sanscript.loadAllSchemes(baseDirectory: tempDir.path)
        
        // Verify that the schemes were loaded
        XCTAssertNotNil(sanscript.schemes["devanagari"])
        XCTAssertNotNil(sanscript.schemes["iast"])
        
        // Test transliteration
        let result = sanscript.t(data: "का", from: "devanagari", to: "iast")
        XCTAssertEqual(result, "kā")
        
        // Clean up
        try FileManager.default.removeItem(at: tempDir)
    }
}
