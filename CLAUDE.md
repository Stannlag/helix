# CLAUDE.md - AI Assistant Guide for Helix

This document provides comprehensive guidance for AI assistants working on the Helix project.

## Project Overview

**Helix** is a cross-platform time investment tracker mobile app that helps users transform scattered efforts into structured growth. The app uses a DNA helix metaphor and features a color-coded calendar system with emoji-driven insights.

### Core Concept
- Users create custom activities (e.g., "Guitar Practice", "Learning Spanish")
- Each activity has a name, custom color, and optional goal
- Users log time sessions with duration, emoji ratings (😞 😐 😊 🤩), and optional notes
- Calendar visualizes time allocation with proportional color-coded blocks
- Dashboard provides analytics on time investment

### Technology Stack
- **Frontend**: Flutter 3.27.1 (iOS, Android, Web)
- **Language**: Dart 3.6+
- **State Management**: Riverpod 2.6.1
- **Backend**: Firebase (Authentication, Firestore)
- **Authentication**: Firebase Auth (Google OAuth)
- **Database**: Cloud Firestore (NoSQL)
- **UI Framework**: Material Design 3
- **Calendar**: table_calendar package
- **Charts**: fl_chart package
- **Typography**: Google Fonts (Inter)

### Platform Support
- ✅ **iOS** - iPhone & iPad (iOS 12+)
- ✅ **Android** - Phones & Tablets (minSdkVersion 28 / Android 9.0)
- ✅ **Web** - Chrome, Brave, Arc browsers

---

## Repository Structure

```
helix/
├── helix-app/                   # Current Flutter application
│   ├── lib/
│   │   ├── core/                # Shared utilities and constants
│   │   │   ├── theme/           # Material 3 theme configuration
│   │   │   │   ├── app_colors.dart
│   │   │   │   └── app_theme.dart
│   │   │   ├── constants/
│   │   │   │   └── emoji_ratings.dart
│   │   │   └── utils/
│   │   │       └── date_helpers.dart
│   │   │
│   │   ├── shared/              # Shared models
│   │   │   └── models/
│   │   │       └── user_model.dart
│   │   │
│   │   ├── features/            # Feature-based organization
│   │   │   ├── auth/
│   │   │   │   ├── screens/
│   │   │   │   │   └── login_screen.dart
│   │   │   │   └── services/
│   │   │   │       └── auth_service.dart
│   │   │   │
│   │   │   ├── home/
│   │   │   │   └── screens/
│   │   │   │       └── home_screen.dart
│   │   │   │
│   │   │   ├── activities/
│   │   │   │   ├── models/
│   │   │   │   │   └── activity_model.dart
│   │   │   │   ├── services/
│   │   │   │   │   └── activity_service.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── activities_screen.dart
│   │   │   │   │   └── activity_form_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── activity_card.dart
│   │   │   │
│   │   │   ├── sessions/
│   │   │   │   ├── models/
│   │   │   │   │   └── session_model.dart
│   │   │   │   ├── services/
│   │   │   │   │   └── session_service.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── sessions_screen.dart
│   │   │   │   │   └── session_form_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── session_card.dart
│   │   │   │
│   │   │   ├── calendar/
│   │   │   │   └── screens/
│   │   │   │       └── calendar_screen.dart
│   │   │   │
│   │   │   └── dashboard/
│   │   │       └── screens/
│   │   │           └── dashboard_screen.dart
│   │   │
│   │   ├── firebase_options.dart
│   │   └── main.dart
│   │
│   ├── android/                 # Android platform config
│   ├── ios/                     # iOS platform config
│   ├── web/                     # Web platform config
│   ├── pubspec.yaml             # Dependencies
│   ├── analysis_options.yaml    # Dart linter rules
│   └── README.md
│
├── helix-archive/               # Archived Angular/.NET implementation
│   ├── helix-front/            # Old Angular 19 app
│   └── helix-back/             # Old .NET 8 API
│
├── Design/                      # UI/UX mockups and design assets
│   ├── logo.xml
│   ├── month_view.html/png
│   └── week_view.html/png
│
├── Documentation/
│   ├── Foundational Documents/  # Project charter, roadmap, personas
│   └── Technical Documents/     # Technical specs, user stories
│
├── QUICK_START.md               # Quick reference guide
├── FLUTTER_SETUP.md             # Flutter installation guide
├── FIREBASE_SETUP.md            # Firebase configuration guide
├── ANDROID_SETUP.md             # Android build setup
├── README.md                    # Project overview
├── Helix-context.md             # Quick AI context reference
└── .gitignore
```

---

## Architecture & Design Patterns

### Clean Architecture Pattern

The Flutter app follows **Clean Architecture** principles with feature-based organization:

#### Layer Structure

1. **Presentation Layer** (`screens/` and `widgets/`)
   - UI components built with Material 3
   - Screen navigation and layout
   - User input handling
   - State consumption via Riverpod

2. **Business Logic Layer** (`services/`)
   - Service classes with Riverpod providers
   - Business rules and validation
   - Data transformation
   - State management

3. **Data Layer** (`models/`)
   - Data models with Firestore serialization
   - `fromFirestore()` factory constructors
   - `toFirestore()` methods
   - Immutable model classes

#### Key Patterns

**State Management with Riverpod**
```dart
// Define providers in service files
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final activitiesProvider = StreamProvider<List<ActivityModel>>((ref) {
  final userId = ref.watch(currentUserProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ActivityService().getActivitiesStream(userId);
});

// Consume in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    return activities.when(
      data: (list) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

**Model Pattern with Firestore**
```dart
class ActivityModel {
  final String id;
  final String userId;
  final String name;
  final Color color;
  final String? goal;
  final DateTime createdAt;

  // Constructor
  ActivityModel({...});

  // From Firestore
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(...);
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {...};
  }
}
```

**Service Pattern**
```dart
class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'activities';

  // Stream for real-time updates
  Stream<List<ActivityModel>> getActivitiesStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromFirestore(doc))
            .toList());
  }

  // CRUD operations
  Future<void> createActivity(ActivityModel activity) async {
    await _firestore.collection(_collection).add(activity.toFirestore());
  }
}
```

---

## Database Schema (Firestore)

### Collections

#### users
```
users/{userId}
├── id (auto-generated document ID)
├── email (String)
├── displayName (String)
├── photoUrl (String, optional)
└── createdAt (Timestamp)
```

#### activities
```
activities/{activityId}
├── id (auto-generated document ID)
├── userId (String, indexed)
├── name (String)
├── colorHex (String, e.g., "#4CAF50")
├── goal (String, optional)
└── createdAt (Timestamp)
```

#### sessions
```
sessions/{sessionId}
├── id (auto-generated document ID)
├── userId (String, indexed)
├── activityId (String, indexed)
├── activityName (String, denormalized)
├── activityColor (String, denormalized)
├── durationMinutes (int)
├── emojiRating (String: "😞" | "😐" | "😊" | "🤩")
├── notes (String, optional)
├── date (Timestamp)
└── createdAt (Timestamp)
```

### Firestore Indexes
- `sessions`: Composite index on (`userId`, `date` descending)
- `activities`: Single field index on `userId`

### Data Denormalization
- Sessions store `activityName` and `activityColor` denormalized for performance
- Reduces need for joins when displaying session lists

---

## Development Workflows

### Prerequisites

**Required Software:**
- Flutter SDK 3.27.1+
- Dart SDK 3.6+
- Firebase CLI (for deployment)
- VSCode or Android Studio with Flutter extensions
- For iOS: Xcode 14+ on macOS
- For Android: Android SDK (API 28+)

**Setup Scripts Available:**
- `setup_flutter.sh` - Install Flutter SDK
- `setup_dependencies.sh` - Install project dependencies
- `setup_web_client_id.sh` - Configure Google Sign-In

### Initial Setup

```bash
# 1. Install Flutter (if not already installed)
./setup_flutter.sh

# 2. Navigate to app directory
cd helix-app

# 3. Get dependencies
flutter pub get

# 4. Configure Firebase
# Follow instructions in FIREBASE_SETUP.md

# 5. Run on desired platform
flutter run                # Default device
flutter run -d chrome      # Web
flutter run -d macos       # macOS
```

### Running the App

**Development Mode:**
```bash
cd helix-app

# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices              # List devices
flutter run -d chrome        # Web
flutter run -d iPhone        # iOS Simulator
flutter run -d emulator-5554 # Android Emulator

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
```

**Build for Production:**
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release
```

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

---

## Coding Conventions & Best Practices

### Dart/Flutter Conventions

#### General Dart Style
- **Follow official Dart style guide**: https://dart.dev/guides/language/effective-dart/style
- **Use `flutter_lints`**: Already configured in `analysis_options.yaml`
- **Prefer `const` constructors**: Use `const` when widgets/objects are compile-time constants
- **Use trailing commas**: Improves formatting for multi-line function calls
- **Avoid `var`**: Use explicit types or `final`/`const`

#### File Naming
- **Snake_case** for all Dart files: `activity_service.dart`, `login_screen.dart`
- **One class per file** (generally)
- **File name matches class name**: `ActivityModel` → `activity_model.dart`

#### Widget Conventions

**StatelessWidget vs StatefulWidget vs ConsumerWidget:**
```dart
// Use StatelessWidget for static UI
class MyStaticWidget extends StatelessWidget {
  const MyStaticWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}

// Use StatefulWidget for local state
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

// Use ConsumerWidget for Riverpod state
class MyConsumerWidget extends ConsumerWidget {
  const MyConsumerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(someProvider);
    return Text(value);
  }
}
```

**Always use `const` when possible:**
```dart
// Good
const Text('Hello')
const SizedBox(height: 16)
const EdgeInsets.all(8)

// Bad
Text('Hello')
SizedBox(height: 16)
EdgeInsets.all(8)
```

**Extract complex widgets:**
```dart
// Good - extracted widget
class ActivityList extends StatelessWidget {
  final List<ActivityModel> activities;

  const ActivityList({required this.activities, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(...);
  }
}

// Bad - deeply nested
Widget build(BuildContext context) {
  return Column(
    children: [
      ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              // 10+ lines of code
            ),
          );
        },
      ),
    ],
  );
}
```

#### Model Conventions

```dart
class MyModel {
  // Fields should be final
  final String id;
  final String name;
  final DateTime createdAt;
  final String? optionalField; // Nullable fields use ?

  // Constructor with named parameters
  MyModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.optionalField,
  });

  // Firestore serialization
  factory MyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MyModel(
      id: doc.id,
      name: data['name'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      optionalField: data['optionalField'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (optionalField != null) 'optionalField': optionalField,
    };
  }

  // CopyWith for immutability
  MyModel copyWith({
    String? name,
    DateTime? createdAt,
    String? optionalField,
  }) {
    return MyModel(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      optionalField: optionalField ?? this.optionalField,
    );
  }
}
```

#### Service Conventions

```dart
class MyService {
  // Private singleton
  static final MyService _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'myCollection';

  // Stream for real-time data
  Stream<List<MyModel>> getItemsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MyModel.fromFirestore(doc))
            .toList());
  }

  // CRUD operations return Future<void> or Future<Model>
  Future<void> createItem(MyModel item) async {
    await _firestore.collection(_collection).add(item.toFirestore());
  }

  Future<void> updateItem(String id, MyModel item) async {
    await _firestore.collection(_collection).doc(id).update(item.toFirestore());
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
```

#### Riverpod Provider Conventions

```dart
// Place providers in service files or dedicated providers.dart

// StreamProvider for real-time data
final activitiesProvider = StreamProvider.autoDispose<List<ActivityModel>>((ref) {
  final userId = ref.watch(currentUserProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ActivityService().getActivitiesStream(userId);
});

// FutureProvider for one-time async operations
final activityProvider = FutureProvider.family<ActivityModel, String>((ref, id) async {
  return await ActivityService().getActivity(id);
});

// StateProvider for simple state
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// StateNotifierProvider for complex state
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});
```

### Material Design 3 Guidelines

- **Use Material 3 components**: `FilledButton`, `OutlinedButton`, `Card.filled()`
- **Follow color scheme**: Use `Theme.of(context).colorScheme.primary` instead of hardcoded colors
- **Consistent spacing**: Use multiples of 4 or 8 (4, 8, 16, 24, 32)
- **Use Scaffold**: Every screen should have a `Scaffold` widget
- **AppBar consistency**: Keep AppBar styling consistent across screens

---

## Common Tasks & Examples

### Adding a New Feature

1. **Create feature directory structure:**
```bash
lib/features/my_feature/
├── models/
│   └── my_model.dart
├── services/
│   └── my_service.dart
├── screens/
│   └── my_screen.dart
└── widgets/
    └── my_widget.dart
```

2. **Create the model:**
```dart
// lib/features/my_feature/models/my_model.dart
class MyModel {
  final String id;
  final String name;

  MyModel({required this.id, required this.name});

  factory MyModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

3. **Create the service with Riverpod provider:**
```dart
// lib/features/my_feature/services/my_service.dart
class MyService {
  Stream<List<MyModel>> getItemsStream() { ... }
  Future<void> createItem(MyModel item) { ... }
}

final myItemsProvider = StreamProvider<List<MyModel>>((ref) {
  return MyService().getItemsStream();
});
```

4. **Create the screen:**
```dart
// lib/features/my_feature/screens/my_screen.dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(myItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: items.when(
        data: (list) => ListView(...),
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
}
```

### Adding a New Firestore Collection

1. **Create the model** with Firestore serialization
2. **Create the service** with CRUD methods
3. **Add Riverpod provider** for state management
4. **Update Firestore Security Rules** in Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /myCollection/{documentId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

### Making API Calls to Firebase

**Reading Data (Real-time Stream):**
```dart
Stream<List<ActivityModel>> getActivitiesStream(String userId) {
  return _firestore
      .collection('activities')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList());
}
```

**Creating Data:**
```dart
Future<void> createActivity(ActivityModel activity) async {
  try {
    await _firestore.collection('activities').add(activity.toFirestore());
  } catch (e) {
    debugPrint('Error creating activity: $e');
    rethrow;
  }
}
```

**Updating Data:**
```dart
Future<void> updateActivity(String id, ActivityModel activity) async {
  await _firestore
      .collection('activities')
      .doc(id)
      .update(activity.toFirestore());
}
```

**Deleting Data:**
```dart
Future<void> deleteActivity(String id) async {
  await _firestore.collection('activities').doc(id).delete();
}
```

---

## Testing Guidelines

### Unit Testing
```dart
// test/models/activity_model_test.dart
void main() {
  group('ActivityModel', () {
    test('should create from Firestore', () {
      final doc = MockDocumentSnapshot();
      final activity = ActivityModel.fromFirestore(doc);
      expect(activity.name, 'Test Activity');
    });
  });
}
```

### Widget Testing
```dart
// test/widgets/activity_card_test.dart
void main() {
  testWidgets('ActivityCard displays activity name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ActivityCard(
          activity: ActivityModel(...),
        ),
      ),
    );

    expect(find.text('Guitar Practice'), findsOneWidget);
  });
}
```

### Integration Testing
- Use Firebase Emulator Suite for local testing
- Test authentication flows end-to-end
- Test Firestore CRUD operations

---

## Security Considerations

### Firebase Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /activities/{activityId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    match /sessions/{sessionId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

### Best Practices
- **Never expose API keys in code**: Use environment variables or Firebase config
- **Validate on client AND server**: Use Firestore security rules as server-side validation
- **Sanitize user input**: Validate all form inputs before saving
- **Use HTTPS only**: Firebase enforces this by default
- **Implement proper error handling**: Don't expose sensitive error details to users

---

## Current Project Status

### Completed Features ✅
- Project structure setup (Flutter + Firebase)
- Firebase Authentication with Google Sign-In
- Material Design 3 theme implementation
- Activity management (CRUD with color picker)
- Session logging with emoji ratings
- Calendar view with table_calendar
- Dashboard with basic analytics
- Real-time data sync with Firestore
- Riverpod state management
- Cross-platform support (iOS, Android, Web)

### In Progress 🚧
- Enhanced dashboard analytics
- Session editing capabilities
- Data export functionality
- Improved error handling and user feedback

### Upcoming 📋
- Streaks and notifications
- Goal tracking and progress visualization
- Weekly/monthly reports
- Data backup and restore
- Predefined activity templates
- Dark mode support

---

## Migration Notes

### From Angular/.NET to Flutter

The project was migrated from Angular 19 + .NET 8 to Flutter + Firebase:

**Why Flutter?**
- True cross-platform support (iOS, Android, Web) with single codebase
- Better mobile performance and native feel
- Simplified backend with Firebase (no server management)
- Faster development cycle with hot reload
- Better suited for mobile-first time tracking app

**Old Stack Location:**
- `helix-archive/helix-front/` - Angular 19 frontend
- `helix-archive/helix-back/` - .NET 8 backend (Clean Architecture)

**Architectural Differences:**
- **Backend**: PostgreSQL + .NET API → Cloud Firestore + Firebase
- **State**: Angular Services + RxJS → Riverpod Providers
- **UI**: Angular Material → Material Design 3 (Flutter)
- **Auth**: Firebase Admin SDK → Firebase Auth client SDK

---

## Troubleshooting

### Common Issues

**Flutter not found:**
```bash
# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"
# Or run setup script
./setup_flutter.sh
```

**Google Sign-In not working:**
- Check Firebase configuration in `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Verify SHA-1/SHA-256 fingerprints in Firebase Console
- See: `FIX_GOOGLE_SIGNIN.md`

**Firestore permission denied:**
- Check Firestore Security Rules in Firebase Console
- Ensure user is authenticated
- Verify `userId` field matches authenticated user

**Build errors on iOS:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

**Build errors on Android:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**Web app not loading:**
- Check Firebase configuration in `web/index.html`
- Verify CORS settings in Firebase Hosting
- Clear browser cache and try incognito mode

---

## Useful Commands Reference

### Flutter CLI
```bash
flutter doctor              # Check installation
flutter devices             # List connected devices
flutter run                 # Run on default device
flutter run -d chrome       # Run on specific device
flutter build apk           # Build Android APK
flutter build ios           # Build iOS app
flutter build web           # Build web app
flutter clean               # Clean build cache
flutter pub get             # Get dependencies
flutter pub upgrade         # Upgrade dependencies
flutter test                # Run tests
flutter analyze             # Analyze code
```

### Firebase CLI
```bash
firebase login              # Login to Firebase
firebase projects:list      # List projects
firebase use <project-id>   # Select project
firebase deploy             # Deploy to hosting
firebase emulators:start    # Start local emulators
```

### Git Workflow
```bash
git checkout -b feature/branch-name
git add .
git commit -m "feat: description"
git push origin feature/branch-name
```

---

## Additional Resources

- **Flutter Documentation**: https://docs.flutter.dev
- **Dart Documentation**: https://dart.dev/guides
- **Firebase Documentation**: https://firebase.google.com/docs
- **Riverpod Documentation**: https://riverpod.dev
- **Material Design 3**: https://m3.material.io
- **table_calendar**: https://pub.dev/packages/table_calendar
- **fl_chart**: https://pub.dev/packages/fl_chart

---

## AI Assistant Guidelines

### When Working on This Project

1. **Understand the migration**: The project switched from Angular/.NET to Flutter
2. **Follow Flutter conventions**: Use official Dart style guide
3. **Use Riverpod for state**: All global state should use Riverpod providers
4. **Feature-based organization**: Keep related files in feature directories
5. **Material Design 3**: Use modern Material components and theming
6. **Firebase best practices**: Implement security rules and optimize queries
7. **Test your changes**: Run on multiple platforms when possible
8. **Document as you go**: Update this file with new patterns or conventions

### Code Generation Tips

- **Models**: Include both `fromFirestore()` and `toFirestore()` methods
- **Services**: Create singleton pattern with Firestore integration
- **Providers**: Use appropriate Riverpod provider type (Stream, Future, State)
- **Screens**: Always use `Scaffold`, include error handling
- **Widgets**: Extract complex UI into separate widget files
- **Const constructors**: Use `const` wherever possible for performance

### When in Doubt

1. Check existing similar code for patterns
2. Refer to this CLAUDE.md document
3. Consult official Flutter/Firebase documentation
4. Check claude.md for business logic context
5. Ask the user for clarification on requirements

---

*Last Updated: 2025-11-17*
*Version: 2.0 (Flutter Migration)*
