---
name: refactoring guardian
description: Safely refactors the Finance Tracker Flutter codebase to improve structure, readability, maintainability, and testability without changing behavior. Use after a feature is implemented, when files become too large, when widgets contain business logic, when duplication appears, or when code complexity increases.
user-invocable: true
---

# Refactoring Guardian

This skill improves the internal structure and maintainability of the **Finance Tracker Flutter codebase**.

Its purpose is to make the code easier to understand, safer to extend, and less error-prone **without changing application behavior**.

This skill operates **after features are implemented** or when complexity, duplication, or poor structure starts to accumulate.

This skill may apply safe refactors, but it must **never change intended functionality**.

---

# When To Use This Skill

Activate this skill when:

- a feature has just been implemented
- a file has grown significantly in size
- a widget `build()` method becomes too large or deeply nested
- business logic appears inside UI widgets
- repeated UI structures appear
- services accumulate multiple responsibilities
- a bug fix introduces messy or temporary code
- calculation logic becomes duplicated
- period, report, or budget logic spreads across multiple places
- naming becomes unclear or inconsistent
- testability of a component becomes difficult
- the user explicitly asks for refactoring or cleanup

If a change increases complexity, refactoring should be considered.

---

# Project Context

Application: **Finance Tracker**

Architecture:

```
model → service → screen → widget
```

Layer rules:

- `models/` — domain data only
- `services/` — all business logic; `FinanceRepository`, `PlanRepository`, `BudgetCalculator`, `ReportAggregator`, `SaveLoadService`, `PeriodBoundsService`
- `screens/` — orchestrate UI behavior
- `widgets/` — render only
- `theme/` — `AppColors` and `buildAppTheme()`

State: `setState` only. No Provider, Riverpod, Bloc.

---

# Refactoring Rules

### What Is Safe To Refactor

- Extract large `build()` methods into private widget builders or separate widgets
- Move business logic from widgets/screens into appropriate services
- Rename unclear variables, methods, or classes
- Extract duplicated UI patterns into reusable widgets
- Extract duplicated calculation logic into static service methods
- Replace magic numbers with named constants
- Replace raw `Color(...)` literals with `AppColors` constants
- Add `const` to constructors that qualify
- Split large files with mixed responsibilities

### What Must Not Change

- Observable behavior visible to the user
- Financial calculation results
- Navigation flow
- State management approach (keep `setState`)
- Data persistence format (JSON schema compatibility)
- Public API of models and services

---

# Refactoring Targets

### Widget Too Large
If `build()` exceeds ~60 lines:
- extract sections into private `_buildXxx()` methods
- extract self-contained sections into separate `StatelessWidget` classes

### Business Logic in Widget
Move to the appropriate service:
- financial calculations → `BudgetCalculator`
- aggregation/grouping → `ReportAggregator`
- period bounds → `PeriodBoundsService`
- data mutations → `FinanceRepository` or `PlanRepository`

### Duplicated UI Pattern
Extract into a shared widget in `lib/widgets/`.

### Raw Color Literals
Replace all `Color(0xFF...)`, `Colors.green`, `Colors.red`, `Colors.grey` in screens/widgets with `AppColors` constants.

### Duplicated Calculation
Centralise in the appropriate pure static service.

---

# Safety Rules

Before applying any refactor:

1. Read the file being refactored
2. Understand what the code currently does
3. Confirm behavior will not change
4. Check for existing tests that cover the code
5. Run `flutter analyze` after the refactor
6. Run `flutter test` after the refactor
7. If tests fail, the refactor introduced a regression — fix it or revert

Never refactor and add features simultaneously. Keep the scope to structural improvements only.

---

# Workflow

When this skill is invoked:

1. read the relevant source files
2. identify structural problems (duplication, size, logic placement)
3. propose specific refactors with justification
4. ask for confirmation before applying
5. apply refactors one logical group at a time
6. run `flutter analyze` — must be clean
7. run `flutter test` — must pass
8. report what changed and why

---

# Output Format

Report:

1. **Files reviewed** — list of files inspected
2. **Problems found** — each issue with type (duplication / size / logic placement / naming)
3. **Proposed refactors** — specific changes, one per item
4. **Changes applied** — what was actually changed
5. **Analyze result** — output of `flutter analyze`
6. **Test result** — output of `flutter test`

---

# Quality Bar

A good refactor:

- leaves behavior identical
- makes the code easier to read and understand
- makes the code easier to test
- makes future changes safer
- passes all existing tests without modification

If tests need to be rewritten to accommodate a refactor, the refactor likely changed behavior. Stop and investigate.
