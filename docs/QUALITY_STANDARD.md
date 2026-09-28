# Portuguese Survivor — Quality Standard

## 1. Purpose

This document defines the minimum quality standards required for Portuguese Survivor.

It applies to:

- Flutter code
- gameplay
- missions
- educational content
- Portuguese language
- UX/UI
- audio
- visual assets
- performance
- testing
- release builds
- store readiness

The purpose is to ensure that speed of development never replaces product quality.

---

# 2. Quality Principles

Portuguese Survivor follows these principles:

1. Correctness
2. Reliability
3. Educational accuracy
4. User clarity
5. Consistency
6. Maintainability
7. Performance
8. Testability
9. Accessibility
10. Release readiness

---

# 3. Definition of Quality

A feature is considered high quality when:

- it solves the intended problem
- it behaves correctly
- it is understandable to the player
- it does not introduce unacceptable regressions
- relevant tests pass
- content is accurate
- European Portuguese standards are respected
- documentation is updated when necessary

---

# 4. Quality Levels

Use four quality levels.

## Level A — Release Ready

Suitable for production release.

Requirements:

- critical paths validated
- no known P0 defects
- no unacceptable P1 defects
- tests pass
- Portuguese content validated
- UX validated
- performance acceptable
- release build verified

---

## Level B — Production Quality

Suitable for normal development use.

Requirements:

- feature works
- major paths tested
- known limitations documented
- no critical regression

---

## Level C — Prototype

Suitable for experimentation.

Requirements:

- purpose is clear
- core concept works
- limitations are known

Prototype code must not automatically be treated as production code.

---

## Level D — Experimental

Used for:

- ideas
- experiments
- temporary implementations
- proof of concept

Experimental work should not be released without further validation.

---

# 5. Critical Quality Rules

The following rules are mandatory.

### Rule 1

Never knowingly release broken core functionality.

### Rule 2

Never knowingly release incorrect Portuguese learning content.

### Rule 3

Never claim that a feature is tested when it has not been tested.

### Rule 4

Never claim that a build succeeded when it was not actually verified.

### Rule 5

Never hide known critical problems.

### Rule 6

Do not silently change established product behavior.

---

# 6. Code Quality

Flutter code should be:

- readable
- maintainable
- reasonably modular
- appropriately documented
- consistent with project architecture

Avoid:

- unnecessary duplication
- dead code
- unexplained hacks
- unnecessary complexity
- large unrelated refactors

---

# 7. Flutter Quality Checklist

Before marking a significant Flutter task DONE, check:

- application compiles
- analyzer passes
- relevant tests pass
- navigation works
- state changes behave correctly
- error states are handled
- loading states are handled
- empty states are handled
- important user interactions work
- no obvious memory/performance problem exists

---

# 8. Static Analysis

When applicable, run:

```text
flutter analyze
