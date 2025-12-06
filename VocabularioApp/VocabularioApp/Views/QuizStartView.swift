//
//  QuizStartView.swift
//  Vocabulario
//
//  Quiz mode selection and start screen
//

import SwiftUI

struct QuizStartView: View {
    @EnvironmentObject var vocabularyVM: VocabularyViewModel
    @State private var selectedMode: QuizMode = .spanishToEnglish
    @State private var showingQuiz = false
    @State private var fuzzyMatching = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                if vocabularyVM.words.isEmpty {
                    emptyState
                } else {
                    quizSetup
                }
            }
            .navigationTitle("Quiz")
        }
        .fullScreenCover(isPresented: $showingQuiz) {
            QuizView(mode: selectedMode, fuzzyMatching: fuzzyMatching)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(Color("TextMuted"))
            
            Text("No words yet!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("TextPrimary"))
            
            Text("Add some vocabulary before starting a quiz.")
                .foregroundColor(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var quizSetup: some View {
        VStack(spacing: 24) {
            // Mode selection
            VStack(spacing: 16) {
                ForEach(QuizMode.allCases) { mode in
                    Button {
                        selectedMode = mode
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.title)
                                    .font(.headline)
                                    .foregroundColor(Color("TextPrimary"))
                                
                                Text("See \(mode == .spanishToEnglish ? "Spanish" : "English"), type \(mode == .spanishToEnglish ? "English" : "Spanish")")
                                    .font(.caption)
                                    .foregroundColor(Color("TextSecondary"))
                            }
                            
                            Spacer()
                            
                            if selectedMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color("AccentColor"))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(Color("TextMuted"))
                            }
                        }
                        .padding()
                        .background(selectedMode == mode ? Color("AccentColor").opacity(0.1) : Color("BackgroundCard"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMode == mode ? Color("AccentColor") : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            .padding()
            
            // Settings
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $fuzzyMatching) {
                    VStack(alignment: .leading) {
                        Text("Flexible Answers")
                            .foregroundColor(Color("TextPrimary"))
                        Text("Accepts close matches and synonyms")
                            .font(.caption)
                            .foregroundColor(Color("TextMuted"))
                    }
                }
                .tint(Color("AccentColor"))
            }
            .padding()
            .background(Color("BackgroundCard"))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Word count
            Text("\(vocabularyVM.words.count) words")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("AccentColor"))
            
            // Start button
            Button {
                showingQuiz = true
            } label: {
                Text("Start Quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    QuizStartView()
        .environmentObject(VocabularyViewModel())
}

