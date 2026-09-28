# Portuguese Survivor — Decision Framework

## 1. Purpose

This document defines how project decisions must be evaluated, prioritized, documented, and executed.

The purpose is to ensure that:

- decisions are consistent
- project priorities remain clear
- MVP scope is protected
- AI agents do not make arbitrary decisions
- technical and product decisions remain aligned
- learning quality is protected
- user experience remains coherent
- European Portuguese remains the language standard
- decisions are based on evidence whenever possible

This document is mandatory for all AI agents working on Portuguese Survivor.

---

# 2. Decision Authority

The final authority hierarchy is:

1. Project Owner
2. CEO / Project Director
3. Relevant Specialist Agent
4. Existing Project Documentation
5. External Research
6. AI-generated assumptions

When conflicts occur, higher-level authority takes precedence.

AI agents must never override explicit decisions made by the Project Owner.

---

# 3. Source of Truth

When information conflicts, use the following priority:

### Level 1 — Explicit Project Owner Decision

Highest authority.

Examples:

- approved feature
- approved gameplay rule
- approved UI behavior
- approved technology decision
- approved roadmap priority

---

### Level 2 — Project Bible

The Project Bible defines the overall project vision, target audience, product philosophy, and strategic direction.

---

### Level 3 — CEO Playbook

Defines how the project should be managed.

---

### Level 4 — Specialized Project Documents

Examples:

- Architecture
- Design System
- Gameplay Rules
- Content Guide
- AI Rules
- Quality Standard
- Coding Standard
- Content Pipeline

---

### Level 5 — External Research

External information may be used to validate or improve decisions.

However, external research must not silently override project decisions.

---

### Level 6 — AI Assumption

AI assumptions are the lowest authority.

When information is uncertain, the AI must explicitly state the uncertainty.

---

# 4. Decision Classification

Every significant decision should first be classified.

## 4.1 Product Decision

Examples:

- adding a new game mode
- changing progression
- changing monetization
- changing target audience
- changing learning objectives

---

## 4.2 Gameplay Decision

Examples:

- mission mechanics
- rewards
- lives
- XP
- difficulty
- progression
- enemy behavior
- player interaction

---

## 4.3 UX/UI Decision

Examples:

- screen layout
- navigation
- button placement
- animations
- feedback
- onboarding

---

## 4.4 Educational Decision

Examples:

- vocabulary selection
- grammar progression
- exercise design
- repetition system
- difficulty progression
- Portuguese correctness

---

## 4.5 Technical Decision

Examples:

- Flutter architecture
- state management
- package selection
- database structure
- performance optimization
- build configuration

---

## 4.6 Content Decision

Examples:

- vocabulary
- dialogues
- missions
- translations
- audio
- lesson structure

---

## 4.7 Business Decision

Examples:

- pricing
- monetization
- acquisition
- retention
- marketing
- partnerships

---

# 5. Decision Priority

Use the following priority system.

## P0 — Critical

Immediate attention required.

Examples:

- app cannot launch
- release build is broken
- serious data loss
- security vulnerability
- corrupted progression
- critical educational misinformation

P0 decisions can interrupt the current sprint.

---

## P1 — High

Important for product quality or release readiness.

Examples:

- major gameplay bug
- important UX problem
- broken progression
- significant performance problem
- incorrect Portuguese content
- important store-readiness issue

P1 should normally be addressed before new features.

---

## P2 — Medium

Important improvements that do not block the product.

Examples:

- UX improvements
- additional animations
- refactoring
- content improvements
- secondary features

P2 items should normally be planned into future work.

---

## P3 — Low

Optional improvements.

Examples:

- cosmetic improvements
- experimental ideas
- minor visual adjustments
- nice-to-have features

P3 items should not interrupt important production work.

---

# 6. Decision Process

Every significant decision should follow this process:

### Step 1 — Identify the Problem

Clearly describe the problem.

Bad:

> The game needs improvement.

Good:

> Players may not understand why they received XP after completing a mission.

---

### Step 2 — Identify the Goal

Define what the decision should achieve.

Example:

> Improve player understanding of the reward system without adding unnecessary UI complexity.

---

### Step 3 — Identify Constraints

Consider:

- MVP scope
- development time
- technical limitations
- educational requirements
- UX requirements
- performance
- localization
- budget
- release schedule

---

### Step 4 — Identify Options

Normally create 2–4 realistic options.

Avoid generating large numbers of theoretical alternatives.

---

### Step 5 — Evaluate Options

Evaluate each option against:

- user value
- learning value
- development effort
- technical risk
- UX impact
- scalability
- maintenance cost
- MVP impact

---

### Step 6 — Choose the Action

Select the option that best satisfies the project requirements.

The decision should be based on evidence and project priorities rather than personal preference.

---

### Step 7 — Document the Decision

Important decisions must be recorded.

The record should contain:

- decision
- reason
- alternatives considered
- expected impact
- implementation owner
- date

---

### Step 8 — Review Later

If new evidence appears, the decision may be revisited.

Changing a decision is acceptable when there is a clear reason.

---

# 7. Decision Matrix

For important decisions use the following conceptual matrix:

| Criterion | Question |
|---|---|
| User Value | Does this significantly help the player? |
| Learning Value | Does this improve Portuguese learning? |
| Product Value | Does this strengthen the product? |
| Effort | How much development work is required? |
| Risk | What can go wrong? |
| UX Impact | Does it make the experience clearer? |
| Technical Impact | Does it complicate the architecture? |
| Maintenance | Will it create long-term cost? |
| MVP Impact | Does it threaten MVP scope? |

No single criterion should automatically dominate every decision.

---

# 8. MVP Protection Rule

The MVP must be protected from uncontrolled feature growth.

Before approving a new feature, ask:

1. Is it necessary?
2. Does it support the core product?
3. Does it improve learning?
4. Does it improve retention or engagement?
5. Can it wait until after MVP?
6. What is the implementation cost?
7. What existing work must be delayed?

If the feature does not provide sufficient value, defer it.

---

# 9. Feature Approval

Every major feature should have:

- clear purpose
- user problem
- expected benefit
- scope
- dependencies
- risks
- acceptance criteria

A feature should not enter production only because:

> "It would be cool."

It must have a clear product reason.

---

# 10. Technical Decision Rule

Technical decisions should prioritize:

1. reliability
2. simplicity
3. maintainability
4. performance
5. scalability
6. development speed

Avoid unnecessary complexity.

Do not introduce a technology only because it is popular.

---

# 11. Architecture Change Rule

Before changing architecture, evaluate:

- current problem
- existing architecture
- proposed architecture
- migration effort
- regression risk
- long-term benefit

Large architectural changes require explicit approval.

AI agents must not perform major architectural restructuring simply to make code "cleaner".

---

# 12. UX Decision Rule

UX decisions should prioritize:

1. clarity
2. simplicity
3. consistency
4. accessibility
5. feedback
6. visual quality

The player should understand:

- what is happening
- what they should do
- what happened after an action
- why they received a reward
- how to continue

---

# 13. Educational Decision Rule

Educational decisions must prioritize:

1. correctness
2. usefulness
3. progressive difficulty
4. repetition
5. contextual learning
6. player motivation

Portuguese content must follow European Portuguese standards.

Brazilian Portuguese should not be introduced accidentally.

---

# 14. Portuguese Content Validation

Any uncertain Portuguese content should be validated before release.

Check:

- European Portuguese vocabulary
- spelling
- grammar
- naturalness
- pronunciation
- regional usage
- learner appropriateness

When there is uncertainty, consult reliable Portuguese language sources or a qualified Portuguese-language specialist.

---

# 15. AI Decision Rule

AI agents must not:

- invent facts
- invent project requirements
- silently change project rules
- pretend uncertainty does not exist
- claim work was completed when it was not
- make irreversible decisions without authorization

AI agents should:

- explain assumptions
- identify uncertainty
- provide evidence
- propose alternatives
- request escalation when necessary

---

# 16. Evidence Rule

When a decision depends on external facts, use evidence.

Examples:

- Flutter documentation
- Apple documentation
- Android documentation
- Google Play documentation
- Portuguese language references
- educational research
- reliable market research

Do not use unsupported claims when the decision has significant consequences.

---

# 17. Risk Evaluation

Every significant decision should consider:

### Technical Risk

Could the change break the application?

### Product Risk

Could the change reduce user value?

### Educational Risk

Could the change reduce learning quality?

### UX Risk

Could the change confuse users?

### Business Risk

Could the change negatively affect sustainability?

### Schedule Risk

Could the change delay the roadmap?

---

# 18. Reversibility

Prefer reversible decisions when uncertainty is high.

### Easily Reversible

Examples:

- UI text
- colors
- minor animations
- vocabulary order

### Moderately Reversible

Examples:

- navigation architecture
- progression rules
- data models

### Difficult to Reverse

Examples:

- major architecture changes
- database migrations
- monetization architecture
- application identity
- major product strategy

High-risk irreversible decisions require additional review.

---

# 19. Conflict Resolution

When two project documents conflict:

1. Identify the conflict.
2. Check the source-of-truth hierarchy.
3. Determine which rule has higher authority.
4. Document the resolution.
5. Update the lower-level document if necessary.

Never silently choose one rule.

---

# 20. Agent Conflict

If two AI agents disagree:

1. Compare their evidence.
2. Compare their assumptions.
3. Identify which project rule applies.
4. Escalate to the Project Director if unresolved.
5. Escalate to the Project Owner when necessary.

The goal is not for an agent to "win".

The goal is to make the most defensible project decision.

---

# 21. Time vs Quality

The project should not maximize either speed or perfection independently.

The goal is:

> Maximum useful quality within a reasonable development cost.

For MVP:

- prioritize correctness
- avoid unnecessary polish
- avoid premature optimization
- avoid unnecessary architecture
- avoid excessive content volume

---

# 22. Decision Documentation Format

Important decisions should use this format:

```text
DECISION

Date:
Decision Owner:
Decision Type:
Priority:

Problem:
Goal:

Options:
1.
2.
3.

Decision:

Reason:

Risks:

Expected Impact:

Implementation Owner:

Review Date:
