---
name: flutter-dev
description: Implements Flutter code for the Finance Tracker application. Use when writing or modifying Flutter code, implementing approved architecture, building screens or widgets, adding services or models, fixing bugs, or extending existing features.
---

# Finance Tracker Flutter Developer Skill

This skill implements **Flutter code** for the Finance Tracker application.

Its responsibility is to translate **approved architecture or feature plans into working Flutter code** that follows project structure, technical constraints, and architectural rules.

The implementation must be **clear, maintainable, predictable, and safe to integrate into the existing application**.

This skill focuses on **implementation**, not architectural design or code review.

--------------------------------------------------
WHEN TO USE THIS SKILL
--------------------------------------------------

Activate this skill when:

- a feature implementation is requested
- an approved architecture plan must be implemented
- Flutter UI code must be written
- a service or model must be created
- an existing feature must be extended
- a bug fix requires code changes
- navigation or screen behavior must be implemented
- a widget or screen must be added

If the task requires **writing or modifying Flutter code**, this skill must be used.

--------------------------------------------------
PROJECT CONTEXT
--------------------------------------------------

Application: Finance Tracker

Purpose:

A personal finance tracking application focused on:

- expenses
- income
- fixed costs
- financial plans
- spending reports
- budgeting

Primary platform:
Android

Secondary platform:
iOS

The application prioritizes:

- clarity of financial information
- responsive UI
- predictable interaction
- maintainable code structure

--------------------------------------------------
ARCHITECTURE OVERVIEW
--------------------------------------------------

The application follows a lightweight layered architecture.

Folder structure:

lib/
  main.dart
  models/
  services/
  screens/
  widgets/

Layer responsibilities:

models/
Domain data classes.

services/
Business logic and calculations.

screens/
Full-page widgets that orchestrate UI behavior.

widgets/
Reusable UI components.

Data flow pattern:

model → service → screen → widget

Services prepare data.  
Screens coordinate UI behavior.  
Widgets render UI.

Business logic must not live inside UI widgets.

--------------------------------------------------
STATE MANAGEMENT RULE
--------------------------------------------------

State management must use:

setState only.

Do NOT introduce:

- Provider
- Riverpod
- Bloc
- Redux
- other state management libraries

Unless explicitly approved.

--------------------------------------------------
DEPENDENCY RULE
--------------------------------------------------

Do not introduce external packages unless explicitly approved.

Prefer solutions using only:

- Flutter SDK
- Dart standard library

--------------------------------------------------
IMPLEMENTATION PRINCIPLES
--------------------------------------------------

Code must prioritize:

- readability
- predictability
- maintainability
- separation of concerns
- testability

Never implement shortcuts that create technical debt.

--------------------------------------------------
WIDGET DESIGN RULES
--------------------------------------------------

Prefer:

StatelessWidget whenever possible.

Use StatefulWidget only when:

- local mutable UI state is required
- UI interactions depend on temporary screen state

Rules:

- keep build() methods short
- extract large sections into widgets
- avoid deep layout nesting
- reuse widgets when UI patterns repeat
- use const constructors when possible

If build() exceeds roughly 40–60 lines, consider extraction.

--------------------------------------------------
UI LOGIC RULES
--------------------------------------------------

Widgets should primarily:

- render data
- trigger user actions

Widgets should NOT contain:

- financial calculations
- aggregation logic
- filtering logic
- report calculations
- category grouping logic
- budget calculations

Move such logic to services.

--------------------------------------------------
DOMAIN MODEL RULE
--------------------------------------------------

Before implementing UI features, ensure the domain model exists.

Typical implementation order:

1. model
2. service
3. screen
4. widgets
5. routing updates

Never start with UI if the domain model is missing.

--------------------------------------------------
SERVICE RULES
--------------------------------------------------

Services contain:

- business logic
- calculations
- aggregation
- filtering
- domain rules

Examples:

- ExpenseService
- FinancialPlanService
- ReportService
- PeriodService
- ImportService

Services must return clean data structures that screens can render.

--------------------------------------------------
NAVIGATION RULES
--------------------------------------------------

Use standard Flutter navigation.

Preferred pattern:

Navigator.push(
  context,
  MaterialPageRoute(...)
)

Avoid complex routing frameworks unless approved.

--------------------------------------------------
COMMON UI PATTERNS
--------------------------------------------------

Empty state pattern:

Centered Column
- icon
- headline text
- supporting text

Lists:

Use ListView.separated with Divider.

Primary action:

FloatingActionButton with Icons.add.

Forms:

Prefer bottom sheets for quick input when appropriate.

--------------------------------------------------
CODE QUALITY RULES
--------------------------------------------------

Follow these coding rules:

- use descriptive variable names
- avoid magic numbers
- extract constants where appropriate
- avoid duplicated logic
- maintain consistent naming conventions

Private widget builders:

_buildExpenseRow()
_buildBudgetSummary()

--------------------------------------------------
IMPLEMENTATION WORKFLOW
--------------------------------------------------

When implementing a feature:

1. read relevant existing files
2. understand how the feature integrates with existing services
3. check whether the model already supports the feature
4. extend models/services if necessary
5. implement screen logic
6. implement reusable widgets
7. update navigation if needed
8. ensure code follows project structure

Do not modify unrelated parts of the codebase.

--------------------------------------------------
SAFETY RULES
--------------------------------------------------

Before completing implementation:

- ensure business logic is not inside widgets
- ensure widgets remain readable
- ensure services remain focused
- avoid introducing architectural inconsistencies

If the implementation conflicts with architecture rules, stop and ask for clarification.

--------------------------------------------------
COLLABORATION WITH OTHER SKILLS
--------------------------------------------------

Architect Skill  
Used before implementing large or structural features.

Tester Skill  
Must be invoked after implementing functionality that changes behavior.

Refactoring Skill  
Should be considered if implementation increases complexity.

Code Reviewer Skill  
Validates correctness after implementation.

UX Designer Skill  
Improves interaction design after structure is defined.

--------------------------------------------------
OUTPUT FORMAT
--------------------------------------------------

When implementing code changes, report:

1. files created or modified
2. purpose of each change
3. how the feature integrates with existing services
4. any architectural considerations

Explain non-obvious design decisions briefly.

--------------------------------------------------
FINAL RULE
--------------------------------------------------

This skill implements working Flutter code that follows project architecture and technical rules.

If architectural uncertainty exists, request clarification from the Architect skill before implementing.