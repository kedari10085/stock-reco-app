# 🔗 Connect Everything - Quick Setup Guide

**You have installed:**
- ✅ Flutter
- ✅ Android Studio
- ✅ Visual Studio
- ✅ Dart
- ✅ Command Line Tools

**Now let's connect everything and run your app!**

---

## ⚡ Quick Connection Steps

### Step 1: Verify Flutter Installation (2 minutes)

Open **Command Prompt** and run:

```bash
flutter --version
```

**Expected Output:**
```
Flutter 3.x.x • channel stable
Framework • revision xxxxx
Engine • revision xxxxx
Tools • Dart 3.x.x
```

✅ **If you see this, Flutter is installed correctly!**

❌ **If "command not found":**
- Flutter is not in PATH
- Add `C:\src\flutter\bin` to PATH (or wherever you installed Flutter)
- Restart Command Prompt

---

### Step 2: Check System Setup (2 minutes)

```bash
flutter doctor -v
```

**Look for these:**
```
[✓] Flutter (Channel stable)
[✓] Android toolchain - develop for Android devices
[✓] Visual Studio - develop for Windows
[✓] Android Studio
[✓] VS Code (optional)
[✓] Connected device
[✓] Network resources
```

**If you see [✗] or [!]:**
- Read the error message
- Most common: Android licenses not accepted
- Fix: Run `flutter doctor --android-licenses` (press 'y' for all)

---

### Step 3: Accept Android Licenses (2 minutes)

**Run as Administrator:**

```bash
flutter doctor --android-licenses
```

**Press:** `y` and Enter for each license (5-7 times)

**Expected:** "All SDK package licenses accepted"

---

### Step 4: Navigate to Your Project (1 minute)

```bash
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
```

**Verify you're in the right folder:**

```bash
dir
```

**You should see:**
- `pubspec.yaml`
- `lib` folder
- `android` folder
- `assets` folder

---

### Step 5: Install Project Dependencies (5 minutes)

```bash
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in stock_reco_app...
Resolving dependencies...
+ cloud_firestore 4.14.0
+ firebase_auth 4.16.0
+ firebase_core 2.24.2
... (many more packages)
Got dependencies!
```

✅ **Success:** "Got dependencies!"

❌ **If errors:**
- Check internet connection
- Run: `flutter clean` then `flutter pub get` again

---

### Step 6: Configure Firebase Files (5 minutes)

#### A. Check google-services.json

```bash
dir android\app\google-services.json
```

✅ **If file exists:** Good!

❌ **If not found:**
```bash
# Check if it's in root folder
dir google-services.json

# If found, move it:
move google-services.json android\app\
```

#### B. Create .env file

```bash
# Check if .env exists
dir assets\.env
```

❌ **If not found, create it:**

```bash
# Copy from example
copy .env.example assets\.env

# Edit the file
notepad assets\.env
```

**Add your Firebase credentials:**
```env
FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FIREBASE_APP_ID=1:123456789:android:xxxxxxxxxxxxx
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_PROJECT_ID=your-project-id
ALPHA_VANTAGE_API_KEY=demo
```

**Where to get these values:**
1. Go to: https://console.firebase.google.com
2. Select your project
3. Click ⚙️ (Settings) → Project settings
4. Scroll to "Your apps" → Android app
5. Copy the values

**Save and close Notepad**

---

### Step 7: Create/Start Android Emulator (5 minutes)

#### Option A: Check if emulator exists

```bash
flutter emulators
```

**If you see emulators listed:**
```bash
# Launch it (replace with your emulator name)
flutter emulators --launch Pixel_6_API_33
```

#### Option B: Create new emulator in Android Studio

1. **Open Android Studio**
2. **Click:** "More Actions" → "Device Manager"
3. **If no devices:**
   - Click "Create Device"
   - Select "Pixel 6" → Next
   - Select "Tiramisu" (API 33) → Download (if needed)
   - Click Next → Finish
4. **Click ▶️** to start emulator
5. **Wait** for emulator to boot (1-2 minutes)

**Verify emulator is running:**
```bash
flutter devices
```

**Expected:**
```
2 connected devices:

Pixel 6 API 33 (mobile) • emulator-5554 • android-x86 • Android 13 (API 33)
Windows (desktop)       • windows       • windows-x64  • Microsoft Windows
```

---

### Step 8: Run the App! (10 minutes first time)

```bash
flutter run
```

**What happens:**
1. ✅ Gradle build starts (5-10 minutes first time)
2. ✅ Dependencies downloaded
3. ✅ App compiled
4. ✅ App installed on emulator
5. ✅ App launches

**Expected Output:**
```
Launching lib\main.dart on Pixel 6 API 33 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app.apk...
Syncing files to device Pixel 6 API 33...

Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

🔥  To hot reload changes while running, press "r" or "R".
```

**✅ SUCCESS:** App appears on emulator with login screen!

---

## 🎯 Alternative: Open in Android Studio

If you prefer using Android Studio IDE:

### Step 1: Open Project

1. **Launch Android Studio**
2. **Click:** "Open"
3. **Navigate to:** `C:\Users\kedar\OneDrive\Documents\stock_reco_app`
4. **Click:** "OK"
5. **Wait** for Gradle sync (5-10 minutes)

### Step 2: Select Device

1. **Top toolbar:** Device dropdown
2. **Select:** Your emulator (e.g., "Pixel 6 API 33")
3. **If not listed:** Click "Device Manager" and start emulator

### Step 3: Run

1. **Click:** ▶️ (Run) button
2. **Or:** Press `Shift + F10`
3. **Wait** for build and launch

---

## 🧪 Test the App

### Test 1: App Launches
✅ **Expected:** Splash screen → Login screen

### Test 2: Sign Up
1. Click "Sign Up"
2. Enter:
   - Name: Test User
   - Email: test@example.com
   - Password: password123
3. Check "Terms & Conditions"
4. Click "Sign Up"

✅ **Expected:** Email verification screen

### Test 3: Check Firestore
1. Open: https://console.firebase.google.com
2. Go to Firestore Database
3. Check `users` collection

✅ **Expected:** New user document with email, name, user_number

### Test 4: Admin Login
1. Login with: `kedari141@gmail.com`
2. Password: (your password)

✅ **Expected:** Admin drawer (☰) appears in top-left

### Test 5: Admin Panel
1. Click drawer → "Add Recommendation"
2. Fill form:
   - Ticker: TCS
   - Exchange: NSE
   - Buy: 3500
   - Target: 3800
   - Rationale: "Strong IT sector growth..."
3. Click "Save & Notify Users"

✅ **Expected:** Success message, recommendation saved

### Test 6: View Recommendations
1. Go to "Recos" tab (bottom navigation)

✅ **Expected:** TCS card appears with prices

---

## 🐛 Common Issues & Quick Fixes

### Issue 1: "flutter: command not found"

**Fix:**
```bash
# Check Flutter location
where flutter

# If not found, add to PATH:
# 1. Search "Environment Variables" in Start Menu
# 2. Edit "Path" under User variables
# 3. Add: C:\src\flutter\bin (or your Flutter location)
# 4. Restart Command Prompt
```

---

### Issue 2: "Gradle sync failed"

**Fix:**
```bash
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
flutter clean
flutter pub get
```

**In Android Studio:**
- File → Invalidate Caches / Restart
- Click "Restart"

---

### Issue 3: "No devices found"

**Fix:**
```bash
# Check if emulator is running
flutter devices

# If empty, start emulator:
flutter emulators --launch Pixel_6_API_33

# Or open Android Studio → Device Manager → Start emulator
```

---

### Issue 4: "Android licenses not accepted"

**Fix:**
```bash
# Run as Administrator
flutter doctor --android-licenses

# Press 'y' for all licenses
```

---

### Issue 5: "Package not found" errors

**Fix:**
```bash
flutter clean
del pubspec.lock
flutter pub get
```

---

### Issue 6: "google-services.json not found"

**Fix:**
```bash
# Check location
dir android\app\google-services.json

# If not found, move from root:
move google-services.json android\app\

# Verify
dir android\app\google-services.json
```

---

### Issue 7: "Firebase not initialized"

**Fix:**
1. Check `assets\.env` exists
2. Verify Firebase credentials are correct
3. Run:
```bash
flutter clean
flutter pub get
flutter run
```

---

### Issue 8: Build takes too long

**Normal:** First build takes 5-10 minutes
**Subsequent builds:** 1-2 minutes

**If stuck:**
```bash
# Stop the build (Ctrl + C)
# Clean and retry:
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
flutter run
```

---

## 📋 Complete Setup Checklist

Run through this checklist:

- [ ] ✅ `flutter --version` works
- [ ] ✅ `flutter doctor` shows all green checkmarks
- [ ] ✅ Android licenses accepted
- [ ] ✅ Navigated to project folder
- [ ] ✅ `flutter pub get` completed successfully
- [ ] ✅ `google-services.json` in `android/app/`
- [ ] ✅ `assets/.env` created with Firebase credentials
- [ ] ✅ Emulator created and running
- [ ] ✅ `flutter devices` shows emulator
- [ ] ✅ `flutter run` builds successfully
- [ ] ✅ App launches on emulator
- [ ] ✅ Login screen appears
- [ ] ✅ Can sign up new user
- [ ] ✅ Firestore saves data
- [ ] ✅ Admin login works
- [ ] ✅ Admin drawer appears
- [ ] ✅ Can add recommendations

---

## 🎯 Quick Command Reference

### Daily Workflow:

```bash
# 1. Navigate to project
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app

# 2. Start emulator (if not running)
flutter emulators --launch Pixel_6_API_33

# 3. Run app
flutter run

# 4. Make changes in code
# 5. Press 'r' for hot reload
# 6. Press 'R' for hot restart
# 7. Press 'q' to quit
```

### Troubleshooting:

```bash
# Check system
flutter doctor -v

# Clean build
flutter clean
flutter pub get

# List devices
flutter devices

# View logs
flutter logs
```

---

## 🎉 Success Indicators

**You're ready when you see:**

1. ✅ Command Prompt shows:
   ```
   Flutter run key commands.
   r Hot reload.
   ```

2. ✅ Emulator shows app with login screen

3. ✅ No errors in console

4. ✅ Can navigate between screens

5. ✅ Firebase authentication works

---

## 📞 Next Steps

Once app is running:

1. **Test all features:**
   - Sign up / Login
   - Admin panel
   - Add recommendations
   - View live prices

2. **Configure Alpha Vantage:**
   - Get API key: https://www.alphavantage.co/support/#api-key
   - Update `assets/.env`
   - Restart app

3. **Set up Firestore:**
   - Read: `FIREBASE_AUTH_SETUP.md`
   - Create collections
   - Set security rules

4. **Customize app:**
   - Change colors
   - Update branding
   - Add features

---

## 🚀 You're All Set!

**Your app is ready to run!**

Just execute:
```bash
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
flutter run
```

**Happy Coding! 🎉📱**
