# Helix - AI Context Guide  
**Project Type**: Time Investment Tracker (Web App)  

---

## 🎯 Core Vision  
Transform scattered efforts into structured growth with a **DNA-inspired time tracker**. Users visualize progress via a color-coded calendar and emoji-driven insights.  

**Key Metaphor**:  
- 🧬 **Helix**: Symbolizes incremental, interconnected progress.  
- 🎨 **Calendar Blocks**: Time allocation = colored segments (e.g., 2h guitar = 50% blue).  

---

## 🚀 MVP Features  
1. **Google OAuth** (Firebase)  
2. **Custom Activities** (Name, Color, Optional Goal)  
3. **Session Logging**  
   - Manual time entry (hours/minutes)  
   - Emoji ratings: 😞 😐 😊 🤩  
4. **Monthly Calendar View**  

---

## 🛠️ Tech Stack (Latest Stable)  
| Component       | Technology              | Version | Key Tools/Libraries                  |  
|-----------------|-------------------------|---------|---------------------------------------|  
| **Frontend**    | Angular                 | 17      | FullCalendar, Angular Material       |  
| **Backend**     | .NET                    | 8       | EF Core 8, Minimal APIs              |  
| **Database**    | PostgreSQL              | 16      | Azure PostgreSQL                     |  
| **Auth**        | Firebase                | 10      | AngularFire, Firebase Admin SDK      |  
| **Hosting**     | Azure                   | -       | Static Web Apps, App Service         |  

---

## 🏗️ Architecture  
```plaintext
[Angular SPA] ↔ [.NET API] ↔ [PostgreSQL]  
       ↑  
  [Firebase Auth]  

  ---
## 📂 Database Schema

### Users
```sql
CREATE TABLE Users (
  Id UUID PRIMARY KEY,
  GoogleId TEXT NOT NULL UNIQUE,
  Email TEXT NOT NULL
);
```

### Activities
```sql
CREATE TABLE Activities (
  Id UUID PRIMARY KEY,
  UserId UUID REFERENCES Users(Id) ON DELETE CASCADE,
  Name TEXT NOT NULL,
  ColorHex TEXT DEFAULT '#4CAF50',
  Goal TEXT
);
```

### Sessions
```sql
CREATE TABLE Sessions (
  Id UUID PRIMARY KEY,
  ActivityId UUID REFERENCES Activities(Id) ON DELETE CASCADE,
  DurationMinutes INT NOT NULL CHECK (DurationMinutes > 0),
  EmojiRating TEXT CHECK (EmojiRating IN ('😞', '😐', '😊', '🤩')),
  Date DATE NOT NULL
);
```

---

## 🔧 Current Priorities

1. **Authentication**
   - Google OAuth implementation (Angular + .NET)
   - JWT token validation middleware

2. **Calendar Prototype**
   - FullCalendar integration with mock data
   - Color-coded day blocks

3. **Core Data Logging**
   - Activity creation form
   - Session logging with emoji ratings

---

## 📜 Coding Guidelines

### Angular 17

- Use **standalone components** (no NgModules)
- New control flow syntax:
  ```html
  @if (isLoggedIn) {
    <app-calendar />
  }
  ```

### .NET 8

- **Minimal APIs** for endpoints:
  ```csharp
  app.MapPost("/sessions", (SessionDto dto) => { ... });
  ```
- **FluentValidation** for DTOs:
  ```csharp
  RuleFor(x => x.DurationMinutes).GreaterThan(0);
  ```

---

## 🌐 Future Roadmap

| Phase | Features                          | Timeline       |
|-------|-----------------------------------|----------------|
| 1.1   | Session editing/deletion          | Post-MVP Week  |
| 2.0   | Time allocation analytics         | +3 Weeks       |
| 3.0   | Social features & AI insights     | +8 Weeks       |
