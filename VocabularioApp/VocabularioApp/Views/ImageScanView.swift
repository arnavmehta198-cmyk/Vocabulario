//
//  ImageScanView.swift
//  Vocabulario
//
//  Image scanning with OCR using Vision framework
//

import SwiftUI
import Vision
import PhotosUI

struct ImageScanView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vocabularyVM: VocabularyViewModel
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var extractedWords: [(spanish: String, english: String)] = []
    @State private var isProcessing = false
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .padding()
                    
                    if isProcessing {
                        ProgressView("Scanning...")
                            .padding()
                    } else if !extractedWords.isEmpty {
                        extractedWordsList
                    }
                } else {
                    imagePicker
                }
            }
            .navigationTitle("Scan Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        await processImage(image)
                    }
                }
            }
        }
    }
    
    private var imagePicker: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(Color("AccentColor"))
            
            Text("Select an image with vocabulary words")
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextSecondary"))
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Choose Photo", systemImage: "photo")
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
    
    private var extractedWordsList: some View {
        VStack {
            Text("Found \(extractedWords.count) words")
                .font(.headline)
                .padding()
            
            List {
                ForEach(Array(extractedWords.enumerated()), id: \.offset) { index, wordPair in
                    HStack {
                        Text(wordPair.spanish)
                            .font(.headline)
                            .foregroundColor(Color("AccentColor"))
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color("TextMuted"))
                        
                        Text(wordPair.english)
                    }
                }
            }
            
            Button {
                addExtractedWords()
            } label: {
                Text("Add All Words")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .cornerRadius(12)
            }
            .padding()
        }
    }
    
    private func processImage(_ image: UIImage) async {
        isProcessing = true
        
        guard let cgImage = image.cgImage else {
            isProcessing = false
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                isProcessing = false
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            parseExtractedText(recognizedText)
            isProcessing = false
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "es-ES"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("OCR error: \(error)")
            isProcessing = false
        }
    }
    
    private func parseExtractedText(_ text: String) {
        let lines = text.components(separatedBy: .newlines)
        var words: [(spanish: String, english: String)] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            // Try different separators
            let separators = [" - ", " – ", " — ", ": ", " = "]
            
            for separator in separators {
                let parts = trimmed.components(separatedBy: separator)
                if parts.count == 2 {
                    let spanish = parts[0].trimmingCharacters(in: .whitespaces)
                    let english = parts[1].trimmingCharacters(in: .whitespaces)
                    
                    if !spanish.isEmpty && !english.isEmpty {
                        words.append((spanish: spanish, english: english))
                        break
                    }
                }
            }
        }
        
        extractedWords = words
    }
    
    private func addExtractedWords() {
        Task {
            for wordPair in extractedWords {
                let words = WordCleaner.processWordPair(spanish: wordPair.spanish, english: wordPair.english)
                await vocabularyVM.addWords(words)
            }
            dismiss()
        }
    }
}

#Preview {
    ImageScanView()
        .environmentObject(VocabularyViewModel())
}

