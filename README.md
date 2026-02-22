# Intermittent Fasting Timer

A premium, offline-first intermittent fasting timer built with Flutter. Track your fasts, monitor streaks, and share achievements — all with a beautiful dark-themed UI.

## Features

- **Multiple Fasting Plans** — 12:12, 16:8, 18:6, 20:4, OMAD, and Custom plans
- **Live Countdown Timer** — Animated circular progress ring with gradient effects and glow
- **Streak Tracking** — Current streak, longest streak, and total fasts at a glance
- **Fasting History** — Weekly heatmap calendar and detailed session log
- **Share Cards** — Generate and share beautiful achievement cards on social media
- **Local Notifications** — Get notified when your fast is complete
- **Confetti Celebration** — Visual celebration on fast completion
- **Offline Storage** — All data persisted locally with Hive (no account required)
- **Premium Plans** — In-app purchase ready architecture for advanced plans
- **Ad Placeholders** — Rewarded ads and interstitial ad integration points

## Screenshots

| Home | Timer | History | Settings |
|------|-------|---------|----------|
| Plan selection & streak badge | Live countdown with progress ring | Weekly heatmap & session log | Preferences & premium upgrade |

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x (Dart 3.x) |
| State Management | Riverpod |
| Navigation | Go Router (ShellRoute) |
| Local Storage | Hive + Hive Flutter |
| Notifications | Flutter Local Notifications |
| Charts | FL Chart |
| Sharing | Share Plus + Screenshot |
| Fonts | Google Fonts |
| Animations | Confetti, TweenAnimationBuilder |

## Project Structure

```
lib/
├── app/
│   ├── app.dart              # App entry widget
│   ├── router.dart           # Go Router configuration
│   └── theme.dart            # Dark theme & color palette
├── core/
│   ├── constants.dart        # Fasting plans & app constants
│   └── utils.dart            # Utility functions
├── models/
│   ├── fasting_plan.dart     # Fasting plan model
│   ├── fasting_session.dart  # Fasting session model
│   └── user_settings.dart    # User settings model
├── providers/
│   ├── history_provider.dart # History state management
│   ├── settings_provider.dart# Settings state management
│   └── timer_provider.dart   # Timer state management
├── screens/
│   ├── home_screen.dart      # Plan selection & start fast
│   ├── timer_screen.dart     # Active timer & completion view
│   ├── history_screen.dart   # Stats grid & session history
│   └── settings_screen.dart  # Preferences & premium
├── services/
│   ├── notification_service.dart # Local notifications
│   ├── share_service.dart    # Share card generation
│   └── storage_service.dart  # Hive storage layer
├── widgets/
│   ├── bottom_nav.dart       # Bottom navigation shell
│   ├── circular_progress.dart# Animated progress ring
│   ├── fasting_share_card.dart# Share card widget
│   ├── plan_card.dart        # Plan selection card
│   ├── stat_card.dart        # Statistics card
│   └── streak_badge.dart     # Streak display badge
└── main.dart                 # App bootstrap
```

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Dart SDK 3.2.0 or higher
- Android Studio (for Android) or Xcode (for iOS)

### Installation

```bash
# Clone the repository
git clone https://github.com/MudassarHakim/intermittent_fasting.git
cd intermittent_fasting

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires Xcode)
flutter build ios --release

# Web
flutter build web --release
```

## Fasting Plans

| Plan | Fast | Eat | Level |
|------|------|-----|-------|
| 12:12 Circadian | 12h | 12h | Beginner |
| 16:8 Lean Gains | 16h | 8h | Intermediate |
| 18:6 Warrior Lite | 18h | 6h | Intermediate |
| 20:4 Warrior | 20h | 4h | Advanced (Premium) |
| OMAD (23:1) | 23h | 1h | Advanced (Premium) |
| Custom | User-defined | User-defined | Premium |

## Architecture

- **State Management** — Riverpod providers for reactive, testable state
- **Navigation** — Go Router with ShellRoute for persistent bottom navigation
- **Storage** — Hive NoSQL database for fast offline reads/writes
- **Theming** — Custom dark theme with gradient accents and glassmorphism effects
- **Notifications** — Timezone-aware local notifications for fast completion alerts

## License

This project is licensed under the MIT License.
