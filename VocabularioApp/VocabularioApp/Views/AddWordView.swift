//
//  AddWordView.swift
//  Vocabulario
//
//  View for adding new vocabulary words
//

import SwiftUI

struct AddWordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vocabularyVM: VocabularyViewModel
    
    @State private var spanishText = ""
    @State private var englishText = ""
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Spanish", text: $spanishText)
                        .textInputAutocapitalization(.never)
                    
                    TextField("English", text: $englishText)
                        .textInputAutocapitalization(.never)
                } header: {
                    Text("Word Pair")
                } footer: {
                    Text("Tip: Use soltero/a format for gender variations")
                        .font(.caption)
                }
            }
            .navigationTitle("Add Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addWords()
                    }
                    .disabled(spanishText.isEmpty || englishText.isEmpty)
                }
            }
            .alert("Words Added!", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            }
        }
    }
    
    private func addWords() {
        let words = WordCleaner.processWordPair(spanish: spanishText, english: englishText)
        
        Task {
            await vocabularyVM.addWords(words)
            showingSuccess = true
            
            if words.count > 1 {
                print("Added \(words.count) words: \(words.map { $0.spanish }.joined(separator: ", "))")
            }
        }
    }
}

#Preview {
    AddWordView()
        .environmentObject(VocabularyViewModel())
}

