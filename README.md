# Finance Tracker

A personal finance tracking app built with Flutter. Tracks expenses, plans
monthly budgets, and visualises spending — all stored locally on device.

Built with AI-assisted development using Claude Code.

## Features

- **Expense tracking** — log expenses with 15 categories and financial type tags
  (asset / consumption / insurance)
- **Budget planning** — define monthly income and fixed costs; app calculates
  spendable budget automatically
- **Plan versioning** — recurring plan items track history via series IDs; edits
  create new versions from a chosen month
- **Reports** — monthly, yearly, and multi-year overview modes; pie charts by
  category with a financial type breakdown
- **Budget progress bar** — live remaining budget with over/under status per month
- **Save / load snapshots** — create up to 5 named local backups; restore any
  snapshot to replace live data
- **Period navigation** — consistent month/year navigation across all tabs with
  shared bounds derived from plan data
- **Welcome screen** — animated entry screen with coin toss interaction and
  haptic feedback

## Tech Stack

| Layer | Technology |
|---|---|
| UI framework | Flutter / Dart |
| Charts | fl_chart |
| Local storage | path_provider (JSON files) |
| Haptics | haptic_feedback |
| AI tooling | Claude Code |

## Project Structure

```
lib/
  main.dart           Entry point; wires repositories and launches app
  models/             Domain data classes and enums
  services/           Business logic, calculations, persistence
  screens/            Full-page UI (subfolders: plan/, reports/, income/, fixed_costs/)
  widgets/            Reusable UI components
  theme/              AppColors constants and buildAppTheme()

.claude/
  skills/             Project-specific Claude Code skill definitions
```

## Getting Started

**Requirements:** Flutter SDK, Android Studio or VS Code, Android/iOS SDK

```bash
# Check environment
flutter doctor

# Clone and enter project
git clone https://github.com/malymaros/finance_tracker.git
cd finance_tracker

# Install dependencies
flutter pub get

# Run
flutter run

# Analyze
flutter analyze

# Test
flutter test

# Build APK
flutter build apk
```

## Claude Code Skills

This project ships with skill definitions in `.claude/skills/` that guide
Claude Code's behaviour when working in this repository:

| Skill | Purpose |
|---|---|
| `architect` | Proposes architecture before implementation |
| `flutter-dev` | Implements Flutter code following project patterns |
| `git-commit-manager` | Manages safe, well-scoped commits |
| `tester` | Maintains test coverage |
| `code-reviewer` | Structured code reviews |
| `refactoring-guardian` | Safe refactors without behaviour changes |
| `ux-designer` | Reviews and improves interaction design |

## Development Philosophy

- Minimal dependencies — Flutter SDK first, packages only when clearly justified
- Business logic in services, never in widgets
- `setState` only — no Provider, Riverpod, or Bloc
- One widget/screen per file
- All colors and theme values centralised in `lib/theme/app_theme.dart`
