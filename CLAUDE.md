# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

Claude should follow the architectural rules and development workflow defined here.

--------------------------------------------------
PROJECT OVERVIEW
--------------------------------------------------

Finance Tracker is a Flutter mobile application for tracking personal expenses.

Primary goal:
Build a simple, fast, and clean mobile application that allows users to record expenses quickly and analyze spending habits.

The project intentionally explores AI-assisted development using Claude Code.

Target platforms:
- Android (primary)
- iOS (secondary)

--------------------------------------------------
DEVELOPMENT PRIORITIES
--------------------------------------------------

When implementing features, prioritize:

1. Simplicity
2. Readability
3. Small reusable widgets
4. Clear folder structure
5. Minimal dependencies

Avoid overengineering.

Do not introduce complex architecture patterns unless necessary.

--------------------------------------------------
PROJECT STRUCTURE
--------------------------------------------------

Code should follow this structure:

lib/
  main.dart
  screens/
  widgets/
  models/
  services/

screens/
Full-page UI components.

Example:
ExpenseListScreen
AddExpenseScreen

widgets/
Reusable UI components.

Example:
ExpenseCard
ExpenseListTile

models/
Data models.

Example:
Expense

services/
Business logic and data access.

Example:
ExpenseService
StorageService

--------------------------------------------------
CODING RULES
--------------------------------------------------

Follow Flutter best practices.

Rules:

- Keep widgets small
- Prefer StatelessWidget where possible
- Extract reusable UI into widgets
- Avoid deeply nested widgets
- Keep business logic out of UI files

File guidelines:

One main widget per file.

Example:

ExpenseListScreen.dart

--------------------------------------------------
STATE MANAGEMENT
--------------------------------------------------

Current approach:

Use `setState`.

Do NOT introduce:

- Riverpod
- Bloc
- Provider

until the project complexity requires it.

--------------------------------------------------
DATA STORAGE
--------------------------------------------------

Current state:

In-memory data only.

Future persistence options:

- Hive
- SQLite

Do not introduce a database yet unless explicitly requested.

--------------------------------------------------
DEPENDENCY RULES
--------------------------------------------------

Before adding a new dependency:

- explain why it is needed
- check if Flutter SDK already provides similar functionality
- keep dependency count minimal

--------------------------------------------------
COMMANDS
--------------------------------------------------

Install dependencies

flutter pub get

Run application

flutter run

Static analysis

flutter analyze

Run tests

flutter test

Build Android APK

flutter build apk

--------------------------------------------------
HOT RELOAD
--------------------------------------------------

During development:

Press `r` in the terminal or save the file in VS Code.

--------------------------------------------------
TESTING
--------------------------------------------------

When adding logic:

- add unit tests when appropriate
- place tests inside the `test/` directory

Example:

test/expense_service_test.dart

--------------------------------------------------
WHEN IMPLEMENTING FEATURES
--------------------------------------------------

Follow this order:

1. Define model
2. Implement UI
3. Add logic/service
4. Add persistence (later)

--------------------------------------------------
EXPECTED FIRST FEATURES
--------------------------------------------------

1. Expense model
2. Expense list screen
3. Add expense form
4. Basic local state management

--------------------------------------------------
GENERAL GUIDELINES FOR CLAUDE
--------------------------------------------------

Before making large changes:

- analyze the existing structure
- keep code consistent with existing patterns
- prefer incremental changes

If unsure about architecture decisions:

propose a plan before implementing.