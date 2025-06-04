import Foundation
import SanscriptSwift
import Toml

// Define TestCase structures
struct TestCase: Codable {
    let input: String
    let expected: String
    let from: String?
    let to: String?
    
    init(input: String, expected: String, from: String? = nil, to: String? = nil) {
        self.input = input
        self.expected = expected
        self.from = from
        self.to = to
    }
}

struct TestCases: Codable {
    let iast_to_devanagari: [TestCase]
    let itrans_dravidian_to_telugu: [TestCase]
    let consonant_clusters: [TestCase]
}

print("SanscriptSwift CLI")
print("=================")

// Create a Sanscript instance
let sanscript = Sanscript.shared

// Parse command line arguments
let args = CommandLine.arguments
let isDebug = args.contains("--debug")

// Set debug flags based on command line argument
Sanscript.debug = isDebug
tomlParserDebug = isDebug

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
                if isDebug {
                    print("Loaded Brahmic scheme: \(schemeName)")
                }
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
                if isDebug {
                    print("Loaded Roman scheme: \(schemeName)")
                }
            } catch {
                print("Warning: Failed to load Roman scheme \(schemeName): \(error)")
            }
        }
    }
    
    // Check if we have the required schemes for our tests
    if sanscript.schemes["devanagari"] != nil && sanscript.schemes["iast"] != nil {
        if isDebug {
            print("Required schemes loaded successfully")
        }
    } else {
        print("Error: Required schemes 'devanagari' and/or 'iast' were not loaded")
        exit(1)
    }
}

// Function to run transliteration
func transliterate(text: String, from: String, to: String) -> String {
    return Sanscript.t(text, from: from, to: to)
}

// Function to run tests
func runTests(debug: Bool) {
    // Load test cases from JSON file
    let testCasesURL = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("test_cases.json")
    
    do {
        let testCasesData = try Data(contentsOf: testCasesURL)
        
        do {
            let testCases = try JSONDecoder().decode(TestCases.self, from: testCasesData)
            
            // Run IAST to Devanagari tests
            print("\nIAST to Devanagari tests:")
            var totalTests = 0
            var passedTests = 0
            
            for test in testCases.iast_to_devanagari {
                totalTests += 1
                let result = transliterate(text: test.input, from: "iast", to: "devanagari")
                let matches = result == test.expected
                if matches {
                    passedTests += 1
                }
                
                if debug {
                    print("\nTesting IAST to Devanagari: '\(test.input)'")
                    print("==== TRANSLITERATE ROMAN DEBUG ====")
                    print("Input: \(test.input)")
                    print("==== END TRANSLITERATE ROMAN DEBUG ====")
                    print("  '\(test.input)' -> '\(result)'")
                    print("    Expected: '\(test.expected)'")
                    print("    Matches: \(matches ? "✓" : "✗")")
                    
                    // Test character pairs for debugging
                    if test.input.count >= 2 {
                        print("  Character pairs:")
                        for i in 0..<(test.input.count-1) {
                            let startIndex = test.input.index(test.input.startIndex, offsetBy: i)
                            let endIndex = test.input.index(test.input.startIndex, offsetBy: i+2)
                            let pair = String(test.input[startIndex..<endIndex])
                            let pairResult = transliterate(text: pair, from: "iast", to: "devanagari")
                            print("    \(i)-\(i+1): '\(pair)' -> '\(pairResult)'")
                        }
                    }
                } else if !matches {
                    print("  '\(test.input)' -> '\(result)' (Expected: '\(test.expected)') ✗")
                }
            }
            print("IAST to Devanagari: \(passedTests)/\(totalTests) tests passed")
            
            // Run ITRANS_DRAVIDIAN to Telugu tests
            print("\nITRANS_DRAVIDIAN to Telugu tests:")
            totalTests = 0
            passedTests = 0
            
            for test in testCases.itrans_dravidian_to_telugu {
                totalTests += 1
                let result = transliterate(text: test.input, from: "itrans_dravidian", to: "telugu")
                let matches = result == test.expected
                if matches {
                    passedTests += 1
                }
                
                if debug {
                    print("\nTesting ITRANS_DRAVIDIAN to Telugu: '\(test.input)'")
                    print("==== TRANSLITERATE ROMAN DEBUG ====")
                    print("Input: \(test.input)")
                    print("==== END TRANSLITERATE ROMAN DEBUG ====")
                    print("  '\(test.input)' -> '\(result)'")
                    print("    Expected: '\(test.expected)'")
                    print("    Matches: \(matches ? "✓" : "✗")")
                } else if !matches {
                    print("  '\(test.input)' -> '\(result)' (Expected: '\(test.expected)') ✗")
                }
            }
            print("ITRANS_DRAVIDIAN to Telugu: \(passedTests)/\(totalTests) tests passed")
            
            // Run consonant cluster tests
            print("\nConsonant cluster tests:")
            totalTests = 0
            passedTests = 0
            
            for test in testCases.consonant_clusters {
                totalTests += 1
                guard let from = test.from, let to = test.to else { continue }
                let result = transliterate(text: test.input, from: from, to: to)
                let matches = result == test.expected
                if matches {
                    passedTests += 1
                }
                
                if debug {
                    print("\nDetailed test for '\(test.input)' from \(from) to \(to):")
                    print("==== TRANSLITERATE ROMAN DEBUG ====")
                    print("Input: \(test.input)")
                    print("==== END TRANSLITERATE ROMAN DEBUG ====")
                    print("  '\(test.input)' -> '\(result)'")
                    print("    Expected: '\(test.expected)'")
                    print("    Matches: \(matches ? "✓" : "✗")")
                } else if !matches {
                    print("  '\(test.input)' -> '\(result)' (Expected: '\(test.expected)') ✗")
                }
            }
            print("Consonant clusters: \(passedTests)/\(totalTests) tests passed")
        } catch {
            print("Error: Could not decode test_cases.json - \(error)")
            exit(1)
        }
    } catch {
        print("Error: Could not load test_cases.json - \(error)")
        exit(1)
    }
}

// Function to print usage
func printUsage() {
    print("Usage:")
    print("  SanscriptCLI [--debug]                      Run all tests")
    print("  SanscriptCLI <text> <from> <to>            Transliterate text")
    print("  SanscriptCLI --text=<text>                  Specify text to transliterate")
    print("  SanscriptCLI --from=<scheme>               Specify source scheme")
    print("  SanscriptCLI --to=<scheme>                 Specify target scheme")
    print("  SanscriptCLI --list                         List available schemes")
    print("  SanscriptCLI --help                         Show this help")
    print("")
    print("Examples:")
    print("  SanscriptCLI 'namaste' iast devanagari")
    print("  SanscriptCLI --text='namaste' --from=iast --to=devanagari")
}

// Function to list available schemes
func listSchemes() {
    print("Available schemes:")
    let schemes = sanscript.schemes.keys.sorted()
    let brahmicSchemes = schemes.filter { scheme in 
        sanscript.schemes[scheme]?["isRomanScheme"] == nil 
    }
    let romanSchemes = schemes.filter { scheme in 
        sanscript.schemes[scheme]?["isRomanScheme"] != nil 
    }
    print("  Brahmic schemes: \(brahmicSchemes.joined(separator: ", "))")
    print("  Roman schemes: \(romanSchemes.joined(separator: ", "))")
}

// Function to parse named parameters
func parseNamedParameters() -> (text: String?, from: String?, to: String?) {
    var text: String? = nil
    var from: String? = nil
    var to: String? = nil
    
    // Skip the first argument (program name)
    for arg in args.dropFirst() {
        if arg == "--debug" { continue } // Skip debug flag
        
        if arg.hasPrefix("--text=") {
            text = String(arg.dropFirst("--text=".count))
        } else if arg.hasPrefix("--from=") {
            from = String(arg.dropFirst("--from=".count))
        } else if arg.hasPrefix("--to=") {
            to = String(arg.dropFirst("--to=".count))
        }
    }
    
    return (text, from, to)
}

// Function to validate schemes
func validateScheme(scheme: String, isSource: Bool) -> Bool {
    if !sanscript.schemes.keys.contains(scheme) {
        print("Error: Unknown \(isSource ? "source" : "target") scheme '\(scheme)'")
        print("Use --list to see available schemes")
        return false
    }
    return true
}

// Check if we have transliteration parameters
func hasTransliterationParameters() -> Bool {
    // Check for positional parameters (text from to)
    if args.count == 4 && !args[1].hasPrefix("--") {
        return true
    }
    
    // Check for named parameters
    let params = parseNamedParameters()
    return params.text != nil || params.from != nil || params.to != nil
}

// Main logic

// First check for specific commands
if args.count == 2 && args[1] == "--list" {
    // List schemes
    listSchemes()
    exit(0)
} else if args.count == 2 && args[1] == "--help" {
    // Show help
    printUsage()
    exit(0)
}

// Then check for transliteration parameters - these take precedence over tests
if args.count == 4 && !args[1].hasPrefix("--") {
    // Positional parameters: <text> <from> <to>
    let text = args[1]
    let from = args[2]
    let to = args[3]
    
    if !validateScheme(scheme: from, isSource: true) || !validateScheme(scheme: to, isSource: false) {
        exit(1)
    }
    
    let result = transliterate(text: text, from: from, to: to)
    print(result)
    exit(0)
} else {
    // Try to parse named parameters
    let params = parseNamedParameters()
    
    if let text = params.text, let from = params.from, let to = params.to {
        if !validateScheme(scheme: from, isSource: true) || !validateScheme(scheme: to, isSource: false) {
            exit(1)
        }
        
        let result = transliterate(text: text, from: from, to: to)
        print(result)
        exit(0)
    } else if params.text != nil || params.from != nil || params.to != nil {
        // Some transliteration parameters were provided, but not all required ones
        print("Error: Missing required parameters")
        if params.text == nil { print("  Missing text to transliterate (--text=<text>)") }
        if params.from == nil { print("  Missing source scheme (--from=<scheme>)") }
        if params.to == nil { print("  Missing target scheme (--to=<scheme>)") }
        print("")
        printUsage()
        exit(1)
    }
}

// If no transliteration parameters were provided, run tests
if args.count == 1 || (args.count == 2 && args[1] == "--debug") {
    runTests(debug: isDebug)
} else {
    // Invalid arguments
    print("Error: Invalid arguments")
    printUsage()
    exit(1)
}
