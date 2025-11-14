#!/bin/bash

# Verify Web Client ID format

echo "🔍 Web Client ID Verification Tool"
echo ""
echo "This tool helps verify your Client ID is correct."
echo ""

read -p "Paste your Web Client ID here: " CLIENT_ID

echo ""
echo "Checking format..."
echo ""

# Check if empty
if [ -z "$CLIENT_ID" ]; then
    echo "❌ No Client ID provided!"
    exit 1
fi

# Check format: should be numbers-string.apps.googleusercontent.com
if [[ $CLIENT_ID =~ ^[0-9]+-[a-zA-Z0-9]+\.apps\.googleusercontent\.com$ ]]; then
    echo "✅ Format looks correct!"
    echo ""
    echo "Your Client ID: $CLIENT_ID"
    echo ""
    echo "Parts breakdown:"
    echo "  Project Number: ${CLIENT_ID%%-*}"
    echo "  Hash: $(echo $CLIENT_ID | cut -d'-' -f2 | cut -d'.' -f1)"
    echo "  Domain: apps.googleusercontent.com"
    echo ""

    # Ask if they want to update index.html
    read -p "Update helix-app/web/index.html with this ID? (y/n): " UPDATE

    if [ "$UPDATE" == "y" ] || [ "$UPDATE" == "Y" ]; then
        sed -i.bak "s/YOUR_WEB_CLIENT_ID/$CLIENT_ID/" helix-app/web/index.html
        echo ""
        echo "✅ Updated helix-app/web/index.html!"
        echo ""
        echo "Next steps:"
        echo "1. cd helix-app"
        echo "2. flutter clean"
        echo "3. flutter run -d chrome"
    fi
else
    echo "❌ This doesn't look like a Web Client ID!"
    echo ""
    echo "You provided: $CLIENT_ID"
    echo ""
    echo "Expected format:"
    echo "  123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com"
    echo ""
    echo "Common mistakes:"
    echo "  ❌ Using API Key (starts with AIzaSy...)"
    echo "  ❌ Using iOS Client ID (different format)"
    echo "  ❌ Using Android Client ID (different format)"
    echo "  ❌ Extra spaces or line breaks"
    echo ""
    echo "Where to find the CORRECT ID:"
    echo "  1. Go to: https://console.cloud.google.com/"
    echo "  2. Select 'helix' project"
    echo "  3. Search for 'Credentials'"
    echo "  4. Look for 'Web client (auto created by Google Service)'"
    echo "  5. Click it and copy the 'Client ID' at the top"
fi

echo ""
