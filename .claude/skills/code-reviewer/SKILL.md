---
name: code-reviewer
description: Performs structured code reviews for the Finance Tracker Flutter application. Use when reviewing a pull request, commit, refactor, bug fix, or newly implemented feature. Detects logic errors, architectural violations, financial calculation mistakes, maintainability problems, missing tests, and performance risks.
---

# Finance Tracker Code Review Skill

This skill performs **careful code reviews** for the Finance Tracker Flutter application.

Its purpose is to detect correctness issues, architectural violations, maintainability problems, and potential regressions **before code is accepted into the codebase**.

This skill **does not rewrite the code unless explicitly asked**.
It produces structured review feedback.

---

# When To Use This Skill

Activate this skill when:

- new code has been implemented
- a feature has been added
- a bug fix was implemented
- a refactor was performed
- a pull request must be reviewed
- a commit must be reviewed
- the user asks for a code review
- multiple files were modified
- architectural layers may have been affected

---

# Project Context

Architecture pattern:

```
model → service → screen → widget
```

Layer rules:

- `models/` — domain data only; no logic
- `services/` — all business logic, calculations, aggregation
- `screens/` — orchestrate UI; call services; no calculations
- `widgets/` — render only; no business logic
- `theme/` — `AppColors` constants and `buildAppTheme()`; no inline Color values elsewhere

Actual services: `FinanceRepository`, `PlanRepository`, `BudgetCalculator`, `ReportAggregator`, `SaveLoadService`, `PeriodBoundsService`, `SeedData`.

State management: `setState` only. No Provider, Riverpod, Bloc, Redux.

---

# What To Review

### Correctness

- Does the code do what it claims?
- Are financial calculations correct?
- Are edge cases handled (zero amounts, empty lists, missing data)?
- Is period/month/year logic correct?
- Does serialisation/deserialisation handle all fields?

### Architecture

- Is business logic inside a widget? (violation)
- Is a screen performing calculations that belong in a service? (violation)
- Does a new model duplicate an existing concept? (violation)
- Is a phantom service or model name used that does not exist? (violation)
- Is `AppColors` used for all colors, or are raw `Color(...)` literals present in screens/widgets? (violation)

### Design System

- Are raw `Color(...)` literals or `Colors.*` values used instead of `AppColors` constants?
- Is `buildAppTheme()` bypassed with inline theme overrides in screens?
- Does new UI respect the navy/gold brand identity for chrome vs light body content?

### State Management

- Is `setState` used correctly without unnecessary full rebuilds?
- Is `ListenableBuilder` used where repository data drives rebuild?
- Are `ValueNotifier` / `ChangeNotifier` disposed properly?

### Code Quality

- Are variable and method names descriptive?
- Are magic numbers extracted as named constants?
- Are `const` constructors used where possible?
- Does `build()` stay under ~60 lines, or does it need extraction?
- Is logic duplicated that could be centralised?

### Safety

- Are async operations awaited correctly?
- Is `mounted` checked before `setState` in async callbacks?
- Are file/IO errors handled gracefully (especially in `SaveLoadService`)?
- Could a null value cause a crash?

### Tests

- Does changed behavior have corresponding test coverage?
- Are new services or calculations covered by unit tests?
- Would the tests catch a regression if this code changed?

---

# Review Checklist

Run through each item for every review:

- [ ] Business logic is in services, not widgets or screens
- [ ] No phantom model or service names invented
- [ ] No raw `Color(...)` literals in screens or widgets
- [ ] All colors reference `AppColors`
- [ ] `setState` / `ListenableBuilder` used appropriately
- [ ] `mounted` checked after all async gaps
- [ ] Financial calculations are correct and centralized
- [ ] Serialisation covers all model fields
- [ ] New behavior has test coverage
- [ ] `const` constructors used where applicable
- [ ] No unnecessary dividers, padding, or widget nesting

---

# Severity Levels

### Critical
Must be fixed before the code is accepted.

- incorrect financial calculation
- crash risk (null dereference, missing await, unhandled exception)
- data loss risk
- architectural violation (business logic in widget)
- missing `mounted` check after async gap

### Major
Should be fixed; may be deferred with justification.

- raw Color literals instead of AppColors
- phantom service/model name used
- duplicated logic that should be centralised
- missing test coverage for changed behavior
- unclear variable names that obscure intent

### Minor
Improvement suggestions; can be addressed in cleanup.

- style inconsistency
- unnecessary widget nesting
- `const` missing on a constructor
- verbose code that could be simplified

---

# Output Format

Structure all reviews as:

### Summary
One paragraph describing what was reviewed and the overall assessment.

### Critical Issues
List each issue with file, line reference, and explanation.

### Major Issues
List each issue with file, line reference, and explanation.

### Minor / Suggestions
List each item briefly.

### Test Coverage Assessment
State whether behavior changes are adequately covered.

### Verdict
One of: **Approved** / **Approved with minor notes** / **Changes requested**

---

# Final Rule

The reviewer's job is to protect correctness, architecture, and maintainability.

Raise issues clearly. Do not soften critical findings.

Do not rewrite code during a review unless explicitly asked.
