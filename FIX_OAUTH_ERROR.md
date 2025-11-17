# 🔴 Fix OAuth Error 401: invalid_client

This error means the Web Client ID isn't properly configured. Let's fix it step by step.

---

## 🔍 **Root Cause**

The issue is usually one of these:
1. ❌ Used wrong Client ID (iOS/Android instead of Web)
2. ❌ Web Client ID doesn't exist yet
3. ❌ OAuth consent screen not configured

---

## ✅ **SOLUTION: Create/Get Correct Web Client ID**

### **Step 1: Verify Your Firebase Web App Config**

1. Go to: **https://console.firebase.google.com/**
2. Select **"helix"** project
3. Click **gear icon (⚙️)** → **Project settings**
4. Scroll to **"Your apps"** section
5. Look for the **Web app** (has `</>` icon with "helix" name)

**If you DON'T see a Web app:**
- Click **"Add app"** → Choose **Web** (`</>` icon)
- Nickname: `helix-web`
- ✅ Check **"Also set up Firebase Hosting"** (optional)
- Click **Register app**
- You'll see a config with `apiKey`, `authDomain`, etc.
- Click **Continue to console**

---

### **Step 2: Get the CORRECT Web Client ID**

**There are TWO places to find it. Use Option A first:**

#### **Option A: From Firebase Console (Easiest)**

1. Still in **Project settings** → **General** tab
2. Scroll to **"Your apps"** → Find your **Web app**
3. Under "SDK setup and configuration" → Click **"Config"**
4. You'll see something like:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "helix-xxxxx.firebaseapp.com",
  projectId: "helix-xxxxx",
  // ... other config
};
```

5. **IMPORTANT**: The Web Client ID is NOT in this config!
6. Scroll down on the same page
7. Look for a section that says **"Web client ID"** explicitly
8. Copy the entire ID (format: `123456789-abc...apps.googleusercontent.com`)

#### **Option B: From Google Cloud Console (If not in Firebase)**

1. Go to: **https://console.cloud.google.com/**
2. Select your **"helix"** project (same name as Firebase)
3. In the search bar, type: **"Credentials"**
4. Click **"APIs & Services"** → **"Credentials"**
5. Look for **"OAuth 2.0 Client IDs"** section
6. You should see clients like:
   - ✅ **"Web client (auto created by Google Service)"** ← THIS ONE!
   - "iOS client..."
   - "Android client..."
7. Click on the **Web client**
8. Copy the **"Client ID"** at the top

---

### **Step 3: Update Your App**

1. Open: `helix-app/web/index.html`
2. Find line 35:
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">
   ```
3. Replace with the Client ID you just copied:
   ```html
   <meta name="google-signin-client_id" content="287419038765-8h9ak2jd83hdkaj2h3kd8ajk3h.apps.googleusercontent.com">
   ```
4. **Double-check there are NO spaces or line breaks!**
5. Save the file

---

### **Step 4: Configure OAuth Consent Screen**

1. In **Google Cloud Console** (https://console.cloud.google.com/)
2. Select your **"helix"** project
3. Search for: **"OAuth consent screen"**
4. Click **"OAuth consent screen"**

**If you see "Configure Consent Screen":**
1. Choose **"External"** (for testing with your account)
2. Click **Create**
3. Fill in:
   - **App name**: Helix
   - **User support email**: Your email
   - **Developer contact**: Your email
4. Click **Save and Continue**
5. **Scopes**: Click **Save and Continue** (skip for now)
6. **Test users**:
   - Click **"Add Users"**
   - Add your Google email
   - Click **Save and Continue**
7. Click **"Back to Dashboard"**

---

### **Step 5: Add Authorized Domain**

1. Still in **Google Cloud Console** → **Credentials**
2. Click on your **Web client** (auto created by Google Service)
3. Under **"Authorized JavaScript origins"**:
   - Click **"Add URI"**
   - Add: `http://localhost` (for local testing)
   - Add: `http://localhost:XXXX` (replace XXXX with your port if different)
4. Under **"Authorized redirect URIs"**:
   - Should already have `http://localhost`
   - If not, add it
5. Click **Save**

---

### **Step 6: Restart Your App**

```bash
cd helix-app

# IMPORTANT: Clear the build and restart
flutter clean
flutter pub get

# Run again
flutter run -d chrome
```

---

## 🔍 **Verify Your Client ID Format**

The Web Client ID should look like this:
```
[12-digit-number]-[32-char-string].apps.googleusercontent.com
```

Example:
```
287419038765-8h9ak2jd83hdkaj2h3kd8ajk3h.apps.googleusercontent.com
```

**❌ NOT like this:**
- `AIzaSy...` ← This is API Key, not Client ID
- `1234567890` ← Just numbers
- `com.helix.helix` ← This is bundle ID

---

## 🧪 **Quick Test Checklist**

Before trying again, verify:

- [ ] You copied the **Web client** ID (not iOS or Android)
- [ ] Client ID ends with `.apps.googleusercontent.com`
- [ ] OAuth consent screen is configured
- [ ] Your email is added as a test user
- [ ] `http://localhost` is in authorized origins
- [ ] Ran `flutter clean` before restarting

---

## 🐛 **Still Not Working?**

### **Option: Use FirebaseUI Instead (Easier)**

If OAuth setup is too complex, we can switch to FirebaseUI which handles this automatically. Let me know if you want to try that approach.

---

## 📸 **Visual Guide: Where to Find Web Client ID**

```
Google Cloud Console
└── helix (project)
    └── APIs & Services
        └── Credentials
            └── OAuth 2.0 Client IDs
                └── "Web client (auto created by Google Service)"
                    └── Client ID: 123456789-abc...apps.googleusercontent.com
                        ↑ COPY THIS!
```

---

## 💡 **Pro Tip**

If you're testing locally, you might see warnings about "This app isn't verified." That's normal! Just click **"Advanced"** → **"Go to Helix (unsafe)"** to continue. This only happens in development.

---

## ❓ **Need Help?**

Share:
1. What you see in Firebase Console under "Your apps"
2. What Client ID you're using (first 10 characters only)
3. Any error messages

I'll help you troubleshoot! 🚀
