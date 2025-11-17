#!/bin/bash

# Interactive tool to find Web Client ID

echo "🔍 Finding Your Web Client ID"
echo ""
echo "The Web Client ID is in Google Cloud Console, not Firebase!"
echo "Let me guide you there..."
echo ""

# Step 1
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Open Google Cloud Console"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Click this link or copy-paste in browser:"
echo "https://console.cloud.google.com/apis/credentials"
echo ""
read -p "Press Enter when you've opened it..."
echo ""

# Step 2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Select Your Project"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "At the TOP of the page, you'll see a project dropdown."
echo "Click it and select your Firebase project (helix or similar)."
echo ""
read -p "Press Enter when you've selected your project..."
echo ""

# Step 3
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: What Do You See?"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Look for a section called 'OAuth 2.0 Client IDs'"
echo ""
echo "What do you see in that section?"
echo ""
echo "A) I see 'Web client (auto created by Google Service)'"
echo "B) I see Android and iOS clients, but NO Web client"
echo "C) I don't see any OAuth clients at all"
echo "D) I see an empty table/no entries"
echo ""
read -p "Enter A, B, C, or D: " ANSWER
echo ""

case $ANSWER in
    A|a)
        echo "✅ GREAT! You found it!"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "STEP 4: Get the Client ID"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "1. Click on 'Web client (auto created by Google Service)'"
        echo "2. You'll see a page with 'Client ID' at the top"
        echo "3. It looks like: 123456789-abcdefg...apps.googleusercontent.com"
        echo "4. Click the COPY button next to it (or select and copy)"
        echo ""
        read -p "Paste your Client ID here: " CLIENT_ID
        echo ""

        if [ -z "$CLIENT_ID" ]; then
            echo "❌ No Client ID entered!"
            exit 1
        fi

        # Verify format
        if [[ $CLIENT_ID =~ ^[0-9]+-[a-zA-Z0-9]+\.apps\.googleusercontent\.com$ ]]; then
            echo "✅ Perfect! That's a valid Web Client ID!"
            echo ""
            echo "Updating helix-app/web/index.html..."

            cd helix-app
            sed -i.bak "s/YOUR_WEB_CLIENT_ID/${CLIENT_ID}/" web/index.html

            echo "✅ Updated!"
            echo ""
            echo "Now run:"
            echo "  cd helix-app"
            echo "  flutter run -d chrome"
        else
            echo "⚠️  That doesn't look like a Web Client ID."
            echo "It should end with: .apps.googleusercontent.com"
            echo ""
            echo "Make sure you copied the 'Client ID', not 'Client secret'"
        fi
        ;;

    B|b)
        echo "📝 You need to create a Web app in Firebase first!"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "CREATE WEB APP IN FIREBASE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "1. Go to: https://console.firebase.google.com/"
        echo "2. Select your project"
        echo "3. Click gear icon (⚙️) → Project settings"
        echo "4. Scroll to 'Your apps' section"
        echo "5. Click 'Add app' → Choose Web (</> icon)"
        echo "6. App nickname: helix-web"
        echo "7. Check 'Also set up Firebase Hosting' (optional)"
        echo "8. Click 'Register app'"
        echo "9. Click 'Continue to console'"
        echo ""
        echo "Then run this script again!"
        ;;

    C|c)
        echo "🔧 You need to enable Google Sign-In in Firebase!"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "ENABLE GOOGLE AUTHENTICATION"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "1. Go to: https://console.firebase.google.com/"
        echo "2. Select your project"
        echo "3. Click 'Build' → 'Authentication'"
        echo "4. Click 'Get started'"
        echo "5. Click 'Sign-in method' tab"
        echo "6. Click 'Google'"
        echo "7. Toggle 'Enable'"
        echo "8. Select support email"
        echo "9. Click 'Save'"
        echo ""
        echo "This will auto-create the OAuth clients!"
        echo "Then run this script again!"
        ;;

    D|d)
        echo "🆕 Looks like a new project! Let's set it up..."
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "SETUP CHECKLIST"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "1. Go to: https://console.firebase.google.com/"
        echo "2. Select your project (or create new one)"
        echo ""
        echo "3. Enable Google Authentication:"
        echo "   - Build → Authentication → Get started"
        echo "   - Sign-in method → Google → Enable"
        echo ""
        echo "4. Add a Web app:"
        echo "   - Settings → Your apps → Add app → Web"
        echo "   - Register the app"
        echo ""
        echo "5. Then come back and run this script again!"
        ;;

    *)
        echo "❌ Invalid option. Please run the script again."
        ;;
esac

echo ""
