# FitCraft Skill Files — Setup Guide for Antigravity

## What's in This Folder

| File | Use When |
|------|----------|
| `flutter-riverpod-patterns.md` | Any screen, widget, state, or notifier is being created |
| `ootdiffusion-replicate.md` | Building the try-on feature or calling Replicate API |
| `mlkit-measurements.md` | Working with body scanning or pose detection |
| `supabase-firebase-split.md` | Any database, auth, or file storage operation |
| `bangladesh-context.md` | Pricing, payments, Android setup, or market decisions |
| `fastapi-backend.md` | Building or deploying the Python backend |

---

## How to Add Skills in Antigravity

### Step 1 — Upload Each Skill File

In Antigravity, go to your project settings and find the **Skills** or **Context Files** section.
Upload each `.md` file from this folder individually.

Each file will appear as an available skill the agent can reference automatically.

### Step 2 — Write Trigger Descriptions (Already Done)

Each skill file starts with a YAML block:
```
---
name: flutter-riverpod-patterns
description: "Use this skill for all Flutter + Riverpod code..."
---
```

Antigravity reads the `description` to decide WHEN to load each skill automatically.
You don't need to manually tell the agent to read them — it detects when they're relevant.

### Step 3 — Paste the Master Context Prompt First

At the start of every new agent session, paste this before your task:

```
You are building FitCraft — a Flutter + FastAPI app for 3D body scanning 
and AI virtual try-on. The full project context is in the skill files 
loaded into this project. Always read the relevant skill files before 
writing any code. Follow the architecture, folder structure, and patterns 
defined there strictly.
```

Then paste whichever weekly task prompt you need (from the project document).

---

## Skill Loading Priority

When working on a task, the agent should read skills in this order:

1. `project-operating-rules.md` — **always read first** for all FitCraft coding work
2. `flutter-riverpod-patterns.md` — for any Flutter UI, widget, state, or notifier work
3. The feature-specific skill (e.g. `mlkit-measurements.md` for scanning)
4. `supabase-firebase-split.md` — whenever data storage is involved
5. `bangladesh-context.md` — whenever pricing or payments come up
6. `fastapi-backend.md` — only when working on the Python backend

---

## Tips for Best Results

- **Start every session fresh** with the master context prompt
- After each milestone, ask: *"Summarize what was built and what files were created"* — save that as your handoff note
- If the agent starts writing `StatefulWidget` or `FutureBuilder`, point it to `flutter-riverpod-patterns.md`
- If it hardcodes USD prices, point it to `bangladesh-context.md`
- If it confuses Firebase Storage with Supabase, point it to `supabase-firebase-split.md`
