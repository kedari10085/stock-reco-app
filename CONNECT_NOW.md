# 🚀 CONNECT NOW - Get Your App Running!

**You have installed: Flutter, Android Studio, Visual Studio, Dart**  
**Let's connect everything and run the app in 15 minutes!**

---

## ⚡ Super Quick Start

### Option 1: Automated Setup (Recommended)

**Double-click this file:**
```
quick_setup.bat
```

This will:
1. ✅ Check if Flutter is in PATH
2. ✅ Accept Android licenses
3. ✅ Move google-services.json to correct location
4. ✅ Create .env file
5. ✅ Install dependencies
6. ✅ Check system setup
7. ✅ List available devices

**Then run:**
```
flutter run
```

---

### Option 2: Manual Setup (If automated fails)

Follow these steps in **Command Prompt**:

#### Step 1: Add Flutter to PATH (if needed)

**Test if Flutter is accessible:**
```bash
flutter --version
```

**If "command not found":**

1. **Find Flutter location:**
   - Usually: `C:\src\flutter\bin`
   - Or wherever you extracted Flutter

2. **Add to PATH:**
   - Press `Win + R`
   - Type: `sysdm.cpl` and press Enter
   - Click "Environment Variables"
   - Under "User variables", select "Path"
   - Click "Edit"
   - Click "New"
   - Add: `C:\src\flutter\bin` (your Flutter path)
   - Click OK on all dialogs

3. **Restart Command Prompt**

4. **Test again:**
   ```bash
   flutter --version
   ```

---

#### Step 2: Accept Android Licenses

**Open Command Prompt as Administrator:**
- Right-click Command Prompt → "Run as administrator"

```bash
flutter doctor --android-licenses
```

**Press `y` and Enter for each license**

---

#### Step 3: Navigate to Project

```bash
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
```

---

#### Step 4: Move google-services.json

```bash
# Check if it's in the right place
dir android\app\google-services.json
```

**If not found:**
```bash
# Check root folder
dir google-services.json

# If found, move it
move google-services.json android\app\
```

---

#### Step 5: Create .env File

```bash
# Copy example
copy .env.example assets\.env

# Edit with your Firebase credentials
notepad assets\.env
```

**Add these values:**
```env
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id
ALPHA_VANTAGE_API_KEY=demo
```

**Get credentials from:**
- https://console.firebase.google.com
- Your project → Settings → Project settings
- Scroll to "Your apps" → Android app

**Save and close**

---

#### Step 6: Install Dependencies

```bash
flutter pub get
```

**Wait 2-5 minutes**

**Expected:** "Got dependencies!"

---

#### Step 7: Check System

```bash
flutter doctor -v
```

**Look for:**
- [✓] Flutter
- [✓] Android toolchain
- [✓] Android Studio
- [✓] VS Code or Visual Studio
- [✓] Connected device

---

#### Step 8: Start Emulator

**Check available emulators:**
```bash
flutter emulators
```

**Start one:**
```bash
flutter emulators --launch Pixel_6_API_33
```

**Or use Android Studio:**
1. Open Android Studio
2. Click "Device Manager"
3. Click ▶️ on any emulator

**Verify it's running:**
```bash
flutter devices
```

---

#### Step 9: Run the App!

```bash
flutter run
```

**First build:** 5-10 minutes  
**Subsequent builds:** 1-2 minutes

**Expected:** App launches on emulator with login screen

---

## 🎯 Using Android Studio (Alternative)

If you prefer IDE:

### Step 1: Open Project

1. **Launch Android Studio**
2. **Click:** "Open"
3. **Select:** `C:\Users\kedar\OneDrive\Documents\stock_reco_app`
4. **Click:** "OK"
5. **Wait** for Gradle sync (5-10 minutes)

### Step 2: Configure Files

1. **Verify google-services.json:**
   - Expand: `android` → `app`
   - Should see: `google-services.json`
   - If not, move it there

2. **Create .env:**
   - Expand: `assets`
   - Right-click → New → File
   - Name: `.env`
   - Copy content from `.env.example`
   - Add your Firebase credentials

### Step 3: Install Dependencies

**In Android Studio Terminal (Alt + F12):**
```bash
flutter pub get
```

### Step 4: Select Device

**Top toolbar:**
- Device dropdown → Select your emulator
- If none, click "Device Manager" → Create/Start emulator

### Step 5: Run

**Click:** ▶️ (Run) button  
**Or:** Press `Shift + F10`

---

## 🧪 Verify Everything Works

### Test 1: Flutter Command
```bash
flutter --version
```
✅ **Expected:** Shows Flutter version

### Test 2: Flutter Doctor
```bash
flutter doctor
```
✅ **Expected:** All green checkmarks (or minor warnings)

### Test 3: Project Dependencies
```bash
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
flutter pub get
```
✅ **Expected:** "Got dependencies!"

### Test 4: Device Available
```bash
flutter devices
```
✅ **Expected:** Shows at least one device (emulator or Windows)

### Test 5: App Runs
```bash
flutter run
```
✅ **Expected:** App builds and launches

---

## 🐛 Common Issues

### Issue 1: "flutter: command not found"

**Cause:** Flutter not in PATH

**Fix:**
1. Find Flutter folder (e.g., `C:\src\flutter`)
2. Add `C:\src\flutter\bin` to PATH
3. Restart Command Prompt
4. Test: `flutter --version`

---

### Issue 2: "Android licenses not accepted"

**Fix:**
```bash
# Run as Administrator
flutter doctor --android-licenses

# Press 'y' for all
```

---

### Issue 3: "Gradle sync failed"

**Fix:**
```bash
flutter clean
flutter pub get
```

**In Android Studio:**
- File → Invalidate Caches / Restart

---

### Issue 4: "No devices found"

**Fix:**
```bash
# List emulators
flutter emulators

# Start one
flutter emulators --launch Pixel_6_API_33
```

**Or:**
- Open Android Studio → Device Manager → Start emulator

---

### Issue 5: "google-services.json not found"

**Fix:**
```bash
# Check location
dir android\app\google-services.json

# If not there, move it
move google-services.json android\app\
```

---

### Issue 6: "Firebase not initialized"

**Fix:**
1. Check `assets\.env` exists
2. Verify Firebase credentials
3. Run:
```bash
flutter clean
flutter pub get
flutter run
```

---

### Issue 7: "Package not found"

**Fix:**
```bash
flutter clean
del pubspec.lock
flutter pub get
```

---

## 📋 Quick Checklist

Before running app, verify:

- [ ] Flutter installed and in PATH (`flutter --version` works)
- [ ] Android licenses accepted (`flutter doctor` shows ✓)
- [ ] Project folder opened (`cd` to stock_reco_app)
- [ ] Dependencies installed (`flutter pub get` completed)
- [ ] `google-services.json` in `android/app/`
- [ ] `assets/.env` created with Firebase credentials
- [ ] Emulator running or device connected (`flutter devices` shows device)
- [ ] Ready to run (`flutter run`)

---

## 🎯 Quick Commands

```bash
# Navigate to project
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app

# Check Flutter
flutter --version
flutter doctor

# Install dependencies
flutter pub get

# List devices
flutter devices

# Start emulator
flutter emulators --launch Pixel_6_API_33

# Run app
flutter run

# While running:
# Press 'r' for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

---

## 🎉 Success!

**You're ready when:**

1. ✅ `flutter --version` shows version
2. ✅ `flutter doctor` shows green checkmarks
3. ✅ `flutter devices` shows your emulator
4. ✅ `flutter run` builds successfully
5. ✅ App appears on emulator
6. ✅ Login screen loads

---

## 📞 What's Next?

Once app is running:

1. **Test Authentication:**
   - Sign up with test email
   - Verify in Firebase Console

2. **Test Admin Features:**
   - Login as `kedari141@gmail.com`
   - Check admin drawer appears
   - Add stock recommendation

3. **Configure APIs:**
   - Get Alpha Vantage API key
   - Update `assets/.env`
   - Restart app

4. **Read Documentation:**
   - `FIREBASE_AUTH_SETUP.md` - Firebase setup
   - `ADMIN_RECOMMENDATIONS_SETUP.md` - Admin features
   - `TROUBLESHOOTING.md` - Common issues

---

## 🚀 Ready to Run!

**Execute these commands:**

```bash
cd C:\Users\kedar\OneDrive\Documents\stock_reco_app
flutter pub get
flutter run
```

**Or double-click:** `quick_setup.bat`

**Your app will launch in 10 minutes!** 🎉

---

**Need help? Check:**
- `CONNECT_EVERYTHING.md` - Detailed connection guide
- `TROUBLESHOOTING.md` - Common issues
- `COMMANDS_CHEATSHEET.md` - All commands

**Happy Coding! 🚀📱**
