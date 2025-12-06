//
//  VocabularyViewModel.swift
//  Vocabulario
//
//  Manages vocabulary list with Firebase Firestore sync
//

import Foundation
import Firebase
import Combine

@MainActor
class VocabularyViewModel: ObservableObject {
    @Published var words: [Word] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSyncing = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLocalWords()
        setupAuthListener()
    }
    
    // MARK: - Local Storage
    
    private func loadLocalWords() {
        if let data = UserDefaults.standard.data(forKey: "vocabularyWords"),
           let decoded = try? JSONDecoder().decode([Word].self, from: data) {
            words = decoded
        }
    }
    
    private func saveLocalWords() {
        if let encoded = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(encoded, forKey: "vocabularyWords")
        }
    }
    
    // MARK: - Firebase Sync
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.startFirestoreSync(userId: user.uid)
                } else {
                    self?.stopFirestoreSync()
                }
            }
        }
    }
    
    private func startFirestoreSync(userId: String) async {
        isSyncing = true
        
        listener = db.collection("users")
            .document(userId)
            .collection("vocabulary")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                Task { @MainActor in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.isSyncing = false
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self.isSyncing = false
                        return
                    }
                    
                    let firestoreWords = documents.compactMap { doc -> Word? in
                        try? doc.data(as: Word.self)
                    }
                    
                    if !firestoreWords.isEmpty || self.words.isEmpty {
                        self.words = firestoreWords
                        self.saveLocalWords()
                    } else if self.words.count > firestoreWords.count {
                        // Upload local words to Firestore
                        await self.uploadLocalWords(userId: userId)
                    }
                    
                    self.isSyncing = false
                }
            }
    }
    
    private func stopFirestoreSync() {
        listener?.remove()
        listener = nil
    }
    
    private func uploadLocalWords(userId: String) async {
        for word in words {
            do {
                var wordToUpload = word
                wordToUpload.userId = userId
                try db.collection("users")
                    .document(userId)
                    .collection("vocabulary")
                    .addDocument(from: wordToUpload)
            } catch {
                print("Error uploading word: \(error)")
            }
        }
    }
    
    // MARK: - Word Management
    
    func addWord(_ word: Word) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            // Add locally only
            words.insert(word, at: 0)
            saveLocalWords()
            return
        }
        
        // Add to Firestore (will sync back via listener)
        do {
            var wordToAdd = word
            wordToAdd.userId = userId
            isSyncing = true
            try db.collection("users")
                .document(userId)
                .collection("vocabulary")
                .addDocument(from: wordToAdd)
        } catch {
            errorMessage = error.localizedDescription
            // Fallback to local
            words.insert(word, at: 0)
            saveLocalWords()
        }
    }
    
    func addWords(_ wordsToAdd: [Word]) async {
        for word in wordsToAdd {
            await addWord(word)
        }
    }
    
    func deleteWord(_ word: Word) async {
        guard let userId = Auth.auth().currentUser?.uid,
              let wordId = word.id else {
            // Delete locally only
            words.removeAll { $0.id == word.id }
            saveLocalWords()
            return
        }
        
        // Delete from Firestore
        do {
            try await db.collection("users")
                .document(userId)
                .collection("vocabulary")
                .document(wordId)
                .delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clearAll() {
        words.removeAll()
        saveLocalWords()
    }
}

