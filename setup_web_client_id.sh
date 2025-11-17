#!/bin/bash

# Get your Firebase Web Client ID and configure Google Sign-In for Web

echo "🔑 Firebase Web Client ID Setup Guide"
echo ""
echo "To make Google Sign-In work on web, you need to add your Web Client ID."
echo ""
echo "========================================="
echo "STEP 1: Get Your Web Client ID"
echo "========================================="
echo ""
echo "1. Go to: https://console.firebase.google.com/"
echo "2. Select your 'helix' project"
echo "3. Click the gear icon (⚙️) > Project settings"
echo "4. Scroll down to 'Your apps' section"
echo "5. Find the Web app (</> icon) - should be 'helix'"
echo "6. Look for 'Web client ID' - it looks like:"
echo "   123456789-abcdefghijklmnop.apps.googleusercontent.com"
echo "7. Copy this ID"
echo ""
echo "========================================="
echo "STEP 2: Add It to web/index.html"
echo "========================================="
echo ""
echo "Open: helix-app/web/index.html"
echo ""
echo "Find this line:"
echo '  <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">'
echo ""
echo "Replace YOUR_WEB_CLIENT_ID with your actual ID:"
echo '  <meta name="google-signin-client_id" content="123456789-abc...apps.googleusercontent.com">'
echo ""
echo "========================================="
echo "STEP 3: Restart Your App"
echo "========================================="
echo ""
echo "1. Stop the running app (Ctrl+C in terminal)"
echo "2. Run: flutter run -d chrome"
echo "3. Try Google Sign-In again!"
echo ""
echo "========================================="
echo "Quick Copy-Paste Template"
echo "========================================="
echo ""
read -p "Paste your Web Client ID here: " CLIENT_ID
echo ""

if [ -z "$CLIENT_ID" ]; then
    echo "❌ No Client ID provided. Please run this script again."
    exit 1
fi

# Update index.html
sed -i.bak "s/YOUR_WEB_CLIENT_ID/$CLIENT_ID/" helix-app/web/index.html

echo "✅ Updated helix-app/web/index.html"
echo ""
echo "🎉 All set! Now run:"
echo "   cd helix-app"
echo "   flutter run -d chrome"
echo ""
