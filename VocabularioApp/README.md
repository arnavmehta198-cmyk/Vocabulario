# Vocabulario - Spanish Quiz iOS App

A native iOS app for learning Spanish vocabulary with quiz features, Google Sign-In, Firebase sync, and OCR scanning.

## Features

✨ **Core Features:**
- Add Spanish-English word pairs
- Interactive quiz with two modes (Spanish→English, English→Spanish)
- Automatic gender variation expansion (soltero/a → soltero + soltera)
- Word cleaning (removes parentheses, content after /, simplifies definitions)
- OCR image scanning using Vision framework
- Fuzzy answer matching

🔐 **Authentication & Sync:**
- Google Sign-In integration
- Firebase Authentication
- Cloud sync with Firestore
- Offline support with local storage

## Requirements

- macOS with Xcode 15.0 or later
- iOS 17.0 or later
- Active Firebase project
- Google Sign-In credentials

## Setup Instructions

### 1. Clone the Repository

```bash
cd "/Users/arnavmehta/F1 Live/VocabularioApp"
```

### 2. Open in Xcode

```bash
open VocabularioApp.xcodeproj
```

If the `.xcodeproj` doesn't exist, create it:
1. Open Xcode
2. File → New → Project
3. Choose "iOS App"
4. Product Name: `VocabularioApp`
5. Interface: SwiftUI
6. Language: Swift
7. Save in the VocabularioApp directory

### 3. Add Swift Packages

In Xcode:
1. File → Add Package Dependencies
2. Add these packages:

**Firebase iOS SDK:**
```
https://github.com/firebase/firebase-ios-sdk.git
```
Select: `FirebaseAuth`, `FirebaseFirestore`

**Google Sign-In:**
```
https://github.com/google/GoogleSignIn-iOS.git
```

### 4. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/project/spanishquiz-ea73d)
2. Add iOS app to your project:
   - Bundle ID: `com.vocabulario.app` (or your chosen bundle ID)
   - Download `GoogleService-Info.plist`
3. **Important:** Add the downloaded file to your Xcode project:
   - Drag `GoogleService-Info.plist` into Xcode
   - Make sure "Copy items if needed" is checked
   - Add to VocabularioApp target

4. In `Info.plist`, update the `REVERSED_CLIENT_ID`:
   - Find the `REVERSED_CLIENT_ID` value in your `GoogleService-Info.plist`
   - Add it to the URL schemes in `Info.plist`

### 5. Enable Firebase Services

In Firebase Console:

**Authentication:**
1. Go to Authentication → Sign-in method
2. Enable Google
3. Add iOS bundle ID
4. Download updated `GoogleService-Info.plist` if prompted

**Firestore:**
1. Go to Firestore Database
2. Create database in test mode
3. Choose location (e.g., `us-west2`)

### 6. Configure Bundle ID and Signing

In Xcode:
1. Select project in navigator
2. Select VocabularioApp target
3. Go to "Signing & Capabilities"
4. Select your team
5. Ensure bundle ID matches Firebase: `com.vocabulario.app`

### 7. Add Required Capabilities

Xcode → Project → Signing & Capabilities → + Capability:
- Sign in with Apple (if needed)

### 8. Build and Run

1. Select your target device or simulator (iOS 17.0+)
2. Press `Cmd+R` or click Play button
3. App should build and run successfully

## Project Structure

```
VocabularioApp/
├── VocabularioApp/
│   ├── VocabularioApp.swift          # App entry point
│   ├── Models/
│   │   ├── Word.swift                # Word model
│   │   └── QuizMode.swift            # Quiz mode enum
│   ├── Views/
│   │   ├── ContentView.swift         # Main tab view
│   │   ├── WordListView.swift        # Word list & management
│   │   ├── AddWordView.swift         # Add word form
│   │   ├── QuizStartView.swift       # Quiz setup
│   │   ├── QuizView.swift            # Quiz interface
│   │   ├── ProfileView.swift         # User profile
│   │   └── ImageScanView.swift       # OCR scanning
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift       # Authentication logic
│   │   └── VocabularyViewModel.swift # Vocabulary management
│   ├── Utilities/
│   │   └── WordCleaner.swift         # Word processing utilities
│   ├── Resources/
│   │   ├── Assets.xcassets/          # Colors and assets
│   │   └── GoogleService-Info.plist  # Firebase config (add this)
│   └── Info.plist                    # App configuration
├── Package.swift                     # SPM dependencies
└── README.md                         # This file
```

## Usage

### Adding Words
1. Tap "+" button in Words tab
2. Enter Spanish and English
3. Use formats like `soltero/a` for gender variations
4. Tap "Add"

### Scanning Images
1. Tap "+" → "Scan Image"
2. Choose photo with vocabulary
3. App extracts word pairs automatically
4. Review and add to vocabulary

### Taking Quiz
1. Go to Quiz tab
2. Select mode (Spanish→English or English→Spanish)
3. Enable/disable fuzzy matching
4. Tap "Start Quiz"
5. Type answers and check

### Sign In
1. Go to Profile tab
2. Tap "Sign in with Google"
3. Complete Google authentication
4. Vocabulary syncs to cloud automatically

## Troubleshooting

### Build Errors

**"Cannot find 'Firebase' in scope"**
- Make sure Firebase packages are added
- Clean build folder: Product → Clean Build Folder (`Cmd+Shift+K`)
- Restart Xcode

**"GoogleService-Info.plist not found"**
- Download from Firebase Console
- Drag into Xcode project
- Ensure "Copy items if needed" is checked

### Runtime Errors

**"Firebase not configured"**
- Check GoogleService-Info.plist is in app bundle
- Verify Info.plist has correct REVERSED_CLIENT_ID

**"Sign in failed"**
- Ensure Google Sign-In is enabled in Firebase Console
- Check bundle ID matches Firebase configuration
- Verify URL schemes in Info.plist

### OCR Not Working

**"Photo library access denied"**
- Go to iOS Settings → VocabularioApp → Photos
- Grant access

**"Scanning fails"**
- Ensure image has clear, readable text
- Works best with high-contrast images
- Supported formats: Spanish - English

## App Store Submission

Before submitting:

1. Update version and build numbers
2. Add app icons to Assets.xcassets
3. Create screenshots
4. Write App Store description
5. Set deployment target to iOS 17.0+
6. Switch Firebase to production mode
7. Enable proper Firestore security rules

## Firebase Security Rules

For production, update Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /vocabulary/{wordId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## License

MIT License - See website repository for details.

## Links

- **Website:** https://arnavmehta198-cmyk.github.io/Vocabulario/spanish-quiz.html
- **Repository:** https://github.com/arnavmehta198-cmyk/Vocabulario
- **Firebase Console:** https://console.firebase.google.com/project/spanishquiz-ea73d

## Support

For issues or questions:
1. Check this README
2. Review Firebase Console logs
3. Check Xcode console output
4. Create GitHub issue

---

Built with ❤️ using SwiftUI, Firebase, and Vision

