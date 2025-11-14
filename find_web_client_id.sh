#!/bin/bash

# Step-by-step guide to find Web Client ID

echo "🔍 Finding Your Web Client ID - Step by Step"
echo ""
echo "The Web Client ID is in Google Cloud Console, not Firebase!"
echo ""
echo "========================================="
echo "FOLLOW THESE EXACT STEPS:"
echo "========================================="
echo ""

echo "1️⃣  Go to: https://console.cloud.google.com/"
echo ""
read -p "   Press Enter when you're there..."
echo ""

echo "2️⃣  At the top of the page, click the project dropdown"
echo "   (It might say 'Select a project' or show a project name)"
echo ""
read -p "   Press Enter to continue..."
echo ""

echo "3️⃣  Select your 'helix' project from the list"
echo "   (Look for the same project you created in Firebase)"
echo ""
read -p "   Press Enter when you've selected it..."
echo ""

echo "4️⃣  In the top search bar, type: credentials"
echo "   Then click on 'Credentials' under 'APIs & Services'"
echo ""
read -p "   Press Enter when you're there..."
echo ""

echo "5️⃣  Look for a section called 'OAuth 2.0 Client IDs'"
echo "   You should see a table with entries like:"
echo "   - Web client (auto created by Google Service)"
echo "   - Android client (auto created by Google Service)"
echo "   - iOS client (auto created by Google Service)"
echo ""
read -p "   Press Enter to continue..."
echo ""

echo "6️⃣  Click on 'Web client (auto created by Google Service)'"
echo "   (The one that says 'Web', not Android or iOS)"
echo ""
read -p "   Press Enter when you've clicked it..."
echo ""

echo "7️⃣  You should now see:"
echo "   - Client ID: (a long string ending in .apps.googleusercontent.com)"
echo "   - Client secret: (another string)"
echo ""
echo "   Copy the ENTIRE 'Client ID' - it looks like:"
echo "   123456789012-abcdefg12345.apps.googleusercontent.com"
echo ""
read -p "   Paste your Web Client ID here: " CLIENT_ID
echo ""

if [ -z "$CLIENT_ID" ]; then
    echo "❌ No Client ID provided!"
    echo ""
    echo "If you don't see 'Web client', it means:"
    echo "  1. Firebase didn't create a web app yet"
    echo "  2. You need to add a web app to your Firebase project"
    echo ""
    echo "To fix this:"
    echo "  1. Go to: https://console.firebase.google.com/"
    echo "  2. Select 'helix' project"
    echo "  3. Click gear icon → Project settings"
    echo "  4. Scroll to 'Your apps' section"
    echo "  5. Click 'Add app' → Choose Web (</> icon)"
    echo "  6. Register the app"
    echo "  7. Then come back here and run this script again"
    exit 1
fi

# Verify format
if [[ $CLIENT_ID =~ ^[0-9]+-[a-zA-Z0-9]+\.apps\.googleusercontent\.com$ ]]; then
    echo "✅ Great! That looks like a valid Web Client ID!"
    echo ""
    echo "Your Client ID: $CLIENT_ID"
    echo ""

    # Update index.html
    if [ -f "helix-app/web/index.html" ]; then
        cp helix-app/web/index.html helix-app/web/index.html.bak
        sed -i.tmp "s/YOUR_WEB_CLIENT_ID/${CLIENT_ID}/" helix-app/web/index.html
        rm -f helix-app/web/index.html.tmp
        echo "✅ Updated helix-app/web/index.html!"
        echo ""
        echo "Now run:"
        echo "  cd helix-app"
        echo "  flutter clean"
        echo "  flutter run -d chrome"
    else
        echo "❌ Can't find helix-app/web/index.html"
        echo "Make sure you run this from the helix directory"
    fi
else
    echo "⚠️  This doesn't look like a Web Client ID"
    echo "It should end with: .apps.googleusercontent.com"
    echo ""
    echo "What you provided: $CLIENT_ID"
    echo ""
    echo "Make sure you copied the 'Client ID', not the 'Client secret'"
fi

echo ""
