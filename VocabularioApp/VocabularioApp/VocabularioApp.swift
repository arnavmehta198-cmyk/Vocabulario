//
//  VocabularioApp.swift
//  Vocabulario - Spanish Quiz App
//
//  Main app entry point
//

import SwiftUI
import Firebase

@main
struct VocabularioApp: App {
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(VocabularyViewModel())
                .environmentObject(AuthViewModel())
        }
    }
}

