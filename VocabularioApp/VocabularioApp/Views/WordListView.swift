//
//  WordListView.swift
//  Vocabulario
//
//  Main word list view with add functionality
//

import SwiftUI

struct WordListView: View {
    @EnvironmentObject var vocabularyVM: VocabularyViewModel
    @State private var showingAddWords = false
    @State private var showingScan = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                if vocabularyVM.words.isEmpty {
                    emptyState
                } else {
                    wordsList
                }
            }
            .navigationTitle("Vocabulario")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddWords = true
                        } label: {
                            Label("Add Word", systemImage: "plus.circle")
                        }
                        
                        Button {
                            showingScan = true
                        } label: {
                            Label("Scan Image", systemImage: "camera")
                        }
                        
                        if !vocabularyVM.words.isEmpty {
                            Divider()
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddWords) {
                AddWordView()
            }
            .sheet(isPresented: $showingScan) {
                ImageScanView()
            }
            .alert("Clear All Words?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    vocabularyVM.clearAll()
                }
            } message: {
                Text("This will delete all \(vocabularyVM.words.count) words from your vocabulary.")
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 80))
                .foregroundColor(Color("TextMuted"))
            
            Text("No words yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("TextPrimary"))
            
            Text("Add some vocabulary to get started!")
                .foregroundColor(Color("TextSecondary"))
            
            Button {
                showingAddWords = true
            } label: {
                Label("Add Your First Word", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("AccentColor"))
                    .cornerRadius(12)
            }
            .padding(.top)
        }
        .padding()
    }
    
    private var wordsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vocabularyVM.words) { word in
                    WordRow(word: word)
                }
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            if vocabularyVM.isSyncing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Syncing...")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                .padding(8)
                .background(Color("BackgroundCard").opacity(0.9))
                .cornerRadius(8)
                .padding()
            }
        }
    }
}

struct WordRow: View {
    let word: Word
    @EnvironmentObject var vocabularyVM: VocabularyViewModel
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.spanish)
                    .font(.headline)
                    .italic()
                    .foregroundColor(Color("AccentColor"))
                
                Text(word.english)
                    .foregroundColor(Color("TextPrimary"))
            }
            
            Spacer()
            
            Button {
                showingDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(Color("TextMuted"))
            }
            .confirmationDialog("Delete this word?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    Task {
                        await vocabularyVM.deleteWord(word)
                    }
                }
            }
        }
        .padding()
        .background(Color("BackgroundCard"))
        .cornerRadius(12)
    }
}

#Preview {
    WordListView()
        .environmentObject(VocabularyViewModel())
}

