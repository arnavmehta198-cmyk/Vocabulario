# Vocabulario iOS App - Quick Start Guide

Get the app running in 10 minutes!

## Prerequisites
- ✅ Mac with Xcode 15+ installed
- ✅ iOS device or simulator with iOS 17+
- ✅ Firebase project already set up (spanishquiz-ea73d)

## 5-Step Setup

### 1️⃣ Open in Xcode (2 min)

```bash
cd "/Users/arnavmehta/F1 Live/VocabularioApp"
# Create new iOS App project in Xcode with these settings:
# - Name: VocabularioApp
# - Interface: SwiftUI  
# - Language: Swift
# - Organization ID: com.vocabulario
```

Or if you have the project file:
```bash
open VocabularioApp.xcodeproj
```

### 2️⃣ Add Dependencies (3 min)

In Xcode:
- `File` → `Add Package Dependencies`
- Add: `https://github.com/firebase/firebase-ios-sdk.git`
  - Select: `FirebaseAuth`, `FirebaseFirestore`
- Add: `https://github.com/google/GoogleSignIn-iOS.git`

### 3️⃣ Configure Firebase (2 min)

1. Go to [Firebase Console](https://console.firebase.google.com/project/spanishquiz-ea73d/settings/general/ios)
2. Click "Add app" → iOS
3. Bundle ID: `com.vocabulario.app`
4. Download `GoogleService-Info.plist`
5. **Drag into Xcode** (check "Copy items if needed")

### 4️⃣ Update Info.plist (1 min)

In `Info.plist`, find `CFBundleURLSchemes` and add your `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`:

```xml
<string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID_HERE</string>
```

### 5️⃣ Build & Run! (2 min)

1. Select target: iPhone 15 Pro (or your device)
2. Press `Cmd+R`
3. App launches! 🎉

## What You Get

✨ **All Features from Website:**
- ✅ Add vocabulary words
- ✅ Spanish gender variations (soltero/a → 2 words)
- ✅ Quiz with two modes
- ✅ Google Sign-in
- ✅ Cloud sync with Firebase
- ✅ OCR image scanning
- ✅ Word cleaning & simplification
- ✅ Offline support

## Test It

1. **Add a word:** soltero/a → single
2. **See it expand:** Creates "soltero" and "soltera"
3. **Take quiz:** Test your knowledge
4. **Sign in:** Tap Profile → Sign in with Google
5. **Scan image:** Take photo of vocabulary list

## Common Issues

**Can't find Firebase packages?**
→ Clean build folder: `Cmd+Shift+K`, then rebuild

**Google Sign-In fails?**
→ Check REVERSED_CLIENT_ID in Info.plist matches GoogleService-Info.plist

**OCR not working?**
→ Grant photo permissions in iOS Settings

## Next Steps

- Add app icon to Assets.xcassets
- Test on real device
- Submit to App Store!

---

Need help? Check the full README.md

Happy coding! 🚀

