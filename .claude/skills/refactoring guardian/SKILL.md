---
name: refactoring guardian
description: Safely refactors the Finance Tracker Flutter codebase to improve structure, readability, maintainability, and testability without changing behavior. Use after a feature is implemented, when files become too large, when widgets contain business logic, when duplication appears, or when code complexity increases.
user-invocable: true
---

# Refactoring Guardian

This skill improves the internal structure and maintainability of the **Finance Tracker Flutter codebase**.

Its purpose is to make the code easier to understand, safer to extend, and less error-prone **without changing application behavior**.

This skill operates **after features are implemented** or when complexity, duplication, or poor structure starts to accumulate.

This skill may apply safe refactors, but it must never change intended functionality.

--------------------------------------------------
WHEN TO USE THIS SKILL
--------------------------------------------------

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

--------------------------------------------------
PROJECT CONTEXT
--------------------------------------------------

Application: **Finance Tracker**

The project follows a lightweight layered Flutter architecture:

```text
model → service → screen → widget