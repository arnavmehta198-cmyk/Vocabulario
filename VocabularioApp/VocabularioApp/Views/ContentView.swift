//
//  ContentView.swift
//  Vocabulario
//
//  Main view with tab navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vocabularyVM: VocabularyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        TabView {
            WordListView()
                .tabItem {
                    Label("Words", systemImage: "book.fill")
                }
            
            QuizStartView()
                .tabItem {
                    Label("Quiz", systemImage: "brain.head.profile")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
        .accentColor(Color("AccentColor"))
    }
}

#Preview {
    ContentView()
        .environmentObject(VocabularyViewModel())
        .environmentObject(AuthViewModel())
}

