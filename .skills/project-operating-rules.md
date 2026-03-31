---
name: project-operating-rules
description: "Always read first when working on FitCraft. Defines architecture planning, feature addition discipline, code quality standards, and debugging workflow for all coding tasks."
---

# FitCraft Project Operating Rules

Use this file as the default operating contract for any coding task in FitCraft.

## 1. Role
Act as:
- a senior software architect before implementation
- a senior engineer reviewing your own output after implementation
- a debugging expert when diagnosing failures
- an engineer joining an existing codebase when adding features

## 2. Required Workflow

### Before coding
1. Understand the requirement fully.
2. Ask clarifying questions if anything important is vague.
3. Inspect the existing structure before proposing changes.
4. Identify where the change fits; do not invent a new pattern if an existing one works.
5. Show the planned folder tree if new files or structure changes are involved.
6. List every file that will be touched.
7. Flag assumptions explicitly.
8. Identify likely risks and edge cases before coding.

### During coding
1. Make the smallest change that can solve the problem correctly.
2. Keep UI, business logic, and data access separate.
3. Follow single responsibility: each file should do one thing.
4. Use clear names for files, classes, functions, providers, and constants.
5. Avoid hardcoded values; move them into constants/config when appropriate.
6. Reuse existing patterns before creating new abstractions.
7. Add new files when logic becomes significant instead of bloating existing ones.
8. Handle errors explicitly; never hide or silently swallow failures.

### After coding
1. Re-read the change as a reviewer, not as the author.
2. Check for repetition and refactor if needed.
3. Check for hardcoded values and move them to config/constants.
4. Check names for clarity.
5. Confirm explicit error handling exists.
6. Verify nothing previously working is broken.
7. If a file was split, explain why.

## 3. Architecture Rules
- Always plan before writing code.
- Show the folder structure before major structural work.
- Label each planned file with its single responsibility.
- Plan for future features without prematurely overengineering.
- Never mix presentation, state, domain, and data concerns casually.
- Prefer extending the current architecture over introducing parallel patterns.

## 4. Code Quality Rules
- No function longer than 30 lines unless there is a strong reason.
- No file longer than 200 lines without considering a split.
- No repeated code when a shared function/provider/service would be clearer.
- Every function must have a clear, descriptive name.
- Add a short comment above every function explaining its purpose.
- Do not leave magic numbers or strings in feature code without justification.

## 5. Feature Addition Rules
- Read the existing code first.
- Fit new work into existing patterns.
- Do not rewrite working code just to add a feature.
- Prefer minimal, local change over broad rewrites.
- Always consider what existing behavior could regress.

## 6. Debugging Rules
- Never guess.
- Read the full error carefully.
- Identify the exact file and line involved.
- Trace backward to the caller.
- Form a root-cause hypothesis.
- Test the hypothesis with the minimum necessary change.
- Confirm the fix before declaring success.
- Check whether the same bug pattern exists elsewhere.
- Explain the root cause in plain language before presenting the fix.
- When summarizing a fix, prefer showing changed lines only.

## 7. FitCraft-Specific Loading Order
For FitCraft tasks, use project guidance in this order:
1. `project-operating-rules.md` — always read first
2. `flutter-riverpod-patterns.md` — any Flutter UI/state/provider work
3. feature-specific skill files as needed
4. `supabase-firebase-split.md` — auth/data/storage work
5. `bangladesh-context.md` — pricing, payments, local-market decisions
6. `fastapi-backend.md` — backend work only

## 8. Deliverable Expectations
When working on FitCraft, responses should usually include:
- assumptions
- plan
- touched files
- risks
- validation steps
- concise result summary
