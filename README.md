# 🧬 Helix - Time & Growth Tracker

**Transform scattered efforts into structured growth with a DNA-inspired time tracker.**

## Project Status: Flutter Migration in Progress

We're rebuilding Helix from Angular/.NET to **Flutter + Firebase** for a truly cross-platform experience!

---

## 📱 Platforms

- ✅ iOS (iPhone & iPad)
- ✅ Android (Phone & Tablet)
- ✅ Web (Progressive Web App)

---

## 🎯 Core Features (MVP)

1. **Google Sign-In** - Secure authentication
2. **Custom Activities** - Track guitar, coding, gym, etc. with custom colors
3. **Session Logging** - Log time with emoji ratings (😞 😐 😊 🤩)
4. **Helix Calendar** - Color-coded monthly/weekly view
5. **Dashboard** - Time allocation analytics

---

## 🛠️ Tech Stack

### New Stack (Current)
- **Frontend**: Flutter 3.x (iOS/Android/Web)
- **Backend**: Firebase (Firestore, Auth, Functions)
- **Auth**: Firebase Auth (Google OAuth)
- **Database**: Cloud Firestore
- **Hosting**: Firebase Hosting (Web)

### Old Stack (Archived)
- Frontend: Angular 19
- Backend: .NET 8 API
- Database: PostgreSQL
- Location: `helix-archive/`

---

## 🚀 Getting Started

### Prerequisites
- macOS 11+ (for iOS development)
- Flutter SDK
- Firebase account
- VSCode with Flutter extensions

### Installation Steps

**Step 1: Install Flutter**
```bash
./setup_flutter.sh
```
Or follow: [FLUTTER_SETUP.md](./FLUTTER_SETUP.md)

**Step 2: Set Up Firebase**
Follow: [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)

**Step 3: Create Flutter Project**
*(Coming next - once Flutter is installed)*

---

## 📂 Project Structure

```
helix/
├── helix-app/              # New Flutter app (TO BE CREATED)
├── helix-archive/          # Old Angular/.NET app
├── Documentation/          # Project docs, roadmap, personas
├── Design/                 # UI mockups and assets
├── QUICK_START.md         # Quick reference guide
├── FLUTTER_SETUP.md       # Detailed Flutter setup
├── FIREBASE_SETUP.md      # Detailed Firebase setup
└── setup_flutter.sh       # Automated Flutter installer
```

---

## 🎨 Design Philosophy

- **DNA Helix Metaphor** - Spiral of progress
- **Material Design 3** - Modern, beautiful UI
- **Color-Coded** - Visual time allocation
- **Emotion-First** - Emoji ratings for qualitative feedback

---

## 📋 Development Roadmap

### Phase 1: MVP (Current)
- [ ] Flutter project setup
- [ ] Firebase integration
- [ ] Google Authentication
- [ ] Activity management
- [ ] Session logging
- [ ] Calendar view
- [ ] Basic analytics

### Phase 2: Polish
- [ ] Streaks & notifications
- [ ] Data export (CSV/PDF)
- [ ] Predefined tags
- [ ] Enhanced analytics

### Phase 3: Social
- [ ] Shared goals
- [ ] Progress sharing
- [ ] Community features

### Phase 4: AI & Advanced
- [ ] AI insights
- [ ] Smart recommendations
- [ ] Advanced analytics

---

## 👥 User Personas

1. **Hobbyist Hannah** - Learning guitar for wedding
2. **Professional Paul** - Building side projects
3. **Student Sam** - Balancing studies and hobbies

See: [Documentation/Foundational Documents/User Personas.docx](./Documentation/Foundational%20Documents/User%20Personas.docx)

---

## 🤝 Contributing

This is currently a solo project by Stanley Laguerre.

---

## 📄 License

Private project - All rights reserved

---

## 📞 Contact

For questions or feedback about the project, please refer to the documentation.

---

## 🎯 Success Metrics (MVP)

- 20 active users in 3 months
- 80% find it "intuitive" and "visually motivating"
- 40% weekly retention after 1 month
- 4.5+ star average rating

---

## 🔗 Quick Links

- [Project Charter](./Documentation/Foundational%20Documents/Project%20Charter.docx)
- [Project Roadmap](./Documentation/Foundational%20Documents/Project%20Roadmap.docx)
- [Technical Documentation](./Documentation/Technical%20Documents/Technical%20Doc.docx)
- [User Stories](./Documentation/Technical%20Documents/User%20Stories%20and%20Dev%20Process.docx)

---

**Last Updated**: November 2025
**Status**: 🚧 Migration to Flutter in progress
