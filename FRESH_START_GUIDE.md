# 🔄 Fresh Start - New Firebase Project

Complete guide to setting up a brand new Firebase project for Helix.

---

## ✅ **Why Start Fresh?**

- Clean slate - no OAuth configuration issues
- New Google account if needed
- Avoid old project complications
- Better understanding of the setup process

---

## 🚀 **Step-by-Step Setup (20 minutes)**

### **STEP 1: Reset Current Configuration**

On your Mac Terminal:

```bash
cd /path/to/your/helix

# Run the reset script
./reset_firebase.sh

# Follow the prompts
```

This will:
- Backup your old configuration
- Remove all Firebase config files
- Clean the Flutter build
- Prepare for fresh setup

---

### **STEP 2: Create New Firebase Project**

1. **Go to Firebase Console**
   - Open: https://console.firebase.google.com/
   - Sign in with your Google account (can be new or existing)

2. **Create Project**
   - Click **"Add project"** or **"Create a project"**
   - **Project name**: `helix-app` (or any name you prefer)
   - Click **"Continue"**

3. **Google Analytics** (optional)
   - Toggle ON or OFF (your choice, not required for MVP)
   - Click **"Continue"**

4. **Create**
   - If Analytics ON: Select account or create new
   - Click **"Create project"**
   - Wait 30-60 seconds for project creation
   - Click **"Continue"** when ready

---

### **STEP 3: Enable Authentication**

1. In your new Firebase project, click **"Build"** → **"Authentication"**

2. Click **"Get started"**

3. Click **"Sign-in method"** tab

4. Find **"Google"** in the list

5. Click on **"Google"**

6. Toggle the **"Enable"** switch

7. **Project support email**: Select your email from dropdown

8. Click **"Save"**

✅ Google Authentication is now enabled!

---

### **STEP 4: Create Firestore Database**

1. Click **"Build"** → **"Firestore Database"**

2. Click **"Create database"**

3. **Security rules**:
   - Select **"Start in test mode"**
   - (We'll add proper rules later)

4. **Cloud Firestore location**:
   - Choose closest region:
     - `us-central1` (Iowa) - North America
     - `europe-west1` (Belgium) - Europe
     - `asia-northeast1` (Tokyo) - Asia
   - Click **"Enable"**

5. Wait 1-2 minutes for database creation

✅ Firestore Database is ready!

---

### **STEP 5: Add Security Rules**

While still in Firestore:

1. Click **"Rules"** tab

2. Replace the content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can access their own data
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);

      match /activities/{activityId} {
        allow read, write: if isOwner(userId);
      }

      match /sessions/{sessionId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

3. Click **"Publish"**

✅ Secure rules are in place!

---

### **STEP 6: Configure Flutter App**

Now we'll connect your Flutter app to this new Firebase project.

1. **Make sure you're logged into Firebase CLI:**

```bash
# Login to Firebase (opens browser)
firebase login

# If already logged in, verify:
firebase projects:list
```

2. **Run FlutterFire Configure:**

```bash
cd helix-app

# This will configure your app for Firebase
flutterfire configure
```

3. **Select your new project:**
   - You'll see a list of your Firebase projects
   - Use arrow keys to navigate
   - Select your **new project** (helix-app or whatever you named it)
   - Press **Enter**

4. **Select platforms:**
   - You'll see: iOS, Android, macOS, Web, Windows
   - Press **Space** to select: **iOS, Android, Web**
   - Press **Enter** to confirm

5. **Confirm:**
   - iOS Bundle ID: `com.helix.helix` ✓
   - Android Package: `com.helix.helix` ✓
   - Press **Enter**

6. **Wait for configuration:**
   - FlutterFire will create/update files
   - You'll see:
     - ✓ Creating firebase_options.dart
     - ✓ Configuring android/app/google-services.json
     - ✓ Configuring ios/Runner/GoogleService-Info.plist

✅ Flutter app is configured!

---

### **STEP 7: Get Dependencies**

```bash
# Still in helix-app directory
flutter pub get
```

---

### **STEP 8: Test on Mobile First** (Recommended!)

Mobile is easier because OAuth works out of the box.

**For iOS:**

```bash
# Open iOS Simulator
open -a Simulator

# Run app
flutter run
```

**For Android:**

```bash
# Make sure Android emulator is running

# Run app
flutter run
```

**Test:**
1. App should open
2. Click "Continue with Google"
3. Sign in with your Google account
4. You should be logged in! 🎉

✅ If mobile works, you're all set!

---

### **STEP 9: Configure Web (Optional)**

If you want to test on web browser:

1. **Get Web Client ID** (follow `WHERE_TO_FIND_CLIENT_ID.md`)

2. **Update web/index.html:**
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">
   ```

3. **Configure OAuth Consent Screen** (follow `FIX_OAUTH_ERROR.md`)

4. **Run on web:**
   ```bash
   flutter run -d chrome
   ```

---

## 🎉 **Success Checklist**

After setup, you should have:

- [x] New Firebase project created
- [x] Google Authentication enabled
- [x] Firestore Database created with rules
- [x] Flutter app configured (firebase_options.dart exists)
- [x] Can sign in on mobile
- [ ] Can sign in on web (optional for now)

---

## 📂 **What Got Created/Updated**

```
helix-app/
├── lib/
│   └── firebase_options.dart          ← NEW (auto-generated)
├── android/
│   └── app/
│       └── google-services.json       ← UPDATED
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist   ← UPDATED
└── web/
    └── index.html                     ← Need to add Client ID
```

---

## 🐛 **Troubleshooting**

### **"flutterfire: command not found"**
```bash
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### **"firebase: command not found"**
```bash
npm install -g firebase-tools
firebase login
```

### **Can't find new project in flutterfire configure**
```bash
# Logout and login again
firebase logout
firebase login

# Try configure again
flutterfire configure
```

### **OAuth error on mobile**
- Make sure Google Authentication is **Enabled** in Firebase Console
- Check you're using the same Google account

### **Firestore permission denied**
- Check security rules are published
- Make sure user is signed in

---

## 💾 **Old Configuration Backup**

Your old Firebase config is saved in:
```
helix/firebase-backup/
├── firebase_options.dart
├── google-services.json
├── GoogleService-Info.plist
└── index.html
```

You can delete this folder once everything works.

---

## 🎯 **Next Steps After Setup**

Once authentication works:

1. ✅ Test sign in/out
2. ✅ Verify user created in Firestore (check Firebase Console → Firestore)
3. ✅ Let me know it's working!
4. 🚀 I'll build the rest of the app features!

---

## ❓ **Need Help?**

If you get stuck:
1. Note which step you're on
2. Share any error messages
3. I'll help you troubleshoot!

---

## 📞 **Quick Commands Reference**

```bash
# Reset Firebase config
./reset_firebase.sh

# Login to Firebase
firebase login

# Configure Flutter app
cd helix-app
flutterfire configure

# Run on mobile
flutter run

# Run on web
flutter run -d chrome

# Clean build if issues
flutter clean
flutter pub get
```

---

🎉 **You're ready to start fresh! Let's go!** 🚀
