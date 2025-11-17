#!/bin/bash

# Reset Firebase Configuration - Start Fresh

echo "🔄 Resetting Firebase Configuration"
echo ""
echo "This will remove the old Firebase config so you can set up a new project."
echo ""

# Confirm
read -p "Are you sure you want to reset Firebase config? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "🧹 Cleaning old Firebase configuration..."
echo ""

cd helix-app

# Backup current config
echo "Creating backup of current config..."
mkdir -p ../firebase-backup
cp lib/firebase_options.dart ../firebase-backup/ 2>/dev/null || true
cp android/app/google-services.json ../firebase-backup/ 2>/dev/null || true
cp ios/Runner/GoogleService-Info.plist ../firebase-backup/ 2>/dev/null || true
cp web/index.html ../firebase-backup/ 2>/dev/null || true

echo "✅ Backed up to ../firebase-backup/"
echo ""

# Remove old Firebase config files
echo "Removing old Firebase configuration files..."

# Remove firebase_options.dart
if [ -f "lib/firebase_options.dart" ]; then
    rm lib/firebase_options.dart
    echo "  ✓ Removed lib/firebase_options.dart"
fi

# Remove Android google-services.json
if [ -f "android/app/google-services.json" ]; then
    rm android/app/google-services.json
    echo "  ✓ Removed android/app/google-services.json"
fi

# Remove iOS GoogleService-Info.plist
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    rm ios/Runner/GoogleService-Info.plist
    echo "  ✓ Removed ios/Runner/GoogleService-Info.plist"
fi

# Reset web client ID
if [ -f "web/index.html" ]; then
    sed -i.bak 's/content="[^"]*" \/> <!-- Google/content="YOUR_WEB_CLIENT_ID"> <!-- Google/' web/index.html
    sed -i.bak 's/<meta name="google-signin-client_id" content="[^"]*">/<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">/' web/index.html
    echo "  ✓ Reset web/index.html client ID"
fi

# Clean build
echo ""
echo "🧼 Cleaning Flutter build..."
flutter clean
echo ""

echo "✅ Firebase configuration reset complete!"
echo ""
echo "========================================="
echo "NEXT STEPS - Create New Firebase Project"
echo "========================================="
echo ""
echo "1️⃣  Go to: https://console.firebase.google.com/"
echo ""
echo "2️⃣  Create a NEW project:"
echo "   - Click 'Create a project' or 'Add project'"
echo "   - Name: helix (or helix2, helix-new, etc.)"
echo "   - Enable/disable Google Analytics (your choice)"
echo "   - Click 'Create project'"
echo ""
echo "3️⃣  Enable Authentication:"
echo "   - Click 'Build' → 'Authentication'"
echo "   - Click 'Get started'"
echo "   - Click 'Sign-in method' tab"
echo "   - Click 'Google' → Toggle Enable"
echo "   - Select your email"
echo "   - Click 'Save'"
echo ""
echo "4️⃣  Create Firestore Database:"
echo "   - Click 'Build' → 'Firestore Database'"
echo "   - Click 'Create database'"
echo "   - Select 'Start in test mode'"
echo "   - Choose location (us-central1 or closest to you)"
echo "   - Click 'Enable'"
echo ""
echo "5️⃣  Configure Flutter app:"
echo "   - Make sure you're logged into Firebase CLI:"
echo "     firebase login"
echo ""
echo "   - Run FlutterFire configure:"
echo "     flutterfire configure"
echo ""
echo "   - Select your NEW project from the list"
echo "   - Select platforms: iOS, Android, Web (press Space to select)"
echo "   - Press Enter to confirm"
echo ""
echo "6️⃣  Get dependencies:"
echo "   flutter pub get"
echo ""
echo "7️⃣  Run the app:"
echo "   flutter run -d chrome"
echo "   (OR choose your preferred device)"
echo ""
echo "========================================="
echo "📋 IMPORTANT NOTES"
echo "========================================="
echo ""
echo "- Old config backed up to: ../firebase-backup/"
echo "- Use a NEW email if you want completely fresh account"
echo "- For web: You'll need to add Web Client ID later (same process)"
echo "- For mobile: Should work immediately!"
echo ""
echo "🎉 Ready to start fresh!"
echo ""

cd ..
