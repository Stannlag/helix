#!/bin/bash

# Flutter Project Setup Script
# Run this on your Mac to create the Helix Flutter project

set -e

echo "🚀 Creating Helix Flutter Project..."
echo ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found!"
    echo "Please run ./setup_flutter.sh first or add Flutter to your PATH"
    echo "Run: source ~/.zshrc"
    exit 1
fi

echo "✓ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Navigate to the helix directory
cd "$(dirname "$0")"

# Remove the empty helix-app directory if it exists
if [ -d "helix-app" ]; then
    echo "Removing placeholder helix-app directory..."
    rm -rf helix-app
fi

# Create Flutter project
echo "📦 Creating Flutter project..."
flutter create \
  --org com.helix \
  --project-name helix \
  --platforms ios,android,web \
  --description "Transform scattered efforts into structured growth with a DNA-inspired time tracker" \
  helix-app

cd helix-app

echo ""
echo "✓ Flutter project created"
echo ""

# Check if Firebase CLI is available
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI not found!"
    echo "Please install it with: npm install -g firebase-tools"
    echo "Then run: firebase login"
    exit 1
fi

# Check if FlutterFire CLI is available
if ! command -v flutterfire &> /dev/null; then
    echo "⚠️  FlutterFire CLI not found!"
    echo "Please install it with: dart pub global activate flutterfire_cli"
    echo "Then add to PATH: export PATH=\"\$PATH\":\"\$HOME/.pub-cache/bin\""
    exit 1
fi

echo "🔥 Configuring Firebase..."
echo ""
echo "This will:"
echo "  1. Connect to your Firebase project"
echo "  2. Configure iOS, Android, and Web"
echo "  3. Generate firebase_options.dart"
echo ""
read -p "Press Enter to continue..."

# Configure Firebase
flutterfire configure

echo ""
echo "✅ Firebase configured!"
echo ""

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "✨ Project setup complete!"
echo ""
echo "Next steps:"
echo "  1. cd helix-app"
echo "  2. flutter run (to test on a device/simulator)"
echo "  3. Tell me you're ready and I'll add the custom code!"
echo ""
