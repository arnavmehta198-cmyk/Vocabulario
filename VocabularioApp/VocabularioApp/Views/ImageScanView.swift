//
//  ImageScanView.swift
//  Vocabulario
//
//  Image scanning with OCR using Vision framework
//  Uses SmartScanParser for advanced text parsing
//

import SwiftUI
import Vision
import PhotosUI

struct ImageScanView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vocabularyVM: VocabularyViewModel
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var extractedWords: [ParsedWord] = []
    @State private var selectedWords: Set<String> = []
    @State private var isProcessing = false
    @State private var processingStatus = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                        
                        if isProcessing {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text(processingStatus)
                                    .font(.caption)
                                    .foregroundColor(Color("TextSecondary"))
                            }
                            .padding()
                        } else if !extractedWords.isEmpty {
                            extractedWordsList
                        }
                    } else {
                        imagePicker
                    }
                }
                .padding()
            }
            .background(Color("BackgroundPrimary"))
            .navigationTitle("Smart Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if selectedImage != nil && !isProcessing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Reset") {
                            resetScan()
                        }
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
            
            Text("Smart Scan Pro")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("TextPrimary"))
            
            Text("Uses advanced AI parsing to extract vocabulary from images")
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextSecondary"))
            
            // Disclaimer
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Disclaimer")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                
                Text("Smart Scan uses OCR technology which may not always produce perfect results. Handwritten text, unusual fonts, poor image quality, or complex layouts may cause errors. Always review extracted words before adding.")
                    .font(.caption2)
                    .foregroundColor(Color("TextSecondary"))
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
            
            // Tips
            VStack(alignment: .leading, spacing: 6) {
                Text("Tips for best results:")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                tipRow("Use clear, well-lit photos")
                tipRow("Crop to show only vocabulary")
                tipRow("Works best with printed text")
                tipRow("Format: 'spanish - english'")
            }
            .padding()
            .background(Color("BackgroundCard"))
            .cornerRadius(12)
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Choose Photo", systemImage: "photo.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .cornerRadius(12)
            }
        }
    }
    
    private func tipRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(Color("AccentColor"))
            Text(text)
                .font(.caption)
                .foregroundColor(Color("TextSecondary"))
        }
    }
    
    private var extractedWordsList: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Found \(extractedWords.count) words")
                        .font(.headline)
                    Text("Tap to select/deselect")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
                
                Button {
                    if selectedWords.count == extractedWords.count {
                        selectedWords.removeAll()
                    } else {
                        selectedWords = Set(extractedWords.map { "\($0.spanish)|\($0.english)" })
                    }
                } label: {
                    Text(selectedWords.count == extractedWords.count ? "Deselect All" : "Select All")
                        .font(.caption)
                        .foregroundColor(Color("AccentColor"))
                }
            }
            
            // Word list
            VStack(spacing: 8) {
                ForEach(extractedWords, id: \.spanish) { word in
                    let key = "\(word.spanish)|\(word.english)"
                    let isSelected = selectedWords.contains(key)
                    
                    Button {
                        if isSelected {
                            selectedWords.remove(key)
                        } else {
                            selectedWords.insert(key)
                        }
                    } label: {
                        HStack {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? Color("AccentColor") : Color("TextMuted"))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(word.spanish)
                                    .font(.headline)
                                    .foregroundColor(Color("AccentColor"))
                                
                                Text(word.english)
                                    .font(.subheadline)
                                    .foregroundColor(Color("TextPrimary"))
                            }
                            
                            Spacer()
                            
                            // Confidence indicator
                            Circle()
                                .fill(confidenceColor(word.confidence))
                                .frame(width: 8, height: 8)
                        }
                        .padding()
                        .background(isSelected ? Color("AccentColor").opacity(0.1) : Color("BackgroundCard"))
                        .cornerRadius(12)
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                confidenceLegend(.green, "High confidence")
                confidenceLegend(.yellow, "Medium")
                confidenceLegend(.red, "Low")
            }
            .font(.caption2)
            
            // Add button
            Button {
                addSelectedWords()
            } label: {
                Text("Add \(selectedWords.count) Words")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedWords.isEmpty ? Color.gray : Color("AccentColor"))
                    .cornerRadius(12)
            }
            .disabled(selectedWords.isEmpty)
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        if confidence >= 0.6 { return .yellow }
        return .red
    }
    
    private func confidenceLegend(_ color: Color, _ text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .foregroundColor(Color("TextMuted"))
        }
    }
    
    private func resetScan() {
        selectedImage = nil
        selectedItem = nil
        extractedWords = []
        selectedWords = []
    }
    
    private func processImage(_ image: UIImage) async {
        isProcessing = true
        processingStatus = "Preparing image..."
        
        guard let cgImage = image.cgImage else {
            isProcessing = false
            return
        }
        
        processingStatus = "Scanning text..."
        
        let request = VNRecognizeTextRequest { request, error in
            Task { @MainActor in
                guard let observations = request.results as? [VNRecognizedTextObservation],
                      error == nil else {
                    isProcessing = false
                    return
                }
                
                processingStatus = "Parsing vocabulary..."
                
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                // Use advanced parser
                extractedWords = SmartScanParser.parse(recognizedText)
                
                // Auto-select high confidence words
                selectedWords = Set(extractedWords
                    .filter { $0.confidence >= 0.6 }
                    .map { "\($0.spanish)|\($0.english)" })
                
                isProcessing = false
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "es-ES", "es-MX"]
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("OCR error: \(error)")
            await MainActor.run {
                isProcessing = false
            }
        }
    }
    
    private func addSelectedWords() {
        Task {
            for word in extractedWords {
                let key = "\(word.spanish)|\(word.english)"
                if selectedWords.contains(key) {
                    let words = WordCleaner.processWordPair(spanish: word.spanish, english: word.english)
                    await vocabularyVM.addWords(words)
                }
            }
            dismiss()
        }
    }
}

#Preview {
    ImageScanView()
        .environmentObject(VocabularyViewModel())
}


