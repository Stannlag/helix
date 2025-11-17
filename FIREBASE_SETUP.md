# Firebase Setup Guide for Helix
## Complete Firebase Configuration

This guide will help you set up Firebase for your Flutter app across all platforms (iOS, Android, Web).

---

## PART 1: Create Firebase Project

### Step 1: Go to Firebase Console

1. Open your browser and go to: https://console.firebase.google.com/
2. Sign in with your Google account
3. Click **"Add project"** or **"Create a project"**

### Step 2: Configure Project

1. **Project name**: `helix` (or `helix-app`)
2. Click **Continue**
3. **Google Analytics**:
   - Toggle ON (recommended for tracking user behavior)
   - Click **Continue**
4. **Analytics account**:
   - Select "Default Account for Firebase" or create new
   - Click **Create project**
5. Wait for project creation (~30 seconds)
6. Click **Continue** when ready

---

## PART 2: Enable Authentication

### Step 3: Set Up Firebase Authentication

1. In the Firebase Console, click **"Build"** > **"Authentication"**
2. Click **"Get started"**
3. Click on **"Sign-in method"** tab
4. Click on **"Google"** provider:
   - Toggle **Enable**
   - **Project support email**: Select your email
   - Click **Save**

### Step 4: Configure OAuth Consent Screen (for production later)

1. Click on **"Settings"** > **"Project settings"**
2. Scroll to **"Your apps"** section
3. Note your **Project ID** (you'll need this)

---

## PART 3: Set Up Firestore Database

### Step 5: Create Firestore Database

1. In Firebase Console, click **"Build"** > **"Firestore Database"**
2. Click **"Create database"**
3. **Security rules**: Select **"Start in test mode"** (we'll add proper rules later)
4. **Cloud Firestore location**: Choose closest to you:
   - `us-central1` (Iowa) - Good for North America
   - `europe-west1` (Belgium) - Good for Europe
   - `asia-northeast1` (Tokyo) - Good for Asia
5. Click **Enable**
6. Wait for database creation (~1 minute)

### Step 6: Set Up Firestore Security Rules (Basic)

1. In Firestore Database, click **"Rules"** tab
2. Replace the default rules with these secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }

    // Helper function to check if user owns the data
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // Activities subcollection
      match /activities/{activityId} {
        allow read, write: if isOwner(userId);
      }

      // Sessions subcollection
      match /sessions/{sessionId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

3. Click **"Publish"**

---

## PART 4: Enable Firebase Storage (Optional - for future features)

### Step 7: Set Up Storage (for profile pictures later)

1. Click **"Build"** > **"Storage"**
2. Click **"Get started"**
3. Accept security rules (we'll customize later)
4. Choose same location as Firestore
5. Click **Done**

---

## PART 5: Install Firebase CLI on Your Mac

### Step 8: Install Firebase Tools

Open your **Mac Terminal** and run:

```bash
# Install Firebase CLI using npm (Node.js required)
# If you don't have Node.js, install it first:
brew install node

# Then install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login
```

This will:
1. Open your browser for authentication
2. Ask you to log in with Google
3. Grant Firebase CLI access

### Step 9: Install FlutterFire CLI

```bash
# Install FlutterFire CLI (makes Firebase setup super easy)
dart pub global activate flutterfire_cli

# Add to PATH if needed
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

---

## PART 6: Get Configuration Files (We'll Do This Together)

Once your Flutter project is created, we'll run:

```bash
# This will be run AFTER we create the Flutter project
flutterfire configure
```

This command will:
- Detect all platforms (iOS, Android, Web)
- Create platform-specific config files automatically
- Generate `firebase_options.dart`
- Set up all Firebase SDKs

---

## What You'll Need Later

Keep these handy from Firebase Console:

1. **Project ID**: (found in Project Settings)
2. **Web API Key**: (found in Project Settings > General)
3. **iOS Bundle ID**: `com.helix.app` (we'll use this)
4. **Android Package Name**: `com.helix.app` (we'll use this)

---

## Next Steps

After completing these steps:

1. ✅ Firebase project created
2. ✅ Google Authentication enabled
3. ✅ Firestore Database created with security rules
4. ✅ Firebase CLI installed and logged in
5. ✅ FlutterFire CLI installed

**Come back and let me know when you're done!**

Then I'll:
- Create the Flutter project
- Run `flutterfire configure`
- Set up the initial app structure
- Connect everything together

---

## Troubleshooting

**Problem: "npm: command not found"**
```bash
# Install Node.js first
brew install node
```

**Problem: "firebase: command not found" after installing**
```bash
# Check if npm global bin is in PATH
npm config get prefix
# Add to PATH: export PATH="$PATH:/usr/local/bin"
```

**Problem: "dart: command not found" for FlutterFire CLI**
```bash
# Make sure Flutter is installed and in PATH
which flutter
# If Flutter is there, Dart should be available
```

---

## Quick Reference

**Check Firebase CLI:**
```bash
firebase --version
```

**Login to Firebase:**
```bash
firebase login
```

**Check FlutterFire CLI:**
```bash
flutterfire --version
```

**List Firebase projects:**
```bash
firebase projects:list
```
