# Portuguese Survivor — Coding Standard

## 1. Purpose

This document defines the coding standards for Portuguese Survivor.

It applies to:

- Flutter
- Dart
- Android configuration
- application architecture
- tests
- scripts
- AI-generated code
- Codex-generated code

The objective is to keep the codebase:

- readable
- maintainable
- predictable
- testable
- scalable
- consistent

---

# 2. Core Principle

The preferred implementation is:

> The simplest correct implementation that fits the existing architecture.

Do not introduce complexity without a clear reason.

---

# 3. Technology Standard

The primary application technology is:

- Flutter
- Dart

The project should use stable and well-supported technologies unless there is a documented reason to use something else.

---

# 4. Existing Architecture First

Before creating or modifying code:

1. inspect the existing architecture
2. identify the relevant feature
3. identify existing reusable components
4. follow established project conventions
5. avoid creating parallel systems

Do not create a new architecture simply because another pattern appears cleaner.

---

# 5. Change Scope

A code change should be as small as reasonably possible.

Prefer:

```text
One problem
↓
One focused change
↓
Relevant tests
