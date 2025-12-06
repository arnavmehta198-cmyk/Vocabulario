//
//  ProfileView.swift
//  Vocabulario
//
//  User profile and settings
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var vocabularyVM: VocabularyViewModel
    
    var body: some View {
        NavigationView {
            List {
                if authVM.isAuthenticated, let user = authVM.user {
                    // User info section
                    Section {
                        HStack(spacing: 16) {
                            if let photoURL = user.photoURL {
                                AsyncImage(url: photoURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color("BackgroundCard")
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color("AccentColor"))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName ?? "User")
                                    .font(.headline)
                                
                                Text(user.email ?? "")
                                    .font(.caption)
                                    .foregroundColor(Color("TextSecondary"))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Stats section
                    Section("Statistics") {
                        HStack {
                            Text("Total Words")
                            Spacer()
                            Text("\(vocabularyVM.words.count)")
                                .foregroundColor(Color("AccentColor"))
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Sync Status")
                            Spacer()
                            if vocabularyVM.isSyncing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Label("Synced", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    // Actions section
                    Section {
                        Button(role: .destructive) {
                            authVM.signOut()
                        } label: {
                            Label("Sign Out", systemImage: "arrow.right.square")
                        }
                    }
                    
                } else {
                    // Sign in section
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 60))
                                .foregroundColor(Color("AccentColor"))
                            
                            Text("Sign in to sync your vocabulary across devices")
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color("TextSecondary"))
                            
                            Button {
                                Task {
                                    await authVM.signInWithGoogle()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                    Text("Sign in with Google")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Local stats
                    Section("Local Statistics") {
                        HStack {
                            Text("Words Stored Locally")
                            Spacer()
                            Text("\(vocabularyVM.words.count)")
                                .foregroundColor(Color("AccentColor"))
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                // About section
                Section("About") {
                    Link(destination: URL(string: "https://github.com/arnavmehta198-cmyk/Vocabulario")!) {
                        Label("GitHub Repository", systemImage: "link")
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(VocabularyViewModel())
}

