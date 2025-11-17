#!/bin/bash

# Configure Flutter to use alternative Chromium browsers
# Run this to set up Brave, Arc, or other browsers for Flutter web development

echo "🌐 Configuring Flutter for Alternative Browsers"
echo ""

# Detect available browsers
BRAVE_PATH="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
ARC_PATH="/Applications/Arc.app/Contents/MacOS/Arc"
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

echo "Detecting installed browsers..."
echo ""

if [ -f "$CHROME_PATH" ]; then
    echo "✓ Chrome found"
fi

if [ -f "$BRAVE_PATH" ]; then
    echo "✓ Brave found"
fi

if [ -f "$ARC_PATH" ]; then
    echo "✓ Arc found"
fi

echo ""
echo "Choose your default browser for Flutter web development:"
echo "1) Brave Browser"
echo "2) Arc Browser"
echo "3) Google Chrome"
echo "4) Use iOS Simulator instead (recommended for Mac)"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        if [ ! -f "$BRAVE_PATH" ]; then
            echo "❌ Brave not found at expected location"
            exit 1
        fi
        echo "export CHROME_EXECUTABLE=\"$BRAVE_PATH\"" >> ~/.zshrc
        export CHROME_EXECUTABLE="$BRAVE_PATH"
        echo "✅ Configured Flutter to use Brave"
        echo "Run: source ~/.zshrc"
        ;;
    2)
        if [ ! -f "$ARC_PATH" ]; then
            echo "❌ Arc not found at expected location"
            exit 1
        fi
        echo "export CHROME_EXECUTABLE=\"$ARC_PATH\"" >> ~/.zshrc
        export CHROME_EXECUTABLE="$ARC_PATH"
        echo "✅ Configured Flutter to use Arc"
        echo "Run: source ~/.zshrc"
        ;;
    3)
        if [ ! -f "$CHROME_PATH" ]; then
            echo "❌ Chrome not found"
            echo "Install from: https://www.google.com/chrome/"
            exit 1
        fi
        echo "✅ Chrome is Flutter's default"
        ;;
    4)
        echo "✅ iOS Simulator is the recommended option for Mac!"
        echo ""
        echo "To use iOS Simulator:"
        echo "  1. Open Simulator: open -a Simulator"
        echo "  2. Run Flutter: flutter run"
        echo ""
        echo "No browser configuration needed!"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎯 Testing configuration..."
flutter devices

echo ""
echo "✨ Done! You can now run:"
echo "  cd helix-app"
echo "  flutter run"
