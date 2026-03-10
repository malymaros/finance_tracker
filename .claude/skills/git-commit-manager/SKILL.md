---
name: git-commit-manager
description: Safely manages Git commits and pushes for the repository. Use when the user asks to commit, stage, push, prepare a commit, finalize changes, or review repository changes before committing.
---

# Git Commit Manager

This skill manages **safe and professional Git commits** for the repository.

Its purpose is to ensure commits are **intentional, well-scoped, and clearly documented** before they are created or pushed.

This skill protects the **integrity and readability of project history**.

It never commits blindly and always performs repository inspection before committing.

--------------------------------------------------
WHEN TO USE THIS SKILL
--------------------------------------------------

Activate this skill when the user requests actions related to Git commits.

Typical trigger phrases include:

- commit
- commit changes
- commit and push
- push changes
- prepare commit
- create commit
- stage and commit
- finalize changes
- push to repository

If the user intent involves **committing or pushing code**, this skill must be used.

--------------------------------------------------
PRIMARY RESPONSIBILITIES
--------------------------------------------------

This skill must:

- inspect the repository state
- analyze staged and unstaged changes
- identify what actually changed
- detect suspicious or unrelated files
- propose a clean commit message
- confirm commit intent with the user
- create the commit
- push the commit to the correct remote branch

The goal is to protect the **quality and trustworthiness of repository history**.

--------------------------------------------------
MANDATORY WORKFLOW
--------------------------------------------------

When a commit request occurs, always follow this exact sequence:

1. run `git status`
2. inspect staged changes with `git diff --staged`
3. inspect unstaged changes with `git diff`
4. identify which files should be committed
5. summarize the changes
6. propose one or more commit message options
7. ask the user for explicit approval
8. after approval:
   - stage intended files
   - create the commit
   - push to `origin` on the current branch

Never skip this workflow.

--------------------------------------------------
COMMIT MESSAGE RULES
--------------------------------------------------

Commit messages must clearly describe the real scope of the change.

Avoid vague messages such as:

- update
- changes
- fix stuff
- wip
- misc

Prefer **conventional commit style** whenever possible:

- feat:
- fix:
- refactor:
- test:
- docs:
- chore:

Examples of good commit messages:

feat: add monthly budget progress calculation

fix: correct overspent calculation in report service

refactor: extract expense aggregation logic into report service

Examples of bad commit messages:

update code

changes

fix things

If multiple unrelated changes are detected, propose **splitting them into separate commits**.

--------------------------------------------------
CHANGE ANALYSIS
--------------------------------------------------

Before committing, analyze the scope of the changes.

Questions to evaluate:

- What functionality changed?
- Is the change a feature, fix, refactor, test, or documentation update?
- Are multiple logical changes mixed together?
- Are generated files accidentally included?

If the changes are unclear, explain the uncertainty before proposing a commit.

--------------------------------------------------
SAFETY RULES
--------------------------------------------------

Never blindly stage all files.

Inspect for suspicious or unintended files such as:

- build artifacts
- temporary files
- secrets
- credentials
- local configuration files
- generated platform files

Examples:

build/  
.env  
*.log  
temporary files  
IDE-generated files  

If such files appear, warn the user before committing.

--------------------------------------------------
PUSH POLICY
--------------------------------------------------

After a commit is successfully created:

- push to `origin` on the current branch
- if upstream is missing, push with `--set-upstream`
- never force push unless explicitly requested by the user

If the push fails:

- clearly explain the error
- suggest appropriate next steps

--------------------------------------------------
MERGE / REBASE SAFETY
--------------------------------------------------

Before committing, check for repository state issues such as:

- merge conflicts
- an ongoing rebase
- detached HEAD state

If any of these conditions are detected:

- stop the commit workflow
- report the issue to the user
- explain how it should be resolved

--------------------------------------------------
OUTPUT FORMAT
--------------------------------------------------

Before creating a commit, report:

1. repository status summary
2. list of files that changed
3. explanation of what changed
4. proposed commit message(s)
5. direct question asking for approval

Example:

Repository status summary:
modified: lib/services/report_service.dart

Files that changed:
- lib/services/report_service.dart

Explanation:
Added aggregation logic for monthly category grouping.

Proposed commit message:
feat: add monthly expense category aggregation

Proceed with this commit?

--------------------------------------------------
AFTER COMMIT
--------------------------------------------------

After the commit and push are complete, report:

1. the commit message used
2. the branch pushed to
3. the push result

Example:

Commit created:
feat: add monthly expense grouping in expenses tab

Pushed to:
origin/main

Push successful.

--------------------------------------------------
QUALITY BAR
--------------------------------------------------

A good commit must be:

- atomic
- descriptive
- intentional
- easy to understand in project history

Your responsibility is to maintain a **clean, safe, and trustworthy commit history**.