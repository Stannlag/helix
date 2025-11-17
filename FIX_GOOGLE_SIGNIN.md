# 🔧 Fix Google Sign-In on Web

You're getting this error because Google Sign-In on web requires a Client ID to be configured in your HTML file.

---

## 🚀 Quick Fix (2 minutes)

### **Step 1: Get Your Web Client ID**

1. Go to: **https://console.firebase.google.com/**
2. Click on your **"helix"** project
3. Click the **gear icon (⚙️)** → **Project settings**
4. Scroll down to **"Your apps"** section
5. You should see a **Web app** (with `</>` icon)
6. Look for **"Web client ID"** - it looks like this:
   ```
   123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com
   ```
7. **Copy this entire ID**

---

### **Step 2: Add It to Your App**

**Option A: Use the automated script (easiest)**

```bash
cd /path/to/your/helix

# Run the setup script
./setup_web_client_id.sh

# It will ask you to paste your Client ID
# Paste it and press Enter
```

**Option B: Manual edit**

1. Open: `helix-app/web/index.html`
2. Find this line (around line 35):
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">
   ```
3. Replace `YOUR_WEB_CLIENT_ID` with your actual ID:
   ```html
   <meta name="google-signin-client_id" content="123456789012-abc...apps.googleusercontent.com">
   ```
4. Save the file

---

### **Step 3: Restart Your App**

```bash
cd helix-app

# Stop the current app (Ctrl+C if running)

# Run it again
flutter run -d chrome
```

---

## ✅ **Test It**

1. Click **"Continue with Google"**
2. Select your Google account
3. You should be signed in! 🎉

---

## 🔍 **Where to Find Your Web Client ID**

Here's exactly where to look in Firebase Console:

```
Firebase Console
  └── helix (your project)
      └── ⚙️ Project settings
          └── General tab
              └── Your apps
                  └── Web app (</> icon)
                      └── SDK setup and configuration
                          └── Config
                              └── Look for:
                                  authDomain: "helix-xxxxx.firebaseapp.com"
                                  ↓
                                  And nearby you'll see the Web client ID
```

**OR** in the Config object, look for `apiKey` - the Web Client ID is usually listed right below it.

---

## 📸 **Visual Guide**

The Web Client ID looks like:
```
[NUMBER]-[RANDOM STRING].apps.googleusercontent.com
```

Example:
```
287419038765-8h9ak2jd83hdkaj2h3kd8ajk3h.apps.googleusercontent.com
```

---

## 🐛 **Still Not Working?**

### Error: "Client ID not found"
- Make sure you copied the **Web client ID**, not the API key
- Check there are no extra spaces when pasting

### Error: "Unauthorized"
- Go to Firebase Console → Authentication → Sign-in method
- Make sure Google is **Enabled**
- Add your domain to **Authorized domains** if testing on localhost

### Error: "redirect_uri_mismatch"
- This usually doesn't happen with localhost
- If it does, add `http://localhost` to authorized redirect URIs in Google Cloud Console

---

## 💡 **Pro Tip**

After fixing, you only need to do this once! The Client ID stays in your `index.html` file.

---

## 🎯 **Next Steps**

Once Google Sign-In works:
1. Test signing in and out
2. Let me know it's working
3. I'll build the rest of the app features!

---

## ❓ **Need Help?**

If you're stuck:
1. Share the exact error message
2. Share what you see in Firebase Console
3. I'll help you troubleshoot!
