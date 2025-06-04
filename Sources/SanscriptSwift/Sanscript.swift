/**
 * Sanscript
 *
 * Sanscript is a Sanskrit transliteration library. Currently, it supports
 * other Indian languages only incidentally.
 *
 * License: MIT
 */

import Foundation

/// Main Sanscript class that provides transliteration functionality
public class Sanscript {
    /// Default options for transliteration
    public struct Defaults: Equatable {
        public var skipSgml: Bool = false
        public var syncope: Bool = false
        public var preferredAlternates: [String: [String: String]] = [:]
        
        /// Public initializer for Defaults
        public init() {}
        
        /// Equatable conformance
        public static func == (lhs: Defaults, rhs: Defaults) -> Bool {
            return lhs.skipSgml == rhs.skipSgml && 
                   lhs.syncope == rhs.syncope &&
                   lhs.preferredAlternates == rhs.preferredAlternates
        }
    }
    
    /// Transliteration schemes
    public var schemes: [String: [String: Any]] = [:]
    
    /// Set of Roman scheme names
    private var romanSchemes: Set<String> = []
    
    /// Object cache for improved performance
    private var cache: [String: Any] = [:]
    
    /// Default options
    public var defaults = Defaults()
    
    /// Singleton instance
    public static let shared = Sanscript()
    
    /// Private initializer for singleton pattern
    private init() {
        // Schemes will be loaded explicitly by the user
    }
    
    /// Static wrapper for the t method to maintain compatibility with existing code
    public static func t(_ data: String, from: String, to: String, options: Defaults? = nil) -> String {
        return shared.t(data: data, from: from, to: to, options: options)
    }
    
    /// Static wrapper for the transliterateWordwise method
    public static func transliterateWordwise(_ data: String, from: String, to: String, options: Defaults? = nil) -> [(String, String)] {
        return shared.transliterateWordwise(data: data, from: from, to: to, options: options)
    }
    
    /**
     * Add a Brahmic scheme to Sanscript.
     *
     * Schemes are of two types: "Brahmic" and "roman". Brahmic consonants
     * have an inherent vowel sound, but roman consonants do not. This is the
     * main difference between these two types of scheme.
     *
     * A scheme definition is an object that maps a group name to a
     * list of characters. For illustration, see the "devanagari" scheme.
     *
     * - Parameters:
     *   - name: The scheme name
     *   - scheme: The scheme data itself
     */
    public func addBrahmicScheme(name: String, scheme: [String: Any]) {
        schemes[name] = scheme
    }
    
    /**
     * Add a roman scheme to Sanscript.
     *
     * See the comments on addBrahmicScheme. The "vowel_marks" field
     * can be omitted.
     *
     * - Parameters:
     *   - name: The scheme name
     *   - scheme: The scheme data itself
     */
    public func addRomanScheme(name: String, scheme: [String: Any]) {
        var schemeCopy = scheme
        
        if schemeCopy["vowel_marks"] == nil {
            var vowelMarks = [String: String]()
            if let vowels = schemeCopy["vowels"] as? [String: String] {
                for (key, value) in vowels {
                    if key != "अ" {
                        vowelMarks[devanagariVowelToMarks[key] ?? ""] = value
                    }
                }
            }
            schemeCopy["vowel_marks"] = vowelMarks
        }
        
        // Mark this as a roman scheme
        schemeCopy["isRomanScheme"] = true
        
        schemes[name] = schemeCopy
        romanSchemes.insert(name)
    }
    
    /**
     * Create a map from every character in `from` to its partner in `to`.
     * Also, store any "marks" that `from` might have.
     *
     * - Parameters:
     *   - from: Input scheme
     *   - to: Output scheme
     *   - options: Scheme options
     * - Returns: A map containing the transliteration data
     */
    private func makeMap(from: String, to: String, options: Defaults) -> [String: Any] {
        var consonants = [String: String]()
        let fromScheme = schemes[from] ?? [:]
        var letters = [String: String]()
        var tokenLengths = [Int]()
        var marks = [String: String]()
        var accents = [String: String]()
        let toScheme = schemes[to] ?? [:]
        
        // Get alternates from the scheme
        let alternates = fromScheme["alternates"] as? [String: [String]] ?? [:]
        
        // Process each group in the scheme
        for (group, fromGroupAny) in fromScheme {
            // Skip special groups
            if ["alternates", "accented_vowel_alternates", "isRomanScheme"].contains(group) {
                continue
            }
            
            guard let fromGroup = fromGroupAny as? [String: String] else { continue }
            guard let toGroupAny = toScheme[group], let toGroup = toGroupAny as? [String: String] else { continue }
            
            // Process each character mapping
            for (key, F) in fromGroup {
                guard var T = toGroup[key] else { continue }
                
                // If target is empty and not in special groups, use the source value
                if T.isEmpty && !["virama", "zwj", "skip"].contains(group) {
                    T = F
                }
                
                // Get alternates for this character
                let alts = alternates[F] ?? []
                
                // Add token lengths for the character and its alternates
                tokenLengths.append(F.count)
                for alt in alts {
                    tokenLengths.append(alt.count)
                }
                
                // Add to appropriate collections based on group
                if group == "vowel_marks" || group == "virama" {
                    marks[F] = T
                    for alt in alts {
                        marks[alt] = T
                    }
                } else {
                    letters[F] = T
                    for alt in alts {
                        letters[alt] = T
                    }
                    
                    if group == "consonants" || group == "extra_consonants" {
                        consonants[F] = T
                        for alt in alts {
                            consonants[alt] = T
                        }
                    }
                    
                    if group == "accents" {
                        accents[F] = T
                        for alt in alts {
                            accents[alt] = T
                        }
                    }
                }
            }
        }
        
        // Process accented vowel alternates
        if let accentedVowelAlternates = fromScheme["accented_vowel_alternates"] as? [String: [String]] {
            for (baseAccentedVowel, synonyms) in accentedVowelAlternates {
                for accentedVowel in synonyms {
                    let baseVowel = String(baseAccentedVowel.dropLast())
                    let sourceAccent = String(baseAccentedVowel.suffix(1))
                    let targetAccent = accents[sourceAccent] ?? sourceAccent
                    
                    // Roman 'a' does not map to any Brahmic vowel mark
                    marks[accentedVowel] = (marks[baseVowel] ?? "") + targetAccent
                    
                    if letters[baseVowel] == nil {
                        print("Error: \(baseVowel), \(targetAccent), \(letters)")
                    }
                    
                    letters[accentedVowel] = (letters[baseVowel] ?? "") + targetAccent
                }
            }
        }
        
        // Get virama character from the target scheme
        let virama = (toScheme["virama"] as? [String: String])?["्"] ?? ""
        
        // Get the 'a' vowel from both schemes
        let toSchemeA = (toScheme["vowels"] as? [String: String])?["अ"] ?? ""
        let fromSchemeA = (fromScheme["vowels"] as? [String: String])?["अ"] ?? ""
        
        // Return the complete map
        return [
            "consonants": consonants,
            "accents": accents,
            "fromRoman": fromScheme["isRomanScheme"] != nil,
            "letters": letters,
            "marks": marks,
            "maxTokenLength": tokenLengths.max() ?? 0,
            "toRoman": toScheme["isRomanScheme"] != nil,
            "virama": virama,
            "toSchemeA": toSchemeA,
            "fromSchemeA": fromSchemeA,
            "from": from,
            "to": to
        ]
    }
    
    /**
     * Transliterate from a romanized script.
     *
     * - Parameters:
     *   - data: The string to transliterate
     *   - map: Map data generated from makeMap()
     *   - options: Transliteration options
     * - Returns: The finished string
     */
    private func transliterateRoman(data: String, map: [String: Any], options: Defaults) -> String {
        var buf = [String]()
        let consonants = map["consonants"] as? [String: String] ?? [:]
        let dataLength = data.count
        let letters = map["letters"] as? [String: String] ?? [:]
        let marks = map["marks"] as? [String: String] ?? [:]
        let maxTokenLength = map["maxTokenLength"] as? Int ?? 0
        let optSkipSGML = options.skipSgml
        let optSyncope = options.syncope
        let toRoman = map["toRoman"] as? Bool ?? false
        let virama = map["virama"] as? String ?? ""
        let fromSchemeA = map["fromSchemeA"] as? String ?? ""
        
        var hadConsonant = false
        var tempLetter: String? = nil
        var tempMark: String? = nil
        var tokenBuffer = ""
        
        // Transliteration state variables
        var skippingSGML = false
        var skippingTrans = false
        var toggledTrans = false
        
        var i = 0
        while i < dataLength || !tokenBuffer.isEmpty {
            // Fill the token buffer, if possible
            let difference = maxTokenLength - tokenBuffer.count
            if difference > 0 && i < dataLength {
                let index = data.index(data.startIndex, offsetBy: i)
                tokenBuffer += String(data[index])
                i += 1
                if difference > 1 {
                    continue
                }
            }
            
            // Match all token substrings to our map
            var j = 0
            var found = false
            
            while j < maxTokenLength {
                if j >= tokenBuffer.count {
                    j += 1
                    continue
                }
                
                let token = String(tokenBuffer.prefix(maxTokenLength - j))
                
                if skippingSGML {
                    skippingSGML = (token != ">")
                } else if token == "<" {
                    skippingSGML = optSkipSGML
                } else if token == "##" {
                    toggledTrans = !toggledTrans
                    tokenBuffer = String(tokenBuffer.dropFirst(2))
                    found = true
                    break
                }
                
                skippingTrans = skippingSGML || toggledTrans
                
                if !skippingTrans {
                    tempLetter = letters[token]
                    if tempLetter != nil {
                        if toRoman {
                            buf.append(tempLetter!)
                        } else {
                            // Handle the implicit vowel. Ignore 'a' and force
                            // vowels to appear as marks if we've just seen a consonant
                            if hadConsonant {
                                tempMark = marks[token]
                                if tempMark != nil {
                                    buf.append(tempMark!)
                                } else if token != fromSchemeA {
                                    buf.append(virama)
                                    buf.append(tempLetter!)
                                }
                            } else {
                                buf.append(tempLetter!)
                            }
                            hadConsonant = consonants[token] != nil
                        }
                        
                        tokenBuffer = String(tokenBuffer.dropFirst(maxTokenLength - j))
                        found = true
                        break
                    } else if j == maxTokenLength - 1 {
                        if hadConsonant {
                            hadConsonant = false
                            if !optSyncope {
                                buf.append(virama)
                            }
                        }
                        
                        buf.append(token)
                        tokenBuffer = String(tokenBuffer.dropFirst(1))
                        // No need for break here as j == maxTokenLength - 1 is true only on the last iteration
                    }
                } else if j == maxTokenLength - 1 {
                    buf.append(token)
                    tokenBuffer = String(tokenBuffer.dropFirst(1))
                }
                
                j += 1
            }
            
            // If we've gone through all possibilities and the token buffer is still not empty,
            // we need to handle the first character and move on
            if !found && tokenBuffer.count > 0 {
                let firstChar = String(tokenBuffer.prefix(1))
                buf.append(firstChar)
                tokenBuffer = String(tokenBuffer.dropFirst(1))
            }
        }
        
        // If we end with a consonant and syncope is not enabled, add a virama
        if hadConsonant && !optSyncope {
            buf.append(virama)
        }
        
        var result = buf.joined()
        
        // Handle accent placement for non-Roman scripts
        if !toRoman, let to = map["to"] as? String, let toScheme = schemes[to], let accents = map["accents"] as? [String: String], !accents.isEmpty {
            if let yogavaahas = toScheme["yogavaahas"] as? [String: String] {
                let accentValues = accents.values.joined()
                let yogavaahaValues = yogavaahas.values.joined()
                
                // Create a pattern to match accent followed by yogavaha
                let pattern = "([\(accentValues)])([\(yogavaahaValues)])"
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(result.startIndex..<result.endIndex, in: result)
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$2$1")
                }
            }
        }
        
        return result
    }
    
    /**
     * Transliterate from a Brahmic script.
     *
     * - Parameters:
     *   - data: The string to transliterate
     *   - map: Map data generated from makeMap()
     *   - options: Transliteration options
     * - Returns: The finished string
     */
    private func transliterateBrahmic(data: String, map: [String: Any], options: Defaults) -> String {
        var buf = [String]()
        let consonants = map["consonants"] as? [String: String] ?? [:]
        let letters = map["letters"] as? [String: String] ?? [:]
        let marks = map["marks"] as? [String: String] ?? [:]
        let toRoman = map["toRoman"] as? Bool ?? false
        let toSchemeA = map["toSchemeA"] as? String ?? ""
        
        var danglingHash = false
        var hadRomanConsonant = false
        var skippingTrans = false
        
        // Handle accent placement for Roman scripts
        var processedData = data
        if toRoman, let to = map["to"] as? String, let toScheme = schemes[to], let accents = map["accents"] as? [String: String], !accents.isEmpty {
            if let yogavaahas = toScheme["yogavaahas"] as? [String: String] {
                let accentValues = accents.values.joined()
                let yogavaahaValues = yogavaahas.values.joined()
                
                // Create a pattern to match yogavaha followed by accent
                let pattern = "([\(yogavaahaValues)])([\(accentValues)])"
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(processedData.startIndex..<processedData.endIndex, in: processedData)
                    processedData = regex.stringByReplacingMatches(in: processedData, options: [], range: range, withTemplate: "$2$1")
                }
            }
        }
        
        // Process each character
        for char in processedData {
            let L = String(char)
            
            // Toggle transliteration state
            if L == "#" {
                if danglingHash {
                    skippingTrans = !skippingTrans
                    danglingHash = false
                } else {
                    danglingHash = true
                }
                
                if hadRomanConsonant {
                    buf.append(toSchemeA)
                    hadRomanConsonant = false
                }
                continue
            } else if skippingTrans {
                buf.append(L)
                continue
            }
            
            // Handle marks
            if let mark = marks[L] {
                buf.append(mark)
                hadRomanConsonant = false
            } else {
                if danglingHash {
                    buf.append("#")
                    danglingHash = false
                }
                
                if hadRomanConsonant {
                    buf.append(toSchemeA)
                    hadRomanConsonant = false
                }
                
                // Push transliterated letter if possible, otherwise push the letter itself
                if let letter = letters[L] {
                    buf.append(letter)
                    hadRomanConsonant = toRoman && (consonants[L] != nil)
                } else {
                    buf.append(L)
                }
            }
        }
        
        if hadRomanConsonant {
            buf.append(toSchemeA)
        }
        
        return buf.joined()
    }
    
    /**
     * Transliterate from one script to another.
     *
     * - Parameters:
     *   - data: The string to transliterate
     *   - from: The source script
     *   - to: The destination script
     *   - options: Transliteration options
     * - Returns: The finished string
     */
    public func t(data: String, from: String, to: String, options: Defaults? = nil) -> String {
        let opts = options ?? defaults
        let cachedOptions = cache["options"] as? Defaults
        let hasPriorState = (cache["from"] as? String == from && cache["to"] as? String == to)
        var map: [String: Any]
        
        // Compare options with cached options
        var optionsMatch = true
        if let cachedOpts = cachedOptions {
            optionsMatch = (opts == cachedOpts)
        } else {
            optionsMatch = false
        }
        
        // Use cached map if possible, otherwise create a new one
        if hasPriorState && optionsMatch {
            map = cache["map"] as? [String: Any] ?? [:]
        } else {
            map = makeMap(from: from, to: to, options: opts)
            cache = [
                "from": from,
                "map": map,
                "options": opts,
                "to": to
            ]
        }
        
        // Special handling for ITRANS
        var processedData = data
        if from == "itrans" {
            // Replace {\m+} with .h.N
            if let regex = try? NSRegularExpression(pattern: "\\{\\\\m\\+\\}", options: []) {
                let range = NSRange(processedData.startIndex..<processedData.endIndex, in: processedData)
                processedData = regex.stringByReplacingMatches(in: processedData, options: [], range: range, withTemplate: ".h.N")
            }
            
            // Remove .h
            if let regex = try? NSRegularExpression(pattern: "\\.h", options: []) {
                let range = NSRange(processedData.startIndex..<processedData.endIndex, in: processedData)
                processedData = regex.stringByReplacingMatches(in: processedData, options: [], range: range, withTemplate: "")
            }
            
            // Handle backslashes
            if let regex = try? NSRegularExpression(pattern: "\\\\([^'`_]|$)", options: []) {
                let range = NSRange(processedData.startIndex..<processedData.endIndex, in: processedData)
                processedData = regex.stringByReplacingMatches(in: processedData, options: [], range: range, withTemplate: "##$1##")
            }
        }
        
        // Handle tamil_superscripted special case
        if from == "tamil_superscripted" {
            if let fromScheme = schemes["tamil_superscripted"] {
                if let vowelMarks = fromScheme["vowel_marks"] as? [String: String],
                   let virama = (fromScheme["virama"] as? [String: String])?["्"] {
                    let vowelMarkValues = vowelMarks.values.joined()
                    let pattern = "([\(vowelMarkValues)\(virama)॒॑]+)([²³⁴])"
                    
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                        let range = NSRange(processedData.startIndex..<processedData.endIndex, in: processedData)
                        processedData = regex.stringByReplacingMatches(in: processedData, options: [], range: range, withTemplate: "$2$1")
                    }
                }
            }
            print("transliteration from tamil_superscripted not fully implemented!")
        }
        
        // Apply shortcuts from the source scheme
        if let fromScheme = schemes[from],
           let fromShortcuts = fromScheme["shortcuts"] as? [String: String] {
            for (key, shortcut) in fromShortcuts {
                if key.contains(shortcut) {
                    // An actually long "key" may already exist in the string
                    processedData = processedData.replacingOccurrences(of: key, with: shortcut)
                }
                processedData = processedData.replacingOccurrences(of: shortcut, with: key)
            }
        }
        
        // Perform the actual transliteration
        var result = ""
        if let fromRoman = map["fromRoman"] as? Bool, fromRoman {
            result = transliterateRoman(data: processedData, map: map, options: opts)
        } else {
            result = transliterateBrahmic(data: processedData, map: map, options: opts)
        }
        
        // Apply shortcuts to the result
        if let toScheme = schemes[to],
           let toShortcuts = toScheme["shortcuts"] as? [String: String] {
            for (key, shortcut) in toShortcuts {
                if shortcut.contains(key) {
                    // An actually long "shortcut" may already exist in the string
                    result = result.replacingOccurrences(of: shortcut, with: key)
                }
                result = result.replacingOccurrences(of: key, with: shortcut)
            }
        }
        
        // Handle tamil_superscripted special case for output
        if to == "tamil_superscripted" {
            if let toScheme = schemes["tamil_superscripted"] {
                if let vowelMarks = toScheme["vowel_marks"] as? [String: String],
                   let virama = (toScheme["virama"] as? [String: String])?["्"] {
                    let vowelMarkValues = vowelMarks.values.joined()
                    let pattern = "([²³⁴])([\(vowelMarkValues)\(virama)॒॑]+)"
                    
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                        let range = NSRange(result.startIndex..<result.endIndex, in: result)
                        result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$2$1")
                    }
                }
            }
        }
        
        // Apply preferred alternates
        if let preferredAlts = opts.preferredAlternates[to] {
            for (key, value) in preferredAlts {
                result = result.replacingOccurrences(of: key, with: value)
            }
        }
        
        return result
    }
    
    /**
     * A function to transliterate each word, for the benefit of script learners.
     *
     * - Parameters:
     *   - data: The string to transliterate
     *   - from: The source script
     *   - to: The destination script
     *   - options: Transliteration options
     * - Returns: An array of tuples containing the original word and its transliteration
     */
    public func transliterateWordwise(data: String, from: String, to: String, options: Defaults? = nil) -> [(String, String)] {
        let opts = options ?? defaults
        let words = data.split(separator: " ")
        
        return words.map { word in
            let result = t(data: String(word), from: from, to: to, options: opts)
            return (String(word), result)
        }
    }
    
    // Mapping from Devanagari vowels to vowel marks
    private let devanagariVowelToMarks: [String: String] = [
        "आ": "ा",  // आ -> ा
        "इ": "ि",  // इ -> ि
        "ई": "ी",  // ई -> ी
        "उ": "ु",  // उ -> ु
        "ऊ": "ू",  // ऊ -> ू
        "ऋ": "ृ",  // ऋ -> ृ
        "ॠ": "ॄ",  // ॠ -> ॄ
        "ऌ": "ॢ",  // ऌ -> ॢ
        "ॡ": "ॣ",  // ॡ -> ॣ
        "ए": "े",  // ए -> े
        "ऐ": "ै",  // ऐ -> ै
        "ओ": "ो",  // ओ -> ो
        "औ": "ौ"   // औ -> ौ
    ]
}
