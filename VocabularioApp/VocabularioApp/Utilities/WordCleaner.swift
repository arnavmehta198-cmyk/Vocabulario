///  WordCleaner.swift
//  Vocabulario
//
//  Utilities for cleaning and processing vocabulary words
//

import Foundation

struct WordCleaner {
    
    /// Clean a word by removing parentheses, brackets
    static func cleanWord(_ word: String) -> String {
        var cleaned = word
        
        // Remove parentheses and their content
        cleaned = cleaned.replacingOccurrences(of: "\\s*\\([^)]*\\)", with: "", options: .regularExpression)
        // Remove brackets and their content
        cleaned = cleaned.replacingOccurrences(of: "\\s*\\[[^\\]]*\\]", with: "", options: .regularExpression)
        // Remove braces and their content
        cleaned = cleaned.replacingOccurrences(of: "\\s*\\{[^}]*\\}", with: "", options: .regularExpression)
        // Normalize whitespace
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return cleaned.trimmingCharacters(in: .whitespaces)
    }
    
    /// Get simple answer (first part before semicolon)
    static func getSimpleAnswer(from definition: String) -> String {
        let parts = definition.split(separator: ";")
        guard let first = parts.first else { return definition }
        return cleanWord(String(first))
    }
    
    /// Expand Spanish words with /a, /o endings into multiple variations
    /// e.g., "soltero/a" → ["soltero", "soltera"]
    static func expandSpanishWord(_ word: String) -> [String] {
        let trimmed = word.trimmingCharacters(in: .whitespaces)
        
        // Pattern: word/ending (e.g., soltero/a, hermano/a)
        if let range = trimmed.range(of: "(o|e)/(a|o|as|os)$", options: .regularExpression) {
            let base = String(trimmed[..<range.lowerBound])
            let endingsPart = String(trimmed[range])
            let endings = endingsPart.split(separator: "/")
            
            if endings.count == 2 {
                let firstEnding = String(endings[0])
                let secondEnding = String(endings[1])
                return [base + firstEnding, base + secondEnding]
            }
        }
        
        // Simple pattern: word/a or word/o
        if let range = trimmed.range(of: "/[aeoás]+$", options: .regularExpression) {
            let base = String(trimmed[..<range.lowerBound])
            let ending = String(trimmed[range].dropFirst()) // Remove /
            
            if base.hasSuffix("o") || base.hasSuffix("e") {
                return [base, String(base.dropLast()) + ending]
            } else {
                return [base, base + ending]
            }
        }
        
        // No expansion needed
        return [trimmed]
    }
    
    /// Process a word pair and return array of Word objects
    static func processWordPair(spanish: String, english: String) -> [Word] {
        let cleanedEnglish = cleanWord(english)
        let englishFull = english.trimmingCharacters(in: .whitespaces)
        
        // Clean parentheses etc from Spanish but keep /a patterns for expansion
        var cleanedSpanish = spanish
        cleanedSpanish = cleanedSpanish.replacingOccurrences(of: "\\s*\\([^)]*\\)", with: "", options: .regularExpression)
        cleanedSpanish = cleanedSpanish.replacingOccurrences(of: "\\s*\\[[^\\]]*\\]", with: "", options: .regularExpression)
        cleanedSpanish = cleanedSpanish.replacingOccurrences(of: "\\s*\\{[^}]*\\}", with: "", options: .regularExpression)
        cleanedSpanish = cleanedSpanish.trimmingCharacters(in: .whitespaces)
        
        // Expand Spanish variations
        let spanishVariations = expandSpanishWord(cleanedSpanish)
        
        // Create Word objects for each variation
        return spanishVariations.map { sp in
            Word(
                spanish: cleanWord(sp),
                english: cleanedEnglish,
                spanishFull: spanish.trimmingCharacters(in: .whitespaces),
                englishFull: englishFull
            )
        }
    }
}

