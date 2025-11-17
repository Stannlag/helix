# 🚀 Helix - Quick Start Guide

## Your Journey to Building Helix

Follow these steps in order:

---

## ✅ STEP 1: Install Flutter (Do This First!)

**On your Mac Terminal:**

```bash
cd /path/to/helix
./setup_flutter.sh
```

**Then verify:**
```bash
flutter --version
flutter doctor
```

**Install VSCode extensions:**
```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

📖 **Detailed guide**: `FLUTTER_SETUP.md`

---

## ✅ STEP 2: Set Up Firebase

**Open browser and follow these steps:**

1. Go to https://console.firebase.google.com/
2. Create new project: `helix`
3. Enable Google Authentication
4. Create Firestore Database (test mode)
5. Set up security rules

**Then on your Mac Terminal:**

```bash
# Install Firebase CLI
npm install -g firebase-tools
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

📖 **Detailed guide**: `FIREBASE_SETUP.md`

---

## ✅ STEP 3: Let Me Create Your Flutter Project

**Once Steps 1 & 2 are done, tell me!**

I will:
1. Create Flutter project structure
2. Configure Firebase for all platforms
3. Set up Material 3 theme
4. Create initial app shell
5. Implement Google Sign-In

---

## ✅ STEP 4: Start Building Features

We'll build in this order:
1. **Authentication** - Google Sign-In
2. **Activities** - Create and manage activities
3. **Sessions** - Log time with emoji ratings
4. **Calendar** - Color-coded Helix calendar
5. **Dashboard** - Analytics and insights

---

## Current Status

- [x] Old project archived
- [ ] Flutter installed
- [ ] Firebase set up
- [ ] Flutter project created
- [ ] First build running

---

## Helpful Commands

**Check Flutter:**
```bash
flutter doctor
flutter devices
```

**Check Firebase:**
```bash
firebase --version
firebase projects:list
```

**Run Flutter app:**
```bash
cd helix-app
flutter run
```

**Hot reload** (while app is running):
```
Press 'r' to hot reload
Press 'R' to hot restart
Press 'q' to quit
```

---

## File Structure (Once Created)

```
helix/
├── helix-archive/          # Old Angular/.NET app
├── helix-app/              # New Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── activities/
│   │   │   ├── sessions/
│   │   │   ├── calendar/
│   │   │   └── dashboard/
│   │   └── core/
│   │       ├── theme/
│   │       └── services/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── pubspec.yaml
├── Documentation/
├── Design/
└── Setup guides (this file, etc.)
```

---

## Need Help?

- **Flutter issues**: Run `flutter doctor -v`
- **Firebase issues**: Check Firebase Console
- **Build errors**: Share the error message
- **Questions**: Just ask!

---

## Let's Go! 🎉

Start with **STEP 1** above and let me know when you're ready for the next step!
