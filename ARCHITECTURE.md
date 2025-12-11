# FitMix PWA - Project Architecture

## Project Overview
FitMix PWA is a Flutter-based Progressive Web Application for fitness tracking and workout management. The project follows a clean architecture pattern with clear separation of concerns.

## Directory Structure

```
fitmix_pwa/
├── .dart_tool/                    # Dart build artifacts and cache
├── .github/
│   └── workflows/
│       └── pages.yml              # GitHub Pages deployment workflow
├── .vscode/                       # VS Code settings
├── assets/                        # Static assets
│   ├── audio/                     # Audio files
│   ├── data/
│   │   └── exercises.json         # Exercise database
│   ├── fonts/
│   │   ├── Pretendard-Bold.otf
│   │   └── Pretendard-Regular.otf
│   ├── icons/                     # SVG icons
│   │   ├── ic_analysis.svg
│   │   ├── ic_arrow_right.svg
│   │   ├── ic_calendar.svg
│   │   ├── ic_close.svg
│   │   ├── ic_home.svg
│   │   ├── ic_info.svg
│   │   ├── ic_library.svg
│   │   ├── ic_logout.svg
│   │   ├── ic_person.svg
│   │   ├── ic_settings.svg
│   │   ├── ic_theme.svg
│   │   ├── ic_tv.svg
│   │   └── ic_warning.svg
│   ├── sounds/                    # Sound effects
│   └── presets.json               # Preset configurations
├── build/                         # Build output (generated)
├── doc/                           # Documentation
│   ├── final_summary.md
│   ├── i18n_guideline.md
│   ├── i18n_migration_report.md
│   ├── project_status.md
│   ├── todo.md
│   ├── youtube_style_bottom_nav.md
│   ├── youtube_style_refactoring_summary.md
│   └── youtube_style_settings.md
├── lib/                           # Main application code
│   ├── core/                      # Core utilities and configurations
│   │   ├── burn_fit_style.dart    # App styling constants
│   │   ├── calendar_config.dart   # Calendar configuration
│   │   ├── constants.dart         # Global constants
│   │   ├── error_handler.dart     # Error handling utilities
│   │   ├── feature_flags.dart     # Feature flag management
│   │   ├── l10n_extensions.dart   # Localization extensions
│   │   └── theme_notifier.dart    # Theme state management
│   ├── data/                      # Data layer - repositories
│   │   ├── auth_repo.dart         # Authentication repository
│   │   ├── exercise_library_repo.dart  # Exercise library repository
│   │   ├── session_repo.dart      # Workout session repository
│   │   ├── settings_repo.dart     # User settings repository
│   │   └── user_repo.dart         # User profile repository
│   ├── l10n/                      # Localization (i18n)
│   │   ├── app_en.arb             # English translations
│   │   ├── app_ja.arb             # Japanese translations
│   │   ├── app_ko.arb             # Korean translations
│   │   ├── app_localizations.dart # Generated localizations
│   │   ├── app_localizations_en.dart
│   │   ├── app_localizations_ja.dart
│   │   └── app_localizations_ko.dart
│   ├── models/                    # Data models
│   │   ├── exercise.dart          # Exercise model
│   │   ├── exercise.g.dart        # Generated code for Exercise
│   │   ├── exercise_db.dart       # Exercise database model
│   │   ├── exercise_set.dart      # Exercise set model
│   │   ├── exercise_set.g.dart    # Generated code for ExerciseSet
│   │   ├── session.dart           # Workout session model
│   │   ├── session.g.dart         # Generated code for Session
│   │   ├── user_profile.dart      # User profile model
│   │   └── user_profile.g.dart    # Generated code for UserProfile
│   ├── pages/                     # UI pages/screens
│   │   ├── analysis_page.dart     # Workout analysis page
│   │   ├── calendar_page.dart     # Calendar view page
│   │   ├── home_page.dart         # Home page
│   │   ├── library_page.dart      # Exercise library (v1)
│   │   ├── library_page_v2.dart   # Exercise library (v2)
│   │   ├── login_page.dart        # Login page
│   │   ├── plan_page.dart         # Workout plan page
│   │   ├── profile_page.dart      # User profile page
│   │   ├── settings_page.dart     # Settings page
│   │   ├── shell_page.dart        # Main shell/navigation page
│   │   ├── splash_page.dart       # Splash screen
│   │   ├── upgrade_page.dart      # Upgrade/premium page
│   │   ├── user_info_form_page.dart  # User info form
│   │   ├── voice_recorder_page.dart  # Voice recording page
│   │   └── workout_page.dart      # Workout execution page
│   ├── services/                  # Business logic services
│   │   ├── audio_recorder_service.dart  # Audio recording service
│   │   ├── exercise_db_service.dart     # Exercise database service
│   │   ├── rhythm_engine.dart           # Rhythm/timing engine
│   │   └── tempo_metronome_service.dart # Metronome service
│   ├── utils/                     # Utility functions
│   │   └── dummy_data_generator.dart    # Test data generation
│   ├── widgets/                   # Reusable UI components
│   │   ├── calendar/              # Calendar-related widgets
│   │   │   ├── calendar_modal_sheet.dart
│   │   │   ├── day_timeline_list.dart
│   │   │   ├── month_header.dart
│   │   │   └── week_strip.dart
│   │   ├── common/                # Common/shared widgets
│   │   │   ├── fm_app_bar.dart    # Custom app bar
│   │   │   ├── fm_bottom_nav.dart # Custom bottom navigation
│   │   │   └── fm_section_header.dart  # Section header widget
│   │   ├── exercise_set_card.dart
│   │   ├── exercise_set_card_demo.dart
│   │   ├── goal_card.dart
│   │   ├── rest_timer_bar.dart
│   │   ├── set_input_card.dart
│   │   ├── summary_chart.dart
│   │   └── tempo_settings_modal.dart
│   └── main.dart                  # Application entry point
├── scripts/                       # Utility scripts
│   ├── fetch_exercises.dart       # Script to fetch exercises
│   ├── fetch_free_exercises.dart  # Script to fetch free exercises
│   └── README.md
├── test/                          # Unit and integration tests
│   ├── calendar_config_test.dart
│   └── session_repo_test.dart
├── web/                           # Web-specific files
│   ├── icons/                     # Web app icons
│   │   ├── Icon-192.png
│   │   ├── Icon-512.png
│   │   ├── Icon-maskable-192.png
│   │   └── Icon-maskable-512.png
│   ├── favicon.png
│   ├── index.html                 # Web entry point
│   └── manifest.json              # PWA manifest
├── .flutter-plugins-dependencies  # Flutter plugins metadata
├── .gitignore                     # Git ignore rules
├── .metadata                      # Flutter metadata
├── analysis_options.yaml          # Dart analysis configuration
├── l10n.yaml                      # Localization configuration
├── pubspec.lock                   # Locked dependency versions
├── pubspec.yaml                   # Project dependencies and metadata
└── README.md                      # Project README
```

## Architecture Layers

### 1. Presentation Layer (pages/ & widgets/)
- **Pages**: Full-screen UI components representing different routes
- **Widgets**: Reusable UI components used across pages
- Handles user interactions and displays data

### 2. Business Logic Layer (services/)
- **AudioRecorderService**: Manages audio recording functionality
- **ExerciseDbService**: Handles exercise database operations
- **RhythmEngine**: Manages workout rhythm and timing
- **TempoMetronomeService**: Provides metronome functionality

### 3. Data Layer (data/)
- **Repositories**: Abstract data access patterns
  - AuthRepo: Authentication operations
  - ExerciseLibraryRepo: Exercise library data
  - SessionRepo: Workout session data
  - SettingsRepo: User settings
  - UserRepo: User profile data

### 4. Domain Layer (models/)
- **Data Models**: Core business entities
  - Exercise: Individual exercise definition
  - ExerciseSet: Set of exercises
  - Session: Workout session
  - UserProfile: User information

### 5. Core Layer (core/)
- **Configuration**: App-wide settings and constants
- **Theme Management**: Theme state and styling
- **Localization**: Multi-language support
- **Error Handling**: Centralized error management
- **Feature Flags**: Feature toggle management

## Key Features

### Internationalization (i18n)
- Supports English, Japanese, and Korean
- ARB files for translation management
- Auto-generated localization classes

### Localization (l10n)
- Calendar configuration for different regions
- Date/time formatting based on locale

### State Management
- Theme state via ThemeNotifier
- Feature flags for gradual rollouts

### UI Components
- Custom app bar (fm_app_bar)
- Custom bottom navigation (fm_bottom_nav)
- Calendar widgets for date selection
- Exercise set cards for workout display
- Rest timer bar for interval tracking

## Build & Deployment

### Build Artifacts
- `build/`: Generated build output
- `.dart_tool/`: Dart compilation cache

### Web Deployment
- `web/index.html`: Web entry point
- `web/manifest.json`: PWA manifest
- GitHub Pages workflow: `.github/workflows/pages.yml`

## Configuration Files

- `pubspec.yaml`: Project dependencies and metadata
- `analysis_options.yaml`: Dart linter configuration
- `l10n.yaml`: Localization settings
- `.vscode/settings.json`: VS Code workspace settings

## Testing

- Unit tests in `test/` directory
- Test coverage for calendar config and session repository
- Integration test support via Flutter testing framework

## Documentation

- `doc/`: Project documentation
  - Architecture decisions
  - Internationalization guidelines
  - Feature implementation guides
  - Project status and roadmap
