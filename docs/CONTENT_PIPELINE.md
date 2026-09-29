# CONTENT PIPELINE

## 1. Purpose

This document defines the standard content production pipeline for Portuguese Survivor.

The goal is to ensure that every educational game content item follows a consistent process from initial idea to final in-game implementation.

The standard pipeline is:

**Idea → Vocabulary → Dialogue → Mission → Audio → QA → Integration → Validation → Release**

Content must not be added directly to the game without passing the appropriate quality checks.

---

# 2. Content Philosophy

Portuguese Survivor is an educational game.

Content must therefore satisfy three requirements simultaneously:

1. It must teach useful European Portuguese.
2. It must be understandable and engaging for the target learner.
3. It must work naturally inside gameplay.

Educational correctness has priority over decorative or unnecessary content.

Gameplay should reinforce learning rather than distract from it.

---

# 3. Source of Truth

Content production must follow the project's source-of-truth hierarchy.

Priority order:

1. `PROJECT_BIBLE.md`
2. `GAMEPLAY_RULES.md`
3. `CONTENT_GUIDE.md`
4. `AI_RULES.md`
5. `DESIGN_SYSTEM.md`
6. `CONTENT_PIPELINE.md`
7. Agent-specific instructions
8. Individual content files
9. AI-generated suggestions
10. Temporary chat discussions

If a conflict exists, the higher-level document has priority.

AI agents must not silently override project rules.

---

# 4. Content Types

Portuguese Survivor content may include:

- Vocabulary
- Expressions
- Sentences
- Dialogues
- Missions
- Exercises
- Questions
- Answers
- Hints
- Rewards
- Audio
- Pronunciation guidance
- Cultural notes
- Visual assets
- Animation requirements
- Learning feedback

Each content item must have a clear educational purpose.

---

# 5. Content Lifecycle

Every content item should follow these stages:

```text
IDEA
  ↓
CONTENT DESIGN
  ↓
PORTUGUESE REVIEW
  ↓
GAMEPLAY DESIGN
  ↓
AUDIO / VISUAL PRODUCTION
  ↓
QA
  ↓
IMPLEMENTATION
  ↓
IN-GAME VALIDATION
  ↓
APPROVAL
  ↓
RELEASE
