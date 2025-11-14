#!/bin/bash

# Install Flutter dependencies and set up project structure

set -e

echo "🚀 Setting up Helix dependencies..."
echo ""

cd helix-app

# Install dependencies
echo "📦 Installing Flutter packages..."
flutter pub get

echo ""
echo "✅ Dependencies installed successfully!"
echo ""

# List installed packages
echo "📋 Installed packages:"
flutter pub deps --style=compact | head -30

echo ""
echo "🎉 Ready to build Helix!"
echo ""
echo "Next: I'll create the app structure and features"
