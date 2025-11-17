#!/bin/bash

# Fix CocoaPods Installation for M1 Mac
# Installs CocoaPods via Homebrew instead of gem

set -e

echo "🔧 Fixing CocoaPods installation..."
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew first..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for M1 Macs
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✓ Homebrew already installed"
fi

echo ""
echo "📦 Installing CocoaPods via Homebrew..."
brew install cocoapods

echo ""
echo "✅ CocoaPods installation fixed!"
echo ""

# Verify installation
echo "Verifying CocoaPods installation:"
pod --version

echo ""
echo "🎉 All done! CocoaPods is ready to use."
