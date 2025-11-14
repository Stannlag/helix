# Helix - AI Context Guide

**Project Type:** Cross-platform Time Tracking Mobile App (Flutter + Firebase)

---

## 🎯 Core Vision

Transform scattered efforts into structured growth with a **DNA-inspired time tracker**. Users visualize their time investment through color-coded calendar views and emoji-driven insights.

**Key Metaphor:**
- 🧬 **Helix**: Symbolizes incremental, interconnected progress
- 🎨 **Proportional Color Blocks**: Time allocation visualized as colored segments
  - Example: 2hrs Guitar (66.7% green) + 1hr Coding (33.3% blue) = visual time DNA

---

## 📱 Current Technology Stack

### Frontend
- **Flutter 3.27.1** - Cross-platform framework
- **Dart** - Programming language
- **Material Design 3** - UI design system
- **Google Fonts (Inter)** - Typography

### State Management
- **Riverpod 2.6.1** - State management solution
- **StreamProvider** - Real-time data streams from Firebase

### Backend & Services
- **Firebase Authentication** - Google OAuth sign-in
- **Cloud Firestore** - NoSQL database
- **Firebase Cloud Functions** - Serverless backend (future)
- **Firebase Hosting** - Web deployment (future)

### Key Dependencies
```yaml
firebase_core: ^3.8.1
firebase_auth: ^5.3.4
cloud_firestore: ^5.6.0
google_sign_in: ^6.2.2
flutter_riverpod: ^2.6.1
google_fonts: ^6.2.1
table_calendar: ^3.1.2  # Calendar widget
fl_chart: ^0.70.2       # Analytics charts
uuid: ^4.5.1            # ID generation
```

### Platform Support
- ✅ **iOS** (iPhone, iPad)
- ✅ **Android** (Phones, Tablets - minimum API 28/Android 9.0)
- ✅ **Web** (Chrome, Brave, Arc browsers)

---

## 🏗️ Architecture

### Clean Architecture Pattern
```
lib/
├── core/                       # Shared utilities
│   ├── theme/                  # Material 3 theme
│   │   ├── app_colors.dart    # DNA-inspired color palette
│   │   └── app_theme.dart     # Complete Material 3 theme
│   ├── constants/
│   │   └── emoji_ratings.dart # 😞 😐 😊 🤩
│   └── utils/
│       └── date_helpers.dart  # Date formatting utilities
│
├── shared/
│   └── models/
│       └── user_model.dart    # Firebase user document
│
├── features/                   # Feature-based organization
│   ├── auth/
│   │   ├── models/
│   │   ├── services/
│   │   │   └── auth_service.dart       # Google Sign-In + Riverpod
│   │   └── screens/
│   │       └── login_screen.dart       # Material 3 login UI
│   │
│   ├── activities/
│   │   ├── models/
│   │   │   └── activity_model.dart     # Name, color, goal
│   │   ├── services/
│   │   │   └── activity_service.dart   # CRUD + Riverpod
│   │   ├── screens/
│   │   │   ├── activities_screen.dart  # List all activities
│   │   │   └── activity_form_screen.dart # Create/edit with color picker
│   │   └── widgets/
│   │       └── activity_card.dart      # Display activity
│   │
│   ├── sessions/
│   │   ├── models/
│   │   │   └── session_model.dart      # Duration, emoji, notes
│   │   ├── services/
│   │   │   └── session_service.dart    # CRUD + Riverpod
│   │   ├── screens/
│   │   │   ├── sessions_screen.dart    # List with date filter
│   │   │   └── session_form_screen.dart # Log with emoji picker
│   │   └── widgets/
│   │       └── session_card.dart       # Display session
│   │
│   ├── calendar/
│   │   └── screens/
│   │       └── calendar_screen.dart    # ⭐ MAIN SCREEN (Week/Month)
│   │
│   ├── dashboard/
│   │   └── screens/
│   │       └── dashboard_screen.dart   # Analytics & insights
│   │
│   └── home/
│       └── screens/
│           └── home_screen.dart        # Bottom nav container
│
└── main.dart                           # App entry point
```

---

## 🎨 Design System

### DNA-Inspired Color Palette
```dart
primary:   #4CAF50  // Growth green
secondary: #2196F3  // Progress blue
tertiary:  #9C27B0  // Creative purple

// 10 Activity Colors
activityColors: [
  #4CAF50, #2196F3, #F44336, #9C27B0, #FF9800,
  #00BCD4, #8BC34A, #E91E63, #FFC107, #795548
]

// Emoji Rating Colors
sad:     #F44336 (😞)
neutral: #FF9800 (😐)
happy:   #8BC34A (😊)
amazing: #4CAF50 (🤩)
```

### Typography
- **Font Family:** Inter (Google Fonts)
- **Material 3 Text Styles:** All variants defined in `app_theme.dart`

---

## 🚀 Key Features

### 1. Calendar View (MAIN SCREEN)
**Location:** `lib/features/calendar/screens/calendar_screen.dart`

#### Week View
- 7 vertical columns (one per day)
- **Height:** 250px (phones) | 50% screen (tablets/desktop)
- **Colored blocks** stacked proportionally based on time spent
- **Calculation:** `block_height = (activity_duration / total_day_duration) × 100%`
- Example: 2hrs Guitar + 1hr Coding = 66.7% green + 33.3% blue
- Navigation arrows to scroll through weeks
- Tap day to select and view sessions

#### Month View
- Traditional calendar grid
- Small colored rectangles in each cell
- Same proportional height logic
- Dynamic grid height based on weeks in month

#### Bottom Section
- Shows **"Today's Sessions"** or **"[Day]'s Sessions"**
- Lists sessions for selected day
- Total time badge
- Tap session to edit
- Empty state when no sessions

**Design Goal:** Visual time tracking that immediately shows time distribution through color DNA

---

### 2. Activity Management
**Location:** `lib/features/activities/`

- Create activities with name, color, and optional goal
- 10 pre-defined DNA-inspired colors
- Live preview card
- Form validation
- Delete with confirmation
- Stored in Firestore: `users/{userId}/activities/{activityId}`

---

### 3. Session Logging
**Location:** `lib/features/sessions/`

- Manual time entry (hours + minutes)
- Activity selection dropdown
- Date picker (defaults to today)
- **Emoji ratings:** 😞 😐 😊 🤩
- Optional notes field
- Live preview card
- Edit/delete existing sessions
- Stored in Firestore: `users/{userId}/sessions/{sessionId}`

---

### 4. Dashboard & Analytics
**Location:** `lib/features/dashboard/screens/dashboard_screen.dart`

- Week/Month toggle
- Total time card (large display)
- Pie chart (time allocation across activities)
- Activity breakdown with percentages
- Emoji rating distribution
- Session count

---

### 5. Google Authentication
**Location:** `lib/features/auth/`

- Google OAuth Sign-In
- User document creation in Firestore
- Photo, display name, email
- Riverpod providers for auth state
- Auto-navigation on auth state change

---

## 📊 Data Models

### UserModel
```dart
{
  id: String (Firebase UID)
  email: String
  displayName: String?
  photoUrl: String?
  createdAt: DateTime
}
```

### ActivityModel
```dart
{
  id: String (UUID v4)
  userId: String
  name: String
  color: Color (stored as hex: #RRGGBB)
  goal: String?
  createdAt: DateTime
}
```

### SessionModel
```dart
{
  id: String (UUID v4)
  userId: String
  activityId: String
  activityName: String      // Denormalized
  activityColor: Color      // Denormalized
  durationMinutes: Int
  emojiRating: String       // 😞 😐 😊 🤩
  notes: String?
  date: DateTime
  createdAt: DateTime
}
```

---

## 🗄️ Firestore Structure

```
users/
  {userId}/
    - email: string
    - displayName: string
    - photoUrl: string
    - createdAt: timestamp

    activities/
      {activityId}/
        - name: string
        - color: string (#hex)
        - goal: string
        - createdAt: timestamp

    sessions/
      {sessionId}/
        - activityId: string
        - activityName: string (denormalized)
        - activityColor: string (denormalized)
        - durationMinutes: number
        - emojiRating: string
        - notes: string
        - date: timestamp
        - createdAt: timestamp
```

**Security Rules:**
```javascript
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;

  match /activities/{activityId} {
    allow read, write: if request.auth.uid == userId;
  }

  match /sessions/{sessionId} {
    allow read, write: if request.auth.uid == userId;
  }
}
```

---

## 🔧 Build Configuration

### Android (See ANDROID_SETUP.md for details)

**Requirements:**
- **minSdk:** 28 (Android 9.0 Pie)
- **Android Gradle Plugin:** 8.3.0
- **Gradle:** 8.4
- **Kotlin:** 2.1.0
- **Google Services:** 4.4.0

**Critical Setup:**
1. Get debug SHA-1 fingerprint
2. Add to Firebase Console
3. Download `google-services.json`
4. Place in `android/app/`

**Files:**
- `android/settings.gradle` - Plugin versions
- `android/gradle/wrapper/gradle-wrapper.properties` - Gradle version
- `android/app/build.gradle` - minSdk configuration
- `android/app/google-services.json` - Firebase config (from console)

---

### iOS

**Requirements:**
- **Deployment Target:** iOS 12.0+
- **Xcode:** Latest version
- **CocoaPods:** Installed via Homebrew

**Critical Setup:**
1. `ios/Runner/GoogleService-Info.plist` - Firebase config (auto-generated)
2. `ios/Runner/Info.plist` - URL scheme for Google Sign-In
   - Added: `CFBundleURLTypes` with `REVERSED_CLIENT_ID`

**URL Scheme:**
```xml
<key>CFBundleURLSchemes</key>
<array>
  <string>com.googleusercontent.apps.459273318088-vl8c0igep667ebkhrvdpjdor7l98ai5u</string>
</array>
```

---

### Web

**Requirements:**
- Chrome, Brave, or Arc browser
- Web Client ID in `web/index.html`

**Configuration:**
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">
```

**Browser Config:**
```bash
# Set CHROME_EXECUTABLE for Brave/Arc
export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
```

---

## 📱 Navigation Structure

### Bottom Navigation (Order Matters!)
1. **Calendar** (Index 0) - ⭐ DEFAULT/HOME SCREEN
2. **Activities** (Index 1)
3. **Sessions** (Index 2)
4. **Dashboard** (Index 3)

**Location:** `lib/features/home/screens/home_screen.dart`

### Drawer Menu
- User profile with photo
- Navigation shortcuts
- About dialog
- Sign out

---

## 🎨 UI/UX Patterns

### Responsive Design
- **Mobile (≤700px height):** Calendar = 250px fixed height
- **Tablet/Desktop (>700px):** Calendar = 50% of screen height
- Uses `MediaQuery` and `LayoutBuilder`

### Scrolling
- **CustomScrollView** with slivers for smooth scrolling
- Calendar + sessions list scroll together
- No fixed constraints that prevent scrolling

### FAB (Floating Action Button)
- Regular FAB (just + icon, not extended)
- Opens SessionFormScreen
- Positioned at bottom-right

### Empty States
- Friendly icons and messages
- Call-to-action buttons
- Example: "No sessions logged today" with "Log Session" button

### Loading States
- `CircularProgressIndicator` centered
- Shown during async operations

### Error States
- Error icon + message
- Retry button
- Invalidates Riverpod providers on retry

---

## 🔐 Authentication Flow

```
App Start
  ↓
Check Auth State (Riverpod StreamProvider)
  ↓
If Not Authenticated → LoginScreen
  ↓
Google Sign-In Button Clicked
  ↓
GoogleSignIn.signIn() → OAuth Flow
  ↓
Create/Update User Document in Firestore
  ↓
Auth State Changes → Navigate to HomeScreen
  ↓
Load User Data & Sessions
```

**Auth Wrapper:** `lib/main.dart` - `AuthWrapper` widget

---

## 🎯 User Workflows

### First Time User
1. Opens app → LoginScreen
2. Taps "Sign in with Google"
3. OAuth flow completes
4. Lands on Calendar (empty state)
5. Creates first activity
6. Logs first session
7. Sees colored block in calendar

### Logging a Session
1. Tap + FAB (from any screen)
2. Select activity (or see "No Activities" message)
3. Pick date (defaults to today)
4. Enter duration (hours + minutes)
5. Choose emoji rating
6. Add optional notes
7. See live preview
8. Tap "Log Session"
9. Session appears in calendar and sessions list

### Viewing Time Distribution
1. Default screen shows current week
2. Colored blocks show proportional time
3. Tap a day to see session details below
4. Scroll through weeks/months with arrows
5. Toggle between Week/Month views

---

## 🧪 Testing Devices

### Tested On
- **Web:** Chrome, Brave (macOS)
- **Android:** Pixel 7 (Android 16)
- **iOS:** Simulator (not yet on physical device)

### User Context
- **Developer:** MacBook Pro M1 (2021)
- **OS:** macOS 15.7.1
- **IDE:** VSCode
- **Development:** Solo developer

---

## 📝 Coding Conventions

### File Naming
- `snake_case.dart` for all Dart files
- Feature folders: lowercase (e.g., `activities`, `sessions`)
- Screens end with `_screen.dart`
- Services end with `_service.dart`
- Models end with `_model.dart`
- Widgets end with `_card.dart`, `_button.dart`, etc.

### Code Style
- **Flutter/Dart style guide** followed
- **Trailing commas** for better formatting
- **const constructors** where possible
- **Material 3 widgets** preferred

### State Management
- **Riverpod providers** in service files
- **ConsumerWidget/ConsumerStatefulWidget** for components needing state
- **StreamProvider** for real-time Firestore data
- **Provider** for services (singleton-like)

### Error Handling
- Try-catch blocks in async operations
- User-friendly error messages via SnackBar
- Retry mechanisms for network failures
- Context.mounted checks before navigation

---

## 🚨 Important Gotchas

### 1. Google Sign-In Platform-Specific Setup
- **Android:** Requires SHA-1 fingerprint in Firebase Console
- **iOS:** Requires URL scheme in Info.plist
- **Web:** Requires Client ID in index.html
- Different for each platform - don't forget!

### 2. Firestore Timestamp Conversion
```dart
// Always convert Timestamp to DateTime
date: (data['date'] as Timestamp).toDate()

// Always convert DateTime to Timestamp when saving
'date': Timestamp.fromDate(date)
```

### 3. Color Serialization
```dart
// Store as hex string
'activityColor': '#${color.value.toRadixString(16).substring(2)}'

// Parse back to Color
Color(int.parse(data['activityColor'].substring(1), radix: 16) + 0xFF000000)
```

### 4. Session Denormalization
Activity name and color are **denormalized** in SessionModel to avoid joins. If activity is deleted, sessions keep the old name/color.

### 5. Calendar Height Calculation
```dart
// Mobile
final calendarHeight = 250.0;

// Large screen
final calendarHeight = constraints.maxHeight * 0.5;
```

### 6. Proportional Block Flex
```dart
// Use flex for proportional heights
Expanded(
  flex: (heightPercent * 100).round(),
  child: Container(color: activityColor)
)
```

### 7. Date Normalization
Always normalize dates to midnight when comparing:
```dart
final dayDate = DateTime(day.year, day.month, day.day);
```

---

## 📚 Reference Documentation

### Created During Development
- `ANDROID_SETUP.md` - Complete Android build setup guide
- `FLUTTER_SETUP.md` - Flutter installation for M1 Mac
- `FIREBASE_SETUP.md` - Firebase configuration steps
- `FIX_GOOGLE_SIGNIN.md` - Google Sign-In troubleshooting
- `FRESH_START_GUIDE.md` - Complete Firebase reset guide

### Key Scripts
- `setup_flutter.sh` - Automated Flutter installation
- `create_flutter_project.sh` - Project creation with Firebase
- `configure_browser.sh` - Brave/Arc browser setup
- `reset_firebase.sh` - Clean Firebase configuration

---

## 🔄 Migration History

### Original Stack (Archived)
- **Frontend:** Angular 17
- **Backend:** .NET 8
- **Database:** PostgreSQL
- **Hosting:** Azure

### Current Stack (Active)
- **Frontend:** Flutter 3.27.1
- **Backend:** Firebase (Firestore, Auth, Functions)
- **Hosting:** Firebase Hosting (future)

**Reason for Migration:**
- Cross-platform mobile support (iOS + Android + Web)
- Faster development for solo developer
- Real-time data sync with Firestore
- Simplified hosting and scaling

**Archived Code:** `helix-archive/` folder

---

## 🎯 Current Implementation Status

### ✅ Completed
- [x] Google OAuth authentication
- [x] User profile management
- [x] Activity CRUD operations
- [x] Session logging with emoji ratings
- [x] Calendar view (Week/Month with proportional blocks)
- [x] Sessions list with filtering
- [x] Dashboard analytics with charts
- [x] Bottom navigation
- [x] Material 3 theme
- [x] Responsive design
- [x] Android build configuration
- [x] iOS build configuration
- [x] Web build configuration

### 🚧 In Progress
- [ ] iOS physical device testing
- [ ] Android physical device testing (Pixel 7)

### 📋 Future Enhancements
- [ ] Session editing improvements
- [ ] Activity statistics per activity
- [ ] Weekly/monthly goals
- [ ] Export data (CSV, PDF)
- [ ] Dark mode toggle
- [ ] Streak tracking
- [ ] Notifications/reminders
- [ ] Data backup/restore
- [ ] Social features (optional)
- [ ] AI insights (optional)

---

## 🐛 Known Issues

### Android Build Errors (Fixed)
All resolved - see `ANDROID_SETUP.md`

### Web OAuth
Works perfectly now after enabling People API

### iOS Testing
Not yet tested on physical device - simulator only

---

## 💡 Development Tips

### Quick Commands
```bash
# Clean build
flutter clean && flutter pub get

# Run on specific device
flutter run -d chrome
flutter run -d "iPhone 15"
flutter run  # Auto-selects connected Android

# Hot reload
r  # While app is running

# Build release
flutter build apk --release  # Android
flutter build ios --release  # iOS
flutter build web --release  # Web
```

### Firebase Emulator (Future)
```bash
firebase emulators:start
```

### Debugging
- Use `print()` for quick debugging
- Use DevTools for performance profiling
- Check Firestore console for data issues
- Check Authentication console for user issues

---

## 🎨 Design Decisions

### Why Calendar as Main Screen?
The visual DNA of colored blocks is the core value proposition. Users should immediately see their time investment when opening the app.

### Why Emoji Ratings?
Quick, visual, emotional feedback. Easier than text or numerical ratings. Fun and engaging.

### Why Denormalized Data?
Session keeps activity name/color even if activity is deleted. Preserves historical accuracy. Trade-off: slight data duplication vs. simpler queries.

### Why Week + Month Views?
- Week view: Detailed daily breakdown for current week planning
- Month view: Big picture overview for monthly patterns

### Why Proportional Blocks?
Visual comparison is faster than reading numbers. The DNA metaphor makes time tracking more engaging and insightful.

---

## 🔮 Next Steps for Development

1. **Test on physical devices**
   - Android: Add SHA-1, test on Pixel 7
   - iOS: Test on iPhone/iPad

2. **Implement missing features**
   - Goals and tracking
   - Notifications
   - Export functionality

3. **Performance optimization**
   - Image caching
   - Query optimization
   - Bundle size reduction

4. **App store deployment**
   - Screenshots
   - App store descriptions
   - Privacy policy
   - Terms of service

5. **Marketing website**
   - Landing page
   - Documentation
   - Support

---

## 📞 Important Context for AI Assistants

### When Working on This Project

**Remember:**
1. Calendar is the MAIN screen (not dashboard)
2. Proportional color blocks are the core feature
3. Mobile-first design (but responsive for tablets)
4. Material 3 design system throughout
5. Riverpod for state management
6. Feature-based folder structure
7. Android requires SHA-1 fingerprint setup
8. iOS requires URL scheme in Info.plist

**Don't:**
1. Create new files when editing existing ones will do
2. Use emojis in code unless explicitly asked
3. Add features not in the spec without confirming
4. Break the proportional color block logic
5. Change navigation order without permission
6. Remove error handling or validation

**Always:**
1. Use existing color palette from `app_colors.dart`
2. Follow Material 3 design patterns
3. Check if session exists before showing in calendar
4. Normalize dates when comparing
5. Use Riverpod providers for Firestore queries
6. Handle loading/error states
7. Add todos for multi-step tasks

---

**Last Updated:** Based on session ending with Android build setup documentation

**Project State:** Core features complete, ready for physical device testing

**Repository:** https://github.com/Stannlag/helix (or local git repo)
