//
//  QuizView.swift
//  Vocabulario
//
//  Main quiz interface
//

import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vocabularyVM: VocabularyViewModel
    
    let mode: QuizMode
    let fuzzyMatching: Bool
    
    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var incorrectCount = 0
    @State private var userAnswer = ""
    @State private var isAnswered = false
    @State private var isCorrect = false
    @State private var quizWords: [Word] = []
    @State private var showingResults = false
    
    var currentWord: Word? {
        guard currentIndex < quizWords.count else { return nil }
        return quizWords[currentIndex]
    }
    
    var progress: Double {
        guard !quizWords.isEmpty else { return 0 }
        return Double(currentIndex) / Double(quizWords.count)
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()
            
            if showingResults {
                resultsView
            } else if let word = currentWord {
                quizContent(for: word)
            }
        }
        .onAppear {
            quizWords = vocabularyVM.words.shuffled()
        }
    }
    
    private func quizContent(for word: Word) -> some View {
        VStack {
            // Header with progress and score
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Label("\(incorrectCount)", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .font(.headline)
            }
            .padding()
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color("BackgroundCard"))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color("AccentColor"))
                        .frame(width: geometry.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
            
            Spacer()
            
            // Question card
            VStack(spacing: 32) {
                Text(mode.prompt)
                    .font(.caption)
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundColor(Color("TextMuted"))
                
                Text(mode == .spanishToEnglish ? word.spanish : word.english)
                    .font(.system(size: 48, weight: .semibold, design: .serif))
                    .italic(mode == .spanishToEnglish)
                    .foregroundColor(Color("AccentColor"))
                    .multilineTextAlignment(.center)
                
                TextField("Your answer", text: $userAnswer)
                    .textFieldStyle(QuizTextFieldStyle())
                    .disabled(isAnswered)
                    .onSubmit {
                        if !isAnswered {
                            checkAnswer()
                        }
                    }
                
                if isAnswered {
                    feedbackView(for: word)
                }
            }
            .padding()
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 16) {
                if isAnswered {
                    Button {
                        nextQuestion()
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AccentColor"))
                            .cornerRadius(12)
                    }
                } else {
                    Button {
                        skipQuestion()
                    } label: {
                        Text("Skip")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("BackgroundCard"))
                            .cornerRadius(12)
                    }
                    
                    Button {
                        checkAnswer()
                    } label: {
                        Text("Check")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(userAnswer.isEmpty ? Color.gray : Color("AccentColor"))
                            .cornerRadius(12)
                    }
                    .disabled(userAnswer.isEmpty)
                }
            }
            .padding()
        }
    }
    
    private func feedbackView(for word: Word) -> some View {
        VStack(spacing: 8) {
            Text(isCorrect ? "¡Correcto!" : "Not quite")
                .font(.headline)
                .foregroundColor(isCorrect ? .green : .red)
            
            if !isCorrect {
                let correctAnswer = mode == .spanishToEnglish ? word.simpleEnglish : word.simpleSpanish
                Text("The answer was: \(correctAnswer)")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var resultsView: some View {
        VStack(spacing: 24) {
            Text("Quiz Complete!")
                .font(.system(size: 40, weight: .bold, design: .serif))
            
            Text("\(Int(Double(correctCount) / Double(correctCount + incorrectCount) * 100))%")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(Color("AccentColor"))
            
            Text("\(correctCount) correct out of \(correctCount + incorrectCount)")
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func checkAnswer() {
        guard let word = currentWord else { return }
        
        let correctAnswer = mode == .spanishToEnglish ? word.simpleEnglish : word.simpleSpanish
        let trimmedAnswer = userAnswer.trimmingCharacters(in: .whitespaces).lowercased()
        let trimmedCorrect = correctAnswer.lowercased()
        
        if trimmedAnswer == trimmedCorrect {
            isCorrect = true
            correctCount += 1
        } else {
            isCorrect = false
            incorrectCount += 1
        }
        
        isAnswered = true
    }
    
    private func skipQuestion() {
        incorrectCount += 1
        isAnswered = true
        isCorrect = false
    }
    
    private func nextQuestion() {
        currentIndex += 1
        
        if currentIndex >= quizWords.count {
            showingResults = true
        } else {
            userAnswer = ""
            isAnswered = false
            isCorrect = false
        }
    }
}

struct QuizTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color("BackgroundCard"))
            .cornerRadius(12)
            .font(.title2)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    QuizView(mode: .spanishToEnglish, fuzzyMatching: true)
        .environmentObject(VocabularyViewModel())
}

