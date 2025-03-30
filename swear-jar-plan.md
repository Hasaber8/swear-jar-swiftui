# Swear Jar App - Implementation Plan

This implementation plan is based on the PRD and SQLite backend spec. It outlines the functional roadmap and module-level structure for building the Swear Jar app using **SwiftUI for iOS** and **Kotlin for Android** (instead of Jetpack Compose). The main focus of development is on the **iOS app**.

---

## 🧭 Screens Overview

### Core Screens
1. HomeScreen
2. LogSwearScreen
3. MoodTrackingScreen
4. InsightsScreen
5. UserProfileScreen
6. SettingsScreen

### Secondary Screens
7. OnboardingScreen
8. StreakCelebrationScreen
9. AccountabilityScreen
10. DonationScreen
11. HistoryScreen
12. MindfulnessScreen

---

## 🧱 Implementation Roadmap by Screen

### 1. **HomeScreen**
**Purpose:** Dashboard with streak info, trends, recent logs, and navigation access.

- [ ] SwiftUI layout
- [ ] Hook up streak value from DB (via `users.streak_days`)
- [ ] Graph trends from `daily_summaries`
- [ ] Show recent `swear_logs` (last 2)
- [ ] Navigate to LogSwearScreen, InsightsScreen

### 2. **LogSwearScreen**
**Purpose:** Logging new swear events with mood, word, reflection.

- [ ] Word selection from `swear_dictionary` (autocomplete)
- [ ] Mood selector (emoji)
- [ ] Context note (optional)
- [ ] "Worth it?" toggle
- [ ] Save log → `swear_logs`
- [ ] Update `users.total_swears`, `total_fine`, `streak_days`
- [ ] Auto-update `daily_summaries`

### 3. **MoodTrackingScreen**
**Purpose:** Track mood without logging a swear.

- [ ] Emoji mood picker
- [ ] Optionally link to streak/insight patterns
- [ ] Store to `daily_summaries.most_common_mood`

### 4. **InsightsScreen**
**Purpose:** Analytics & emotional intelligence dashboard

- [ ] Swears over time graph (7-day, mood breakdown)
- [ ] Top words by severity
- [ ] Mood → swearing correlation
- [ ] Worth it? % stats
- [ ] Pull data from `swear_logs`, `daily_summaries`

### 5. **UserProfileScreen**
**Purpose:** Manage profile, word list, settings

- [ ] Show `users` data (name, avatar, streak, etc.)
- [ ] Word list from `user_words` + `swear_dictionary`
- [ ] Fine settings, severity toggles
- [ ] Navigate to onboarding or export

### 6. **SettingsScreen**
**Purpose:** App-level preferences and backup/export

- [ ] Pull `user_settings`
- [ ] Toggle notifications, dark mode, reminders
- [ ] Trigger DB export/import functions
- [ ] Privacy toggle (share stats)

---

## 🧩 Supporting Features

### Authentication & Profiles
- [ ] Simple local profile creation (`users` table)
- [ ] Store current user session in iOS `UserDefaults`
- [ ] Support switching between multiple profiles

### OnboardingScreen
- [ ] Guided flow for new users
- [ ] Setup avatar, username, mood & word presets
- [ ] Create initial `users`, `user_words`, `user_settings`

### HistoryScreen
- [ ] Searchable list from `swear_logs`
- [ ] Filters by severity, mood, date
- [ ] Inline editing of log entries

### MindfulnessScreen
- [ ] Show suggestions based on mood/stress
- [ ] Breathing exercise animations
- [ ] Pull tips from static or embedded content

### StreakCelebrationScreen
- [ ] Triggered on clean streak milestones
- [ ] Confetti or animation + motivational quote

### DonationScreen
- [ ] Tally `users.total_fine`
- [ ] Allow user to connect with real donation link (external)

### AccountabilityScreen
- [ ] Show anonymized stats if enabled
- [ ] Option to invite accountability buddy (local only for MVP)

---

## 🗃️ Storage Layer Mapping (from SQLite backend)

| UI Feature | SQLite Table(s) |
|------------|------------------|
| User data | `users`, `user_settings` |
| Swear log | `swear_logs`, `swear_dictionary`, `user_words` |
| Trends | `daily_summaries`, `streak_history` |
| Emotional data | `swear_logs.mood`, `daily_summaries.most_common_mood` |
| Word list | `swear_dictionary`, `user_words` |
| Profile | `users`, `user_words`, `user_settings` |

---

## ✅ Development Priorities (iOS MVP Scope)

1. HomeScreen (SwiftUI)
2. LogSwearScreen + DB integration
3. SQLite DAO Layer in Swift
4. User Profile & Auth (UserDefaults)
5. Streak & Daily Summary Logic
6. Insights Dashboard (basic version)
7. Onboarding Flow
8. Settings Screen
9. Export/Import Support

---

## 📁 Project Structure (Swift/SwiftUI)

```
SwearJar/
├── App/
│   └── SwearJarApp.swift         # Main app entry point
├── Models/
│   ├── User.swift                # User model
│   ├── SwearWord.swift           # Swear word model (from swear_dictionary)
│   ├── UserWord.swift            # User's custom words
│   ├── SwearLog.swift            # Log entry model
│   ├── UserSettings.swift        # Settings model
│   ├── StreakHistory.swift       # Streak tracking model
│   └── DailySummary.swift        # Daily analytics model
├── Views/
│   ├── ContentView.swift         # Main tab container
│   ├── Home/
│   │   └── HomeView.swift        # Main dashboard
│   ├── LogSwear/
│   │   └── LogSwearView.swift    # Swear logging screen
│   ├── Insights/
│   │   └── InsightsView.swift    # Analytics dashboard
│   ├── Profile/
│   │   └── ProfileView.swift     # User profile screen
│   ├── Settings/
│   │   └── SettingsView.swift    # App settings
│   ├── Onboarding/
│   │   └── OnboardingView.swift  # First-time user experience
│   └── Components/               # Reusable UI components
│       ├── MoodPicker.swift
│       ├── StreakCounter.swift
│       └── ...
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── LogSwearViewModel.swift
│   ├── InsightsViewModel.swift
│   ├── ProfileViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── Database/
│   │   ├── DatabaseManager.swift # SQLite setup
│   │   └── Repositories/         # Data access layer
│   │       ├── UserRepository.swift
│   │       ├── SwearLogRepository.swift
│   │       └── ...
│   ├── StreakService.swift       # Streak calculation logic
│   └── BackupService.swift       # Export/import functionality
└── Utilities/
    ├── Extensions/               # Swift extensions
    └── Constants.swift           # App-wide constants
```

This structure follows the MVVM (Model-View-ViewModel) architecture pattern which works well with SwiftUI. It separates concerns and makes the codebase more maintainable and testable.

---

Let me know if you'd like a SwiftDAO layer scaffolding or an updated roadmap for the Android version.
