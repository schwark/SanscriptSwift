/**
 * TOMLParser
 *
 * An optimized TOML parser for loading scheme files used by Sanscript
 * 
 * License: MIT
 */

import Foundation

/// Error types for TOML parsing
public enum TOMLParserError: Error {
    case invalidSyntax(String)
    case fileNotFound(String)
    case readError(String)
    case invalidArrayFormat(String)
}

/// A cache for storing parsed TOML files
public class TOMLCache {
    /// Singleton instance
    public static let shared = TOMLCache()
    
    /// Cache storage
    private var cache: [String: [String: [String: Any]]] = [:]
    
    /// Get a cached scheme or nil if not cached
    /// - Parameter filePath: Path to the TOML file
    /// - Returns: Cached scheme or nil
    public func getScheme(filePath: String) -> [String: [String: Any]]? {
        return cache[filePath]
    }
    
    /// Cache a scheme
    /// - Parameters:
    ///   - filePath: Path to the TOML file
    ///   - scheme: Parsed scheme
    public func cacheScheme(filePath: String, scheme: [String: [String: Any]]) {
        cache[filePath] = scheme
    }
    
    /// Clear the cache
    public func clearCache() {
        cache.removeAll()
    }
}

/// An optimized TOML parser specifically designed for Sanscript scheme files
public class TOMLParser {
    /// Parse a TOML file and return a dictionary representation
    /// - Parameter filePath: Path to the TOML file
    /// - Returns: Dictionary representation of the TOML file
    /// - Throws: TOMLParserError if parsing fails
    public static func parse(filePath: String) throws -> [String: [String: Any]] {
        // Check cache first
        if let cachedScheme = TOMLCache.shared.getScheme(filePath: filePath) {
            return cachedScheme
        }
        
        guard let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            throw TOMLParserError.readError("Failed to read file at \(filePath)")
        }
        
        let result = try parse(string: fileContents)
        
        // Cache the result
        TOMLCache.shared.cacheScheme(filePath: filePath, scheme: result)
        
        return result
    }
    
    /// Parse a TOML string and return a dictionary representation
    /// - Parameter string: TOML string to parse
    /// - Returns: Dictionary representation of the TOML string
    /// - Throws: TOMLParserError if parsing fails
    public static func parse(string: String) throws -> [String: [String: Any]] {
        var result: [String: [String: Any]] = [:]
        var currentSection: String = ""
        
        // Use NSString for more efficient line splitting
        let nsString = string as NSString
        let lines = nsString.components(separatedBy: .newlines)
        
        for (lineNumber, line) in lines.enumerated() {
            // Skip empty lines and comments efficiently
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                continue
            }
            
            // Check for section header
            if trimmedLine.hasPrefix("[") && trimmedLine.hasSuffix("]") {
                let startIndex = trimmedLine.index(after: trimmedLine.startIndex)
                let endIndex = trimmedLine.index(before: trimmedLine.endIndex)
                currentSection = String(trimmedLine[startIndex..<endIndex])
                
                if result[currentSection] == nil {
                    result[currentSection] = [:]
                }
                
                continue
            }
            
            // Parse key-value pairs
            if let separatorRange = trimmedLine.range(of: "=") {
                let key = trimmedLine[..<separatorRange.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = trimmedLine[separatorRange.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                
                if currentSection.isEmpty {
                    throw TOMLParserError.invalidSyntax("Key-value pair outside of section at line \(lineNumber + 1)")
                }
                
                // Handle string values (with quotes)
                if value.hasPrefix("\"") && value.hasSuffix("\"") {
                    let startIndex = value.index(after: value.startIndex)
                    let endIndex = value.index(before: value.endIndex)
                    let cleanValue = String(value[startIndex..<endIndex])
                        .replacingOccurrences(of: "\\\"", with: "\"")
                        .replacingOccurrences(of: "\\\\", with: "\\")
                    
                    result[currentSection]?[key] = cleanValue
                } 
                // Handle array values (for alternates)
                else if value.hasPrefix("[") && value.hasSuffix("]") {
                    let startIndex = value.index(after: value.startIndex)
                    let endIndex = value.index(before: value.endIndex)
                    let arrayString = String(value[startIndex..<endIndex])
                    
                    // Parse the array elements
                    var arrayElements: [String] = []
                    var currentElement = ""
                    var insideQuotes = false
                    
                    for char in arrayString {
                        if char == "\"" && (currentElement.isEmpty || !currentElement.hasSuffix("\\")) {
                            insideQuotes = !insideQuotes
                            currentElement.append(char)
                        } else if char == "," && !insideQuotes {
                            // End of element
                            let trimmedElement = currentElement.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmedElement.isEmpty {
                                // Clean up quoted strings
                                if trimmedElement.hasPrefix("\"") && trimmedElement.hasSuffix("\"") {
                                    let startIdx = trimmedElement.index(after: trimmedElement.startIndex)
                                    let endIdx = trimmedElement.index(before: trimmedElement.endIndex)
                                    let cleanElement = String(trimmedElement[startIdx..<endIdx])
                                        .replacingOccurrences(of: "\\\"", with: "\"")
                                        .replacingOccurrences(of: "\\\\", with: "\\")
                                    arrayElements.append(cleanElement)
                                } else {
                                    arrayElements.append(trimmedElement)
                                }
                            }
                            currentElement = ""
                        } else {
                            currentElement.append(char)
                        }
                    }
                    
                    // Add the last element
                    let trimmedElement = currentElement.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedElement.isEmpty {
                        // Clean up quoted strings
                        if trimmedElement.hasPrefix("\"") && trimmedElement.hasSuffix("\"") {
                            let startIdx = trimmedElement.index(after: trimmedElement.startIndex)
                            let endIdx = trimmedElement.index(before: trimmedElement.endIndex)
                            let cleanElement = String(trimmedElement[startIdx..<endIdx])
                                .replacingOccurrences(of: "\\\"", with: "\"")
                                .replacingOccurrences(of: "\\\\", with: "\\")
                            arrayElements.append(cleanElement)
                        } else {
                            arrayElements.append(trimmedElement)
                        }
                    }
                    
                    result[currentSection]?[key] = arrayElements
                }
                // Handle simple values
                else {
                    result[currentSection]?[key] = value
                }
                
                continue
            }
            
            // If we get here, the line is not a valid TOML syntax
            throw TOMLParserError.invalidSyntax("Invalid syntax at line \(lineNumber + 1): \(line)")
        }
        
        return result
    }
    
    /// Load multiple TOML files in parallel
    /// - Parameter filePaths: Array of file paths to load
    /// - Returns: Dictionary of file paths to parsed TOML
    /// - Throws: TOMLParserError if loading fails
    public static func parseMultiple(filePaths: [String]) throws -> [String: [String: [String: Any]]] {
        var result: [String: [String: [String: Any]]] = [:]
        var errors: [Error] = []
        
        let dispatchGroup = DispatchGroup()
        let queue = DispatchQueue(label: "com.sanscript.toml-parsing", attributes: .concurrent)
        let resultQueue = DispatchQueue(label: "com.sanscript.toml-results")
        
        for filePath in filePaths {
            dispatchGroup.enter()
            queue.async {
                do {
                    let parsed = try parse(filePath: filePath)
                    resultQueue.async {
                        result[filePath] = parsed
                        dispatchGroup.leave()
                    }
                } catch {
                    resultQueue.async {
                        errors.append(error)
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.wait()
        
        if !errors.isEmpty {
            throw errors.first!
        }
        
        return result
    }
}

/// Extension to load scheme files for Sanscript
extension Sanscript {
    /// Load a scheme from a TOML file
    /// - Parameters:
    ///   - filePath: Path to the TOML file
    ///   - isRoman: Whether this is a Roman scheme
    /// - Throws: TOMLParserError if loading fails
    public func loadSchemeFromTOML(filePath: String, isRoman: Bool) throws {
        let scheme = try TOMLParser.parse(filePath: filePath)
        let schemeName = URL(fileURLWithPath: filePath).deletingPathExtension().lastPathComponent
        
        // Convert the scheme to the format expected by Sanscript
        var schemeWithMetadata: [String: [String: String]] = [:]
        
        for (section, sectionData) in scheme {
            schemeWithMetadata[section] = [:]
            
            for (key, value) in sectionData {
                if let stringValue = value as? String {
                    schemeWithMetadata[section]?[key] = stringValue
                } else if let arrayValue = value as? [String] {
                    // For arrays, we store them as a comma-separated string for now
                    // The Sanscript class will handle them specially
                    schemeWithMetadata[section]?[key] = arrayValue.joined(separator: ",")
                }
            }
        }
        
        if isRoman {
            schemeWithMetadata["isRomanScheme"] = ["true": "true"]
            addRomanScheme(name: schemeName, scheme: schemeWithMetadata)
        } else {
            addBrahmicScheme(name: schemeName, scheme: schemeWithMetadata)
        }
    }
    
    /// Load all schemes from the common_maps directory
    /// - Parameter baseDirectory: Base directory containing common_maps
    /// - Throws: TOMLParserError if loading fails
    public func loadAllSchemes(baseDirectory: String) throws {
        let brahmicDirectory = "\(baseDirectory)/Sources/SanscriptSwift/Resources/common_maps/brahmic"
        let romanDirectory = "\(baseDirectory)/Sources/SanscriptSwift/Resources/common_maps/roman"
        
        let fileManager = FileManager.default
        
        var filePaths: [String] = []
        var isRomanMap: [String: Bool] = [:]
        
        // Collect all file paths
        if let brahmicFiles = try? fileManager.contentsOfDirectory(atPath: brahmicDirectory) {
            for file in brahmicFiles where file.hasSuffix(".toml") {
                let path = "\(brahmicDirectory)/\(file)"
                filePaths.append(path)
                isRomanMap[path] = false
            }
        }
        
        if let romanFiles = try? fileManager.contentsOfDirectory(atPath: romanDirectory) {
            for file in romanFiles where file.hasSuffix(".toml") {
                let path = "\(romanDirectory)/\(file)"
                filePaths.append(path)
                isRomanMap[path] = true
            }
        }
        
        // Parse all files in parallel
        let parsedFiles = try TOMLParser.parseMultiple(filePaths: filePaths)
        
        // Add schemes
        for (filePath, scheme) in parsedFiles {
            let schemeName = URL(fileURLWithPath: filePath).deletingPathExtension().lastPathComponent
            
            // Convert the scheme to the format expected by Sanscript
            var schemeWithMetadata: [String: [String: String]] = [:]
            
            for (section, sectionData) in scheme {
                schemeWithMetadata[section] = [:]
                
                for (key, value) in sectionData {
                    if let stringValue = value as? String {
                        schemeWithMetadata[section]?[key] = stringValue
                    } else if let arrayValue = value as? [String] {
                        // For arrays, we store them as a comma-separated string for now
                        // The Sanscript class will handle them specially
                        schemeWithMetadata[section]?[key] = arrayValue.joined(separator: ",")
                    }
                }
            }
            
            if isRomanMap[filePath] == true {
                schemeWithMetadata["isRomanScheme"] = ["true": "true"]
                addRomanScheme(name: schemeName, scheme: schemeWithMetadata)
            } else {
                addBrahmicScheme(name: schemeName, scheme: schemeWithMetadata)
            }
        }
    }
    
    /// Load schemes from bundle resources
    /// - Throws: TOMLParserError if loading fails
    public func loadSchemesFromBundle() throws {
        let bundle = Bundle(for: Sanscript.self)
        
        guard let brahmicURL = bundle.url(forResource: "brahmic", withExtension: nil, subdirectory: "Resources/common_maps"),
              let romanURL = bundle.url(forResource: "roman", withExtension: nil, subdirectory: "Resources/common_maps") else {
            throw TOMLParserError.fileNotFound("Could not find common_maps directory in bundle")
        }
        
        var filePaths: [String] = []
        var isRomanMap: [String: Bool] = [:]
        
        // Get all TOML files in the brahmic directory
        if let brahmicFiles = try? FileManager.default.contentsOfDirectory(at: brahmicURL, includingPropertiesForKeys: nil) {
            for fileURL in brahmicFiles where fileURL.pathExtension == "toml" {
                filePaths.append(fileURL.path)
                isRomanMap[fileURL.path] = false
            }
        }
        
        // Get all TOML files in the roman directory
        if let romanFiles = try? FileManager.default.contentsOfDirectory(at: romanURL, includingPropertiesForKeys: nil) {
            for fileURL in romanFiles where fileURL.pathExtension == "toml" {
                filePaths.append(fileURL.path)
                isRomanMap[fileURL.path] = true
            }
        }
        
        // Parse all files in parallel
        let parsedFiles = try TOMLParser.parseMultiple(filePaths: filePaths)
        
        // Add schemes
        for (filePath, scheme) in parsedFiles {
            let schemeName = URL(fileURLWithPath: filePath).deletingPathExtension().lastPathComponent
            
            // Convert the scheme to the format expected by Sanscript
            var schemeWithMetadata: [String: [String: String]] = [:]
            
            for (section, sectionData) in scheme {
                schemeWithMetadata[section] = [:]
                
                for (key, value) in sectionData {
                    if let stringValue = value as? String {
                        schemeWithMetadata[section]?[key] = stringValue
                    } else if let arrayValue = value as? [String] {
                        // For arrays, we store them as a comma-separated string for now
                        schemeWithMetadata[section]?[key] = arrayValue.joined(separator: ",")
                    }
                }
            }
            
            if isRomanMap[filePath] == true {
                schemeWithMetadata["isRomanScheme"] = ["true": "true"]
                addRomanScheme(name: schemeName, scheme: schemeWithMetadata)
            } else {
                addBrahmicScheme(name: schemeName, scheme: schemeWithMetadata)
            }
        }
    }
}
