#!/bin/bash

# Flutter Setup Script for M1 Mac
# Run this script to automatically install Flutter

set -e  # Exit on error

echo "🚀 Starting Flutter Installation for M1 Mac..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check if Flutter is already installed
if command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️  Flutter is already installed!${NC}"
    flutter --version
    echo ""
    read -p "Do you want to reinstall? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
fi

# Step 2: Download Flutter
echo -e "${BLUE}📦 Downloading Flutter SDK for Apple Silicon...${NC}"
cd ~
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.27.1-stable.zip

# Step 3: Unzip
echo -e "${BLUE}📂 Extracting Flutter...${NC}"
unzip -q flutter_macos_arm64_3.27.1-stable.zip

# Step 4: Move to permanent location
echo -e "${BLUE}📁 Moving Flutter to /opt/flutter...${NC}"
sudo mv flutter /opt/flutter 2>/dev/null || {
    echo -e "${YELLOW}⚠️  Cannot write to /opt, installing to ~/flutter instead${NC}"
    mv flutter ~/flutter
    FLUTTER_PATH="$HOME/flutter/bin"
}

# Default path
FLUTTER_PATH="${FLUTTER_PATH:-/opt/flutter/bin}"

# Step 5: Add to PATH
echo -e "${BLUE}🔧 Configuring PATH...${NC}"
SHELL_CONFIG=""
if [ -f ~/.zshrc ]; then
    SHELL_CONFIG=~/.zshrc
elif [ -f ~/.bash_profile ]; then
    SHELL_CONFIG=~/.bash_profile
else
    SHELL_CONFIG=~/.zshrc
    touch ~/.zshrc
fi

# Check if already in PATH
if ! grep -q "flutter/bin" "$SHELL_CONFIG"; then
    echo "" >> "$SHELL_CONFIG"
    echo "# Flutter" >> "$SHELL_CONFIG"
    echo "export PATH=\"\$PATH:$FLUTTER_PATH\"" >> "$SHELL_CONFIG"
    echo -e "${GREEN}✓ Added Flutter to PATH in $SHELL_CONFIG${NC}"
else
    echo -e "${YELLOW}⚠️  Flutter already in PATH${NC}"
fi

# Step 6: Load new PATH
export PATH="$PATH:$FLUTTER_PATH"

# Clean up
rm -f ~/flutter_macos_arm64_3.27.1-stable.zip

# Step 7: Install Xcode Command Line Tools
echo -e "${BLUE}🛠️  Checking Xcode Command Line Tools...${NC}"
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo -e "${YELLOW}⚠️  Please complete the Xcode installation in the popup, then run this script again.${NC}"
    exit 0
else
    echo -e "${GREEN}✓ Xcode Command Line Tools installed${NC}"
fi

# Step 8: Install CocoaPods
echo -e "${BLUE}📦 Installing CocoaPods...${NC}"
if ! command -v pod &> /dev/null; then
    sudo gem install cocoapods
    echo -e "${GREEN}✓ CocoaPods installed${NC}"
else
    echo -e "${GREEN}✓ CocoaPods already installed${NC}"
fi

# Step 9: Run Flutter doctor
echo ""
echo -e "${BLUE}🏥 Running Flutter Doctor...${NC}"
echo ""
flutter doctor -v

echo ""
echo -e "${GREEN}✅ Flutter installation complete!${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Restart your terminal (or run: source $SHELL_CONFIG)"
echo "2. Run: flutter doctor"
echo "3. Install VSCode extensions:"
echo "   code --install-extension Dart-Code.flutter"
echo "   code --install-extension Dart-Code.dart-code"
echo ""
echo -e "${GREEN}🎉 You're ready to build with Flutter!${NC}"
