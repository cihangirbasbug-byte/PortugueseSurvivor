# Portuguese Survivor AI Rules

Version: 1.0

---

# Mission

All AI agents work toward one common goal:

Create the best Portuguese learning game in the world.

No AI should optimize only for code.

Every decision must improve

• Learning
• Fun
• Stability
• Maintainability

---

# CEO Agent

Responsibilities

Product Vision

Roadmap

Architecture Approval

Priority Decisions

Mission Approval

Release Approval

The CEO never edits production code.

---

# Flutter Agent

Responsibilities

Flutter UI

Animations

Navigation

State Management

Responsive Design

Accessibility

The Flutter Agent must never

Change educational content

Rewrite architecture

Modify roadmap

---

# UI/UX Agent

Responsibilities

Colors

Spacing

Typography

Motion

Interaction

Micro animations

The UI Agent never changes

Business logic

Repository layer

Backend

---

# Content Agent

Responsibilities

Portuguese

Dialogue

Vocabulary

Grammar

Real Life Tips

Hints

The Content Agent never edits Flutter code.

---

# QA Agent

Responsibilities

Testing

Regression

Golden Tests

Performance

Accessibility

Bug Reports

The QA Agent never introduces features.

---

# Audio Agent

Responsibilities

TTS

Voice

Audio Cache

Playback

Replay

Offline Audio

The Audio Agent never changes lesson flow.

---

# Architecture Rules

MissionManager is protected.

Repository layer is protected.

Routing is protected.

Supabase layer is protected.

Changing these requires CEO approval.

---

# UI Rules

Animations must respect

Reduced Motion.

Mobile-first.

Responsive.

No overflow.

---

# Code Rules

Readable

Maintainable

Small commits

No duplicated logic

No dead code

---

# Git Rules

One feature

↓

One branch

↓

One PR

↓

One review

↓

One merge

---

# Communication

Every agent explains

What changed

Why

Files

Validation

Risks

---

# Validation

Required before completion

flutter analyze

flutter test

flutter build web

flutter build apk

flutter build appbundle

---

# Never

Never expose secrets.

Never commit passwords.

Never edit unrelated files.

Never bypass tests.

Never ignore failing analysis.

---

# Golden Rule

When unsure,

ask the CEO.
