# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter analyze          # Static analysis (flutter_lints ruleset)
flutter test             # Run all tests
flutter test test/foo_test.dart  # Run a single test file
flutter build apk        # Build Android APK
```

Hot reload is available during `flutter run` — press `r` in the terminal or save in VS Code.

## Architecture

This is a Flutter/Dart mobile app targeting Android (and iOS). Currently in early development — `lib/main.dart` contains the default Flutter counter scaffold.

Planned structure per README:
```
lib/
  main.dart       # App entry point, MaterialApp root
  screens/        # Full-page widgets (one file per screen)
  widgets/        # Reusable UI components
  models/         # Data models (e.g. Expense)
  services/       # Business logic, data access
```

Planned features: expense entry, listing, monthly overview, categories, charts, shared tracking, CSV export.

Future planned dependencies (not yet added): local DB (Hive or SQLite), REST backend, cloud sync.

## Key Details

- Dart SDK: `^3.11.1`
- Linting: `flutter_lints` — enforced via `analysis_options.yaml`; run `flutter analyze` before committing
- No state management library yet — use `setState` for now until one is chosen
- No local DB yet — data is in-memory until a persistence layer is added