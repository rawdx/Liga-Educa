# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
flutter pub get                              # Install dependencies
flutter run                                  # Run in debug mode
flutter build apk                            # Build Android APK
flutter build ios                            # iOS build
dart analyze                                 # Run code analysis (flutter_lints)
flutter test                                 # Run tests
flutter pub run flutter_launcher_icons       # Regenerate app icons
flutter pub run flutter_native_splash:create # Regenerate splash screen
```

## Architecture Overview

Liga Educa is a Flutter mobile app for a youth sports league, displaying competitions, news, and team information.

### Core Patterns

- **Navigation**: GoRouter with StatefulShellRoute (5 branches: Home, Competitions, News, Values, Profile). Routes defined in `lib/nav.dart` with custom fade+slide transitions for detail pages.
- **Data Layer**: JSON-based services with singleton pattern. `CompetitionsService` and `PhrasesService` load from `assets/data/*.json` and cache in memory.
- **Theming**: Material Design 3 with custom system in `lib/theme.dart`. Uses `AppSpacing`, `AppRadius`, and `AppColors` constants. Inter font via Google Fonts. Dark theme only (hardcoded).
- **Drawer Coordination**: Global `DrawerManager` (ChangeNotifier) coordinates drawer state across pages.

### Directory Structure

```
lib/
├── main.dart           # App entry, MaterialApp.router setup
├── nav.dart            # GoRouter configuration, all routes
├── theme.dart          # Colors, spacing, radius, typography
├── drawer_manager.dart # Global drawer state
├── models/             # Data classes (CompetitionSummary, MatchResult, StandingRow, Phrase)
├── services/           # Data loading services (singleton pattern)
├── pages/              # Screen components (10 pages)
└── widgets/            # Reusable UI (AppShell, LeagueAppBar, LeagueCard, NewsCard, SponsorFooter)

assets/
├── data/               # JSON data files (competitions, teams, matches, phrases)
├── images/             # Logos, team images, splash, sponsor GIF
└── icons/
```

### Key Navigation Patterns

- Use `context.go('/path')` for navigation
- Use `navigationShell.goBranch(index)` for bottom nav tab switches
- Competition detail: `/competitions/detail/:competitionId`
- News detail: `/home/news-detail` or `/news/detail` (both work)

### Data Models

- `CompetitionSummary`: Competition metadata (id, category, seasonLabel, groupLabel)
- `MatchResult`: Match with teams, score, status (0=Pending, 1=Finished, 2=Suspended, 3=Postponed)
- `StandingRow`: League table entry with stats
- `CompetitionDetailData`: Full view combining results, standings, next matchday

### Dependencies

- `go_router: ^17.0.1` - Routing
- `provider: ^6.1.2` - State management
- `google_fonts: ^8.0.0` - Typography
- `flutter_svg: ^2.2.3` - SVG support
- `url_launcher: ^6.3.2` - External links
