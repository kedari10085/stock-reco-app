# 🎯 Commands Cheatsheet - Copy & Paste

**All commands you need to run the StockReco Pro app**

---

## 📥 Download Links (Open in Browser)

```
Android Studio:
https://developer.android.com/studio

Flutter SDK:
https://docs.flutter.dev/get-started/install/windows

Firebase Console:
https://console.firebase.google.com
```

---

## 🔧 Installation Commands

### Check if Flutter is Installed
```bash
flutter --version
```

**Expected Output:**
```
Flutter 3.x.x • channel stable
```

**If not found:** Install Flutter (see INSTALLATION_GUIDE.md)

---

### Check System Setup
```bash
flutter doctor -v
```

**Expected Output:**
```
[✓] Flutter
[✓] Android toolchain
[✓] Chrome
[✓] Android Studio
[✓] Connected device
[✓] Network resources
```

---

### Accept Android Licenses (Run as Administrator)
```bash
flutter doctor --android-licenses
```

**Then press:** `y` and Enter for each license

---

## 📂 Project Setup Commands

### Navigate to Project
```bash
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
```

---

### Install Dependencies
```bash
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in stock_reco_app...
Got dependencies!
```

---

### Clean Project (if needed)
```bash
flutter clean
```

---

### Clean and Reinstall
```bash
flutter clean
flutter pub get
```

---

## 🔥 Firebase Setup Commands

### Check google-services.json Location
```bash
dir android\app\google-services.json
```

**Expected:** File exists

**If not found, move it:**
```bash
move google-services.json android\app\google-services.json
```

---

### Create .env File
```bash
# Copy example
copy .env.example assets\.env

# Then edit assets\.env with your Firebase credentials
notepad assets\.env
```

**Add these lines:**
```env
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_APP_ID=your_firebase_app_id_here
FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here
FIREBASE_PROJECT_ID=your_project_id_here
ALPHA_VANTAGE_API_KEY=demo
```

---

## 📱 Emulator Commands

### List Available Emulators
```bash
flutter emulators
```

**Expected Output:**
```
2 available emulators:

Pixel_6_API_33 • Pixel 6 API 33 • Google • android

To run an emulator, run 'flutter emulators --launch <emulator id>'.
```

---

### Launch Emulator
```bash
flutter emulators --launch Pixel_6_API_33
```

**Or launch from Android Studio:**
- Tools → Device Manager → Click ▶️

---

### List Connected Devices
```bash
flutter devices
```

**Expected Output:**
```
2 connected devices:

Pixel 6 API 33 (mobile) • emulator-5554 • android-x86 • Android 13 (API 33)
Chrome (web)            • chrome        • web-javascript • Google Chrome 120.0
```

---

## 🚀 Run App Commands

### Run on Connected Device
```bash
flutter run
```

**First build:** 5-10 minutes  
**Subsequent builds:** 1-2 minutes

---

### Run with Verbose Logging
```bash
flutter run -v
```

**Use this for debugging errors**

---

### Run on Specific Device
```bash
flutter run -d emulator-5554
```

**Replace `emulator-5554` with your device ID from `flutter devices`**

---

### Run in Release Mode (Faster)
```bash
flutter run --release
```

**Note:** No hot reload in release mode

---

## 🔄 While App is Running

### Hot Reload (Quick Refresh)
```
Press: r
```

**Reloads code changes without restarting app**

---

### Hot Restart (Full Restart)
```
Press: R
```

**Restarts app from scratch**

---

### View Logs
```
Press: v
```

**Or in separate terminal:**
```bash
flutter logs
```

---

### Quit App
```
Press: q
```

---

## 🏗️ Build Commands

### Build APK (Release)
```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

### Build APK (Debug)
```bash
flutter build apk --debug
```

---

### Build App Bundle (for Play Store)
```bash
flutter build appbundle
```

---

## 🧹 Clean & Fix Commands

### Clean Build Files
```bash
flutter clean
```

---

### Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

---

### Clean Gradle (Android)
```bash
cd android
gradlew clean
cd ..
flutter clean
flutter pub get
```

---

### Fix Gradle Issues
```bash
cd android
gradlew clean
gradlew build
cd ..
```

---

### Update Dependencies
```bash
flutter pub upgrade
```

---

### Get Outdated Packages
```bash
flutter pub outdated
```

---

## 🔍 Debugging Commands

### Analyze Code
```bash
flutter analyze
```

**Checks for errors and warnings**

---

### Run Tests
```bash
flutter test
```

---

### Check Performance
```bash
flutter run --profile
```

---

### Enable DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

---

## 📊 Project Info Commands

### Show Flutter Version
```bash
flutter --version
```

---

### Show Dart Version
```bash
dart --version
```

---

### Show Project Dependencies
```bash
flutter pub deps
```

---

### Show Project Tree
```bash
flutter pub deps --tree
```

---

## 🔥 Firebase Commands (Optional)

### Install Firebase CLI
```bash
npm install -g firebase-tools
```

---

### Login to Firebase
```bash
firebase login
```

---

### Initialize Firebase
```bash
firebase init
```

---

### Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

---

### Deploy Cloud Functions
```bash
firebase deploy --only functions
```

---

## 🎨 Android Studio Shortcuts

### Open Terminal
```
Alt + F12
```

---

### Run App
```
Shift + F10
```

---

### Debug App
```
Shift + F9
```

---

### Stop App
```
Ctrl + F2
```

---

### Hot Reload
```
Ctrl + \
```

---

### Find File
```
Ctrl + Shift + N
```

---

### Search Everywhere
```
Double Shift
```

---

### Format Code
```
Ctrl + Alt + L
```

---

## 🐛 Common Error Fixes

### Error: "Gradle sync failed"
```bash
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
```

---

### Error: "Package not found"
```bash
flutter pub get
flutter pub upgrade
```

---

### Error: "Firebase not initialized"
```bash
# Check files exist:
dir android\app\google-services.json
dir assets\.env

# If missing, create them
# Then:
flutter clean
flutter pub get
flutter run
```

---

### Error: "Emulator won't start"
```bash
# List emulators
flutter emulators

# Try launching specific one
flutter emulators --launch Pixel_6_API_33

# Or create new one in Android Studio:
# Tools → Device Manager → Create Device
```

---

### Error: "Android licenses not accepted"
```bash
# Run as Administrator
flutter doctor --android-licenses

# Press 'y' for all
```

---

### Error: "Build failed"
```bash
# Nuclear option - clean everything
flutter clean
del pubspec.lock
flutter pub get
cd android
gradlew clean
cd ..
flutter run
```

---

## 📋 Quick Test Sequence

### After Installation, Run These:
```bash
# 1. Check Flutter
flutter --version

# 2. Check system
flutter doctor -v

# 3. Navigate to project
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app

# 4. Install dependencies
flutter pub get

# 5. List devices
flutter devices

# 6. Run app
flutter run
```

---

## 🎯 Daily Development Workflow

### Start Development Session:
```bash
# 1. Navigate to project
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app

# 2. Update dependencies (if needed)
flutter pub get

# 3. Start emulator (or use physical device)
flutter emulators --launch Pixel_6_API_33

# 4. Run app
flutter run
```

---

### Make Changes:
1. Edit code in Android Studio
2. Press `r` for hot reload
3. Press `R` for hot restart (if needed)

---

### End Session:
1. Press `q` to quit app
2. Close emulator

---

## 📞 Help Commands

### Get Help
```bash
flutter help
```

---

### Get Help for Specific Command
```bash
flutter run --help
flutter build --help
flutter doctor --help
```

---

### Check Flutter Channel
```bash
flutter channel
```

---

### Switch to Stable Channel
```bash
flutter channel stable
flutter upgrade
```

---

## 🎉 Success Indicators

### You're Ready When:
```bash
# This shows all green checkmarks
flutter doctor -v

# This works without errors
flutter run

# App launches on emulator
# Login screen appears
```

---

## 📝 Copy-Paste Setup Script

**Run this in Command Prompt (after Flutter installed):**

```bash
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
flutter pub get
flutter doctor -v
flutter devices
flutter run
```

---

## 🚨 Emergency Reset

**If everything is broken, run this:**

```bash
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
flutter clean
del pubspec.lock
cd android
gradlew clean
cd ..
flutter pub get
flutter doctor -v
flutter run
```

---

## ✅ Verification Script

**Run to verify everything works:**

```bash
echo "=== Checking Flutter ==="
flutter --version

echo "=== Checking System ==="
flutter doctor

echo "=== Checking Project ==="
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
flutter pub get

echo "=== Checking Devices ==="
flutter devices

echo "=== All checks complete ==="
```

---

**Save this file for quick reference!** 📌

**Bookmark these commands - you'll use them daily!** 🔖
