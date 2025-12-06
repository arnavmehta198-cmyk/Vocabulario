///  QuizMode.swift
//  Vocabulario
//
//  Quiz mode enumeration
//

import Foundation

enum QuizMode: String, CaseIterable, Identifiable {
    case spanishToEnglish = "Spanish → English"
    case englishToSpanish = "English → Spanish"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var prompt: String {
        switch self {
        case .spanishToEnglish:
            return "Translate to English"
        case .englishToSpanish:
            return "Translate to Spanish"
        }
    }
}

