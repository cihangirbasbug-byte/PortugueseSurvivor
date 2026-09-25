# Portuguese Survivor Architecture

Version: 1.0

---

# Philosophy

Portuguese Survivor uses a Feature First architecture.

Every feature is independent.

Every feature owns its own

- UI
- Logic
- Models
- Repository
- State

Features must not depend directly on each other.

Communication happens only through services.

---

# Project Structure

lib/

features/

core/

shared/

services/

assets/

---

# Feature Structure

Each feature contains

presentation/

domain/

data/

widgets/

models/

repositories/

services/

---

Example

lesson/

presentation/

widgets/

domain/

data/

models/

repositories/

---

# Layers

Presentation

↓

Domain

↓

Repository

↓

Data Source

↓

Storage / API

No layer may skip another layer.

---

# State Management

Riverpod

StateNotifier

Provider

AsyncValue

State must never be stored inside Widgets.

Widgets display state.

Providers own state.

---

# Dependency Rule

UI

↓

Controller

↓

Repository

↓

Datasource

Never reverse this flow.

---

# Audio System

Audio Service

↓

Cache

↓

Player

↓

UI

Audio generation must never block UI.

---

# Lesson Engine

Lesson Engine controls

Scenes

Questions

Hints

Progress

Completion

Animations

The UI never decides lesson flow.

Lesson Engine decides.

---

# Mission Engine

Mission Engine controls

Mission order

Unlocks

XP rewards

Stars

Completion

Navigation

---

# XP Engine

XP is calculated centrally.

No screen calculates XP.

---

# Save System

Single Save Service.

All progress goes through Save Service.

No widget writes directly.

---

# Offline Support

Everything required for learning must work offline.

Downloaded audio

Lessons

Images

Progress

---

# Error Handling

Errors must never crash the application.

Instead

Show friendly UI

Retry automatically

Log silently

---

# Performance Rules

60 FPS minimum

Lazy loading

Image caching

Audio caching

Minimal rebuilds

---

# Testing

Unit Tests

Widget Tests

Integration Tests

Golden Tests

---

# Future Modules

AI Teacher

Conversation Mode

Grammar Engine

Story Engine

Leaderboard

Cloud Sync

Premium

---

# Architecture Rule

If a new feature does not fit this architecture,

the architecture is updated first,

then the feature is implemented.
