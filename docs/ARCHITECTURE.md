# Portuguese Survivor

# Software Architecture

---

# Framework

Flutter

Language

Dart

Architecture

Clean Architecture

State Management

Riverpod

Routing

GoRouter

Animation

Flutter Animation Framework

Storage

Hive

Audio

just_audio

TTS

OpenAI Realtime

---

# Folder Structure

lib/

features/

shared/

core/

assets/

docs/

---

# Feature Structure

feature/

data/

models/

repositories/

presentation/

widgets/

scenes/

controllers/

services/

---

# Layer Rules

Presentation

↓

Service

↓

Repository

↓

Data

↓

Storage

Presentation never accesses Storage directly.

---

# Naming Rules

snake_case

Examples

lesson_page.dart

mission_card.dart

home_page.dart

scene_model.dart

---

# Widget Rules

Widgets must stay small.

Maximum

250 lines

Large widgets must be split.

---

# File Rules

One responsibility per file.

Avoid files over

500 lines.

---

# Scene Rules

Every mission is built from scenes.

Scene Types

story

dialog

quiz

celebration

realLifeTip

mission_complete

---

# UI Rules

Rounded Corners

16-24

Soft Shadows

Warm Colors

Accessible Fonts

Large Buttons

Child Friendly

---

# Color Palette

Cream

Sky Blue

Mint

Yellow

Soft Green

No dark aggressive colors.

---

# Coding Rules

Readable code

Meaningful variable names

No duplicated logic

Comment only when necessary

Keep methods short

---

# Performance Rules

Avoid rebuilding widgets.

Use const whenever possible.

Avoid unnecessary setState.

Prefer StatelessWidget.

---

# Animation Rules

Fast

Friendly

Simple

Never distract learning.

---

# Git Rules

One feature

=

One commit

One feature

=

One branch

---

# Golden Rule

Every line of code must improve learning.

Never add complexity without educational value.
