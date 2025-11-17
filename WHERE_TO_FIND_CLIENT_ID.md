# 🔍 Where to Find Web Client ID (VISUAL GUIDE)

The Web Client ID is **NOT in Firebase Console** - it's in **Google Cloud Console**!

---

## 📍 **EXACT LOCATION**

```
Google Cloud Console
https://console.cloud.google.com/

1. Top of page → Click project dropdown
   └── Select "helix" project

2. Search bar at top → Type "credentials"
   └── Click "Credentials" (under APIs & Services)

3. Page shows:
   ┌─────────────────────────────────────────┐
   │ Credentials                             │
   ├─────────────────────────────────────────┤
   │                                         │
   │ OAuth 2.0 Client IDs                    │
   │ ┌─────────────────────────────────────┐ │
   │ │ Name                    │ Type │ ID │ │
   │ ├─────────────────────────────────────┤ │
   │ │ Web client              │ Web  │... │ │ ← CLICK THIS!
   │ │ (auto created by...)    │      │    │ │
   │ ├─────────────────────────────────────┤ │
   │ │ Android client          │Android│...│ │
   │ │ (auto created by...)    │      │    │ │
   │ ├─────────────────────────────────────┤ │
   │ │ iOS client              │ iOS  │... │ │
   │ │ (auto created by...)    │      │    │ │
   │ └─────────────────────────────────────┘ │
   └─────────────────────────────────────────┘

4. Click "Web client (auto created by Google Service)"

5. You'll see:
   ┌─────────────────────────────────────────┐
   │ Edit OAuth client                       │
   ├─────────────────────────────────────────┤
   │                                         │
   │ Client ID:                              │
   │ 123456789012-abc...apps.google...com    │ ← COPY THIS!
   │ [📋 Copy button]                        │
   │                                         │
   │ Client secret:                          │
   │ GOCSPX-...                              │
   │                                         │
   └─────────────────────────────────────────┘
```

---

## ✅ **What You're Looking For**

**Format:**
```
[NUMBER]-[RANDOM].apps.googleusercontent.com
```

**Example:**
```
287419038765-8h9ak2jd83hdkaj2h3kd8ajk3h.apps.googleusercontent.com
```

**Length:** Usually 60-80 characters

**Ends with:** `.apps.googleusercontent.com`

---

## ❌ **What's NOT the Client ID**

These are common mistakes:

1. ❌ **API Key** (starts with `AIzaSy...`)
   - This is in Firebase Console → Project settings
   - We don't need this!

2. ❌ **Client Secret** (starts with `GOCSPX-...`)
   - This is below the Client ID
   - We don't need this either!

3. ❌ **Project ID** (like `helix-abc123`)
   - This is just the Firebase project name
   - Not what we need!

4. ❌ **Auth Domain** (like `helix-abc123.firebaseapp.com`)
   - This is for Firebase config
   - Not the Client ID!

---

## 🚨 **If You Don't See "Web client"**

This means Firebase didn't create a web app yet. Fix it:

### **Create Web App in Firebase:**

1. Go to: https://console.firebase.google.com/
2. Select **"helix"** project
3. Click **gear icon (⚙️)** → **Project settings**
4. Scroll to **"Your apps"** section
5. Look for web apps:

```
Your apps
┌──────────────────────────────────┐
│ iOS app    │ com.helix.helix     │
│ Android app│ com.helix.helix     │
│ Web app    │ ??? NOT HERE ???    │  ← If missing, add it!
└──────────────────────────────────┘
```

6. If no web app, click **"Add app"** → Choose **Web** (`</>` icon)
7. Nickname: `helix-web`
8. Check ✅ **"Also set up Firebase Hosting"** (optional)
9. Click **"Register app"**
10. You'll see config - Click **"Continue to console"**

Now go back to Google Cloud Console and you should see the Web client!

---

## 🎯 **STEP-BY-STEP SCRIPT**

Run this interactive guide:

```bash
cd /path/to/your/helix
./find_web_client_id.sh
```

It will walk you through each step and update your app automatically!

---

## 📸 **Screenshot Checklist**

When you're on the right page in Google Cloud Console, you should see:

- ✅ URL contains: `console.cloud.google.com/apis/credentials`
- ✅ Page title: "Credentials"
- ✅ Section: "OAuth 2.0 Client IDs"
- ✅ Entry: "Web client (auto created by Google Service)"
- ✅ Type column says: "Web"

If you see all of these, you're in the right place!

---

## 🆘 **Still Can't Find It?**

Share with me:
1. What you see in Google Cloud Console → Credentials page
2. Do you see ANY OAuth clients listed?
3. What options do you see when you click on them?

I'll help you locate it! 🚀
