# Helix - Flutter Dependencies

This file lists all the dependencies that will be added to the project.

## Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0
  firebase_analytics: ^11.3.8

  # Google Sign In
  google_sign_in: ^6.2.2

  # State Management
  flutter_riverpod: ^2.6.1

  # UI Components
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.14

  # Calendar
  table_calendar: ^3.1.2
  intl: ^0.19.0

  # Charts
  fl_chart: ^0.70.2

  # Utilities
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## Why These Packages?

### Firebase Packages
- **firebase_core**: Required for all Firebase features
- **firebase_auth**: User authentication with Google
- **cloud_firestore**: NoSQL database for activities and sessions
- **firebase_analytics**: Track user behavior

### Google Sign In
- **google_sign_in**: Official Google authentication

### State Management
- **flutter_riverpod**: Modern, simple state management (better than Provider)

### UI Components
- **google_fonts**: Beautiful typography
- **flutter_svg**: For logo and icons

### Calendar
- **table_calendar**: Customizable calendar widget (we'll style it for Helix)
- **intl**: Date/time formatting

### Charts
- **fl_chart**: Beautiful charts for analytics dashboard

### Utilities
- **uuid**: Generate unique IDs for documents

---

## Installation

These will be added automatically when you run the setup script.

Manual installation:
```bash
cd helix-app
flutter pub add firebase_core firebase_auth cloud_firestore firebase_analytics
flutter pub add google_sign_in
flutter pub add flutter_riverpod
flutter pub add google_fonts flutter_svg
flutter pub add table_calendar intl
flutter pub add fl_chart
flutter pub add uuid
```
