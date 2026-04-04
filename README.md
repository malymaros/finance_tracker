# Finance Tracker

A personal finance tracking app built with Flutter. Tracks expenses, plans
monthly budgets, and visualises spending — all stored locally on device.

Built with AI-assisted development using Claude Code.

## Features

- **Expense tracking** — log expenses with 17 categories and financial type tags
  (asset / consumption / insurance)
- **Budget planning** — define monthly income and fixed costs; app calculates
  spendable budget automatically; fixed costs grouped by financial type in
  collapsible accordions with category drill-down
- **Category budgets** — set monthly spending limits per category; progress bars
  in category view; warning card in items view when limits are exceeded;
  full version history (budgets can change from a given month)
- **GUARD** — mark fixed-cost plan items as guarded; app tracks payment status
  per month and sends local push notification reminders on a configurable schedule
- **Guided add flow** — type-selector bottom sheet before plan item forms ensures
  Income vs Fixed Cost is chosen explicitly before filling any fields
- **Plan versioning** — recurring plan items and category budgets track history
  via series IDs; edits create new versions from a chosen month
- **Reports** — monthly, yearly, and multi-year overview modes; pie charts by
  category; drill-down into category detail showing fixed costs and expenses
- **PDF export** — generate and share monthly or yearly PDF reports
- **Import** — import expenses from xlsx or csv files with a preview-and-edit step
  before committing
- **Budget progress bar** — live remaining budget with over/under status per month
- **Save / load snapshots** — create up to 3 named local backups and restore
  from them; automatic daily rotation keeps a Primary and Secondary backup
  updated in the background without user action
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
| PDF generation | pdf + share_plus |
| Import (xlsx/csv) | excel + file_picker |
| Notifications | flutter_local_notifications |
| Preferences | shared_preferences |
| AI tooling | Claude Code |

## Project Structure

```
lib/
  main.dart           Entry point; wires repositories and launches app
  models/             Domain data classes and enums
  services/           Business logic, calculations, persistence
  screens/            Full-page UI (subfolders: plan/, reports/)
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
| `refactoring guardian` | Safe refactors without behaviour changes |
| `ux-designer` | Reviews and improves interaction design |

## Development Philosophy

- Minimal dependencies — Flutter SDK first, packages only when clearly justified
- Business logic in services, never in widgets
- `setState` only — no Provider, Riverpod, or Bloc
- One widget/screen per file
- All colors and theme values centralised in `lib/theme/app_theme.dart`
