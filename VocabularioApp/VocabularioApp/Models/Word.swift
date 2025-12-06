//
//  Word.swift
//  Vocabulario
//
//  Model for vocabulary word pairs
//

import Foundation
import FirebaseFirestore

struct Word: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var spanish: String
    var english: String
    var spanishFull: String?
    var englishFull: String?
    var createdAt: Date
    var userId: String?
    
    init(spanish: String, english: String, spanishFull: String? = nil, englishFull: String? = nil) {
        self.spanish = spanish
        self.english = english
        self.spanishFull = spanishFull ?? spanish
        self.englishFull = englishFull ?? english
        self.createdAt = Date()
    }
    
    // For Firestore encoding
    enum CodingKeys: String, CodingKey {
        case id
        case spanish
        case english
        case spanishFull
        case englishFull
        case createdAt
        case userId
    }
}

// Extension for word cleaning utilities
extension Word {
    /// Get simple answer (first part before semicolon)
    var simpleEnglish: String {
        WordCleaner.getSimpleAnswer(from: english)
    }
    
    var simpleSpanish: String {
        WordCleaner.getSimpleAnswer(from: spanish)
    }
}

