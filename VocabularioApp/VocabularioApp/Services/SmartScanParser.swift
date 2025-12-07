//
//  SmartScanParser.swift
//  Vocabulario
//
//  Advanced OCR text parsing with multiple strategies
//  Matches website's Smart Scan Pro functionality
//

import Foundation

struct ParsedWord {
    let spanish: String
    let english: String
    let confidence: Double
    let source: String
}

class SmartScanParser {
    
    // MARK: - Language Detection Patterns
    
    private static let spanishPatterns = try! NSRegularExpression(pattern: "[áéíóúüñ¿¡]", options: .caseInsensitive)
    private static let spanishArticles = try! NSRegularExpression(pattern: "^(el|la|los|las|un|una|unos|unas)\\s", options: .caseInsensitive)
    private static let englishPatterns = try! NSRegularExpression(pattern: "\\b(the|a|an|to|is|are|was|were|been|being|have|has|had|do|does|did)\\b", options: .caseInsensitive)
    
    // MARK: - Main Parse Function
    
    static func parse(_ text: String) -> [ParsedWord] {
        let cleanedText = advancedTextCleanup(text)
        
        var allResults: [ParsedWord] = []
        
        // Try multiple parsing strategies
        allResults.append(contentsOf: parseWithSeparators(cleanedText))
        allResults.append(contentsOf: parseWithPatternMatching(cleanedText))
        allResults.append(contentsOf: parseWithLanguageDetection(cleanedText))
        allResults.append(contentsOf: parseWithContextualAnalysis(cleanedText))
        
        // Deduplicate and return
        return deduplicateAndScore(allResults)
    }
    
    // MARK: - Text Cleanup
    
    private static func advancedTextCleanup(_ text: String) -> String {
        var cleaned = text
        
        // Normalize unicode
        cleaned = cleaned.replacingOccurrences(of: "\r\n", with: "\n")
        cleaned = cleaned.replacingOccurrences(of: "\r", with: "\n")
        
        // Normalize quotes and dashes
        let replacements: [(String, String)] = [
            (""", "\""), (""", "\""), ("„", "\""),
            ("'", "'"), ("'", "'"), ("`", "'"),
            ("—", "-"), ("–", "-"), ("−", "-"),
            ("→", " → "), ("⟶", " → "),
            ("…", "..."),
            ("ﬁ", "fi"), ("ﬂ", "fl")
        ]
        
        for (old, new) in replacements {
            cleaned = cleaned.replacingOccurrences(of: old, with: new)
        }
        
        // Remove page numbers
        cleaned = cleaned.replacingOccurrences(of: "(?m)^\\s*\\d+\\s*$", with: "", options: .regularExpression)
        
        return cleaned
    }
    
    // MARK: - Strategy 1: Separator-based parsing
    
    private static func parseWithSeparators(_ text: String) -> [ParsedWord] {
        var results: [ParsedWord] = []
        let lines = text.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        let separatorPatterns: [(pattern: String, name: String)] = [
            ("\\s+[-–—]\\s+", "dash"),
            ("\\s*=\\s*", "equals"),
            ("\\s*:\\s+", "colon"),
            ("\\s+→\\s+", "arrow"),
            ("\\t+", "tab"),
            ("\\s{3,}", "multi-space"),
            ("\\s*\\|\\s*", "pipe")
        ]
        
        for line in lines {
            let cleanLine = preprocessLine(line)
            guard !cleanLine.isEmpty, !isHeaderOrNoise(cleanLine) else { continue }
            
            for sep in separatorPatterns {
                if let regex = try? NSRegularExpression(pattern: sep.pattern, options: []) {
                    let range = NSRange(cleanLine.startIndex..., in: cleanLine)
                    let parts = regex.stringByReplacingMatches(in: cleanLine, options: [], range: range, withTemplate: "|||")
                        .components(separatedBy: "|||")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    
                    if parts.count >= 2 {
                        let spanish = cleanWord(parts[0])
                        let english = cleanWord(parts.dropFirst().joined(separator: " "))
                        
                        if isValidWordPair(spanish: spanish, english: english) {
                            results.append(ParsedWord(
                                spanish: spanish,
                                english: english,
                                confidence: 0.85,
                                source: "separator-\(sep.name)"
                            ))
                            break
                        }
                    }
                }
            }
        }
        
        return results
    }
    
    // MARK: - Strategy 2: Pattern matching
    
    private static func parseWithPatternMatching(_ text: String) -> [ParsedWord] {
        var results: [ParsedWord] = []
        let lines = text.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        let patterns: [String] = [
            "^[\\d]+[.\\)]\\s*(.+?)\\s*[-–—]\\s*(.+)$",
            "^[•\\-\\*►]\\s*(.+?)\\s*[-–—:]\\s*(.+)$",
            "^(.+?)\\s*=\\s*(.+)$",
            "^([^:]+?):\\s+(.+)$",
            "^(.+?)\\s*→\\s*(.+)$",
            "^(.+?)\\.{2,}\\s*(.+)$"
        ]
        
        for line in lines {
            let cleanLine = preprocessLine(line)
            guard !cleanLine.isEmpty, !isHeaderOrNoise(cleanLine) else { continue }
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                   let match = regex.firstMatch(in: cleanLine, options: [], range: NSRange(cleanLine.startIndex..., in: cleanLine)),
                   match.numberOfRanges >= 3 {
                    
                    let spanishRange = Range(match.range(at: 1), in: cleanLine)!
                    let englishRange = Range(match.range(at: 2), in: cleanLine)!
                    
                    let spanish = cleanWord(String(cleanLine[spanishRange]))
                    let english = cleanWord(String(cleanLine[englishRange]))
                    
                    if isValidWordPair(spanish: spanish, english: english) {
                        results.append(ParsedWord(
                            spanish: spanish,
                            english: english,
                            confidence: 0.85,
                            source: "pattern-matching"
                        ))
                        break
                    }
                }
            }
        }
        
        return results
    }
    
    // MARK: - Strategy 3: Language detection
    
    private static func parseWithLanguageDetection(_ text: String) -> [ParsedWord] {
        var results: [ParsedWord] = []
        let lines = text.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        for line in lines {
            let cleanLine = preprocessLine(line)
            guard !cleanLine.isEmpty, !isHeaderOrNoise(cleanLine) else { continue }
            
            // Split by any separator
            let parts = cleanLine.components(separatedBy: CharacterSet(charactersIn: "\t=-:|"))
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            if parts.count >= 2 {
                var spanishPart: String?
                var englishPart: String?
                
                for part in parts {
                    let spanishScore = getSpanishScore(part)
                    let englishScore = getEnglishScore(part)
                    
                    if spanishScore > englishScore && spanishPart == nil {
                        spanishPart = part
                    } else if englishScore >= spanishScore && englishPart == nil {
                        englishPart = part
                    }
                }
                
                if spanishPart == nil && englishPart == nil && parts.count == 2 {
                    spanishPart = parts[0]
                    englishPart = parts[1]
                }
                
                if let spanish = spanishPart, let english = englishPart {
                    let cleanSpanish = cleanWord(spanish)
                    let cleanEnglish = cleanWord(english)
                    
                    if isValidWordPair(spanish: cleanSpanish, english: cleanEnglish) {
                        results.append(ParsedWord(
                            spanish: cleanSpanish,
                            english: cleanEnglish,
                            confidence: 0.7,
                            source: "language-detection"
                        ))
                    }
                }
            }
        }
        
        return results
    }
    
    // MARK: - Strategy 4: Contextual analysis
    
    private static func parseWithContextualAnalysis(_ text: String) -> [ParsedWord] {
        var results: [ParsedWord] = []
        
        // Find dominant separator
        let separators = [" - ", " = ", ": ", "\t", " | "]
        var maxCount = 0
        var dominantSep = " - "
        
        for sep in separators {
            let count = text.components(separatedBy: sep).count - 1
            if count > maxCount {
                maxCount = count
                dominantSep = sep
            }
        }
        
        if maxCount > 2 {
            let lines = text.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            for line in lines {
                let cleanLine = preprocessLine(line)
                guard !cleanLine.isEmpty, !isHeaderOrNoise(cleanLine) else { continue }
                
                let parts = cleanLine.components(separatedBy: dominantSep)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                
                if parts.count >= 2 {
                    let spanish = cleanWord(parts[0])
                    let english = cleanWord(parts.dropFirst().joined(separator: " "))
                    
                    if isValidWordPair(spanish: spanish, english: english) {
                        results.append(ParsedWord(
                            spanish: spanish,
                            english: english,
                            confidence: 0.9,
                            source: "contextual"
                        ))
                    }
                }
            }
        }
        
        return results
    }
    
    // MARK: - Helper Functions
    
    private static func preprocessLine(_ line: String) -> String {
        var cleaned = line
        
        // Remove numbering
        if let regex = try? NSRegularExpression(pattern: "^[\\d]+[.\\):\\-]\\s*", options: []) {
            cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: NSRange(cleaned.startIndex..., in: cleaned), withTemplate: "")
        }
        
        // Remove bullets
        if let regex = try? NSRegularExpression(pattern: "^[•\\-\\*\\+►▪◦○●]\\s*", options: []) {
            cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: NSRange(cleaned.startIndex..., in: cleaned), withTemplate: "")
        }
        
        return cleaned.trimmingCharacters(in: .whitespaces)
    }
    
    private static func isHeaderOrNoise(_ line: String) -> Bool {
        let lower = line.lowercased()
        let noisePatterns = [
            "^(chapter|unit|lesson|section|part|module)",
            "^(vocabulary|vocab|words|terms|glossary)",
            "^(spanish|english|español|inglés)$",
            "^(page|pagina)",
            "^[\\d\\s\\-_.]+$"
        ]
        
        for pattern in noisePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               regex.firstMatch(in: lower, options: [], range: NSRange(lower.startIndex..., in: lower)) != nil {
                return true
            }
        }
        
        return false
    }
    
    private static func cleanWord(_ word: String) -> String {
        var cleaned = word
        
        // Remove surrounding quotes and brackets
        cleaned = cleaned.trimmingCharacters(in: CharacterSet(charactersIn: "\"'[](){}<>«»"))
        
        // Remove leading/trailing punctuation
        cleaned = cleaned.trimmingCharacters(in: CharacterSet(charactersIn: ".,;:-–—_"))
        
        // Normalize whitespace
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return cleaned.trimmingCharacters(in: .whitespaces)
    }
    
    private static func isValidWordPair(spanish: String, english: String) -> Bool {
        guard !spanish.isEmpty, !english.isEmpty else { return false }
        guard spanish.count >= 1, english.count >= 1 else { return false }
        
        // Must have letters
        let letterSet = CharacterSet.letters
        guard spanish.unicodeScalars.contains(where: { letterSet.contains($0) }),
              english.unicodeScalars.contains(where: { letterSet.contains($0) }) else {
            return false
        }
        
        // Shouldn't be identical
        guard spanish.lowercased() != english.lowercased() else { return false }
        
        return true
    }
    
    private static func getSpanishScore(_ text: String) -> Double {
        var score = 0.0
        let range = NSRange(text.startIndex..., in: text)
        
        if spanishPatterns.firstMatch(in: text, options: [], range: range) != nil {
            score += 0.4
        }
        if spanishArticles.firstMatch(in: text, options: [], range: range) != nil {
            score += 0.3
        }
        if englishPatterns.firstMatch(in: text, options: [], range: range) != nil {
            score -= 0.3
        }
        
        return max(0, min(1, score))
    }
    
    private static func getEnglishScore(_ text: String) -> Double {
        var score = 0.0
        let range = NSRange(text.startIndex..., in: text)
        
        if englishPatterns.firstMatch(in: text, options: [], range: range) != nil {
            score += 0.4
        }
        if text.lowercased().hasPrefix("to ") || text.lowercased().hasPrefix("the ") {
            score += 0.3
        }
        if spanishPatterns.firstMatch(in: text, options: [], range: range) != nil {
            score -= 0.3
        }
        
        return max(0, min(1, score))
    }
    
    private static func deduplicateAndScore(_ results: [ParsedWord]) -> [ParsedWord] {
        var seen: [String: ParsedWord] = [:]
        
        for result in results {
            let key = "\(result.spanish.lowercased())|||\(result.english.lowercased())"
            
            if seen[key] == nil || seen[key]!.confidence < result.confidence {
                seen[key] = result
            }
        }
        
        return Array(seen.values).sorted { $0.confidence > $1.confidence }
    }
}

