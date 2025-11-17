#!/bin/bash

# Switch Flutter browser configuration
# Changes between Brave, Arc, and Chrome

echo "🔄 Switching Flutter Browser Configuration"
echo ""

BRAVE_PATH="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
ARC_PATH="/Applications/Arc.app/Contents/MacOS/Arc"
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Remove existing CHROME_EXECUTABLE line from .zshrc
echo "Removing old configuration..."
sed -i.bak '/CHROME_EXECUTABLE/d' ~/.zshrc

echo ""
echo "Which browser do you want to use?"
echo "1) Brave Browser"
echo "2) Arc Browser"
echo "3) Google Chrome"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        if [ ! -f "$BRAVE_PATH" ]; then
            echo "❌ Brave not found at: $BRAVE_PATH"
            exit 1
        fi
        echo "export CHROME_EXECUTABLE=\"$BRAVE_PATH\"" >> ~/.zshrc
        export CHROME_EXECUTABLE="$BRAVE_PATH"
        echo "✅ Switched to Brave Browser"
        ;;
    2)
        if [ ! -f "$ARC_PATH" ]; then
            echo "❌ Arc not found at: $ARC_PATH"
            exit 1
        fi
        echo "export CHROME_EXECUTABLE=\"$ARC_PATH\"" >> ~/.zshrc
        export CHROME_EXECUTABLE="$ARC_PATH"
        echo "✅ Switched to Arc Browser"
        ;;
    3)
        if [ ! -f "$CHROME_PATH" ]; then
            echo "❌ Chrome not found"
            exit 1
        fi
        echo "export CHROME_EXECUTABLE=\"$CHROME_PATH\"" >> ~/.zshrc
        export CHROME_EXECUTABLE="$CHROME_PATH"
        echo "✅ Switched to Google Chrome"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🔧 Reload your shell configuration:"
echo "  source ~/.zshrc"
echo ""
echo "✨ Done! Flutter will now use your selected browser."
