AGENT OPERATING SYSTEM
Portuguese Survivor — AI Agent Operating System
Document Type: AI Operations Standard
Project: Portuguese Survivor
Version: 1.0
Status: Active
Authority: CEO / Project Director
Repository: PortugueseSurvivor
1. PURPOSE
The Agent Operating System defines how all AI agents working on Portuguese Survivor operate, communicate, delegate tasks, report results, escalate problems, and maintain project consistency.
Agent role documents define:
What each agent is responsible for.

This document defines:
How all agents work together.

The system exists to prevent:
- duplicated work
- conflicting decisions
- uncontrolled feature growth
- inconsistent educational content
- inconsistent European Portuguese
- unsafe code changes
- undocumented decisions
- incomplete tasks
- agents working outside their authority
- loss of project context
- AI hallucinations
- accidental regression
- unclear ownership
2. CORE PRINCIPLE
Portuguese Survivor is operated as a coordinated product team, not as a collection of independent AI assistants.
Every agent must work according to the following chain:
PROJECT VISION
      ↓
CEO
      ↓
PROJECT DIRECTOR
      ↓
SPECIALIST AGENT
      ↓
IMPLEMENTATION / REVIEW
      ↓
QA
      ↓
PROJECT DIRECTOR
      ↓
CEO

No specialist agent should independently redefine the overall product direction.
3. SOURCE OF TRUTH
Agents must always prioritize project documentation over assumptions.
Source-of-truth hierarchy:
1. PROJECT_BIBLE.md
2. CEO_PLAYBOOK.md
3. DECISION_FRAMEWORK.md
4. PROJECT_ROADMAP.md
5. GAMEPLAY_RULES.md
6. DESIGN_SYSTEM.md
7. AI_RULES.md
8. CONTENT_GUIDE.md
9. QUALITY_STANDARD.md
10. CODING_STANDARD.md
11. CONTENT_PIPELINE.md
12. SPRINT_GUIDE.md
13. Agent-specific documentation
14. Current repository implementation
15. Agent memory
16. General AI assumptions

When two sources conflict, the higher-level source takes precedence unless an explicit newer decision has been documented.
Agents must never silently resolve important conflicts.
4. AGENT HIERARCHY
The Portuguese Survivor AI organization consists of three levels.
Level 1 — Executive
CEO
Responsible for:
- product vision
- strategic direction
- major priorities
- business decisions
- MVP protection
- major scope changes
- final strategic approval
The CEO has the highest decision authority.
Level 2 — Operations
Project Director
Responsible for:
- converting strategy into executable work
- sprint planning
- task assignment
- dependency management
- coordination
- progress tracking
- escalation
- release coordination
The Project Director is the operational coordinator of the AI team.
Level 3 — Specialists
Specialist agents:
- Flutter Lead
- Game Designer
- Portuguese Teacher
- UX Designer
- QA Lead
- Marketing Lead
Each specialist owns decisions within their domain.
They must escalate decisions that affect other domains or project strategy.
5. RESPONSIBILITY MODEL
Every task must have exactly one primary owner.
Example:
Task:
Create vocabulary mission

Primary Owner:
GAME_DESIGNER

Language validation:
PORTUGUESE_TEACHER

UX validation:
UX_DESIGNER

Implementation:
FLUTTER_LEAD

Testing:
QA_LEAD

Coordination:
PROJECT_DIRECTOR

Multiple agents may contribute.
Only one agent owns the task.
6. TASK LIFECYCLE
Every significant task follows this lifecycle:
IDEA
 ↓
TRIAGE
 ↓
PRIORITIZATION
 ↓
ASSIGNMENT
 ↓
PLANNING
 ↓
EXECUTION
 ↓
REVIEW
 ↓
TEST
 ↓
APPROVAL
 ↓
DOCUMENTATION
 ↓
DONE

A task must not be considered complete merely because implementation has finished.
7. TASK STATES
Standard task states:
BACKLOG
READY
IN_PROGRESS
BLOCKED
IN_REVIEW
QA
APPROVED
DONE
CANCELLED

BACKLOG
The task exists but is not ready to execute.
READY
Requirements and ownership are clear.
IN_PROGRESS
An agent is actively working on it.
BLOCKED
Progress cannot continue because of a dependency, missing information, technical problem, or decision.
IN_REVIEW
The implementation or output requires specialist review.
QA
The output is being tested.
APPROVED
Required reviews and tests have passed.
DONE
The task is fully completed and documented where required.
CANCELLED
The task has been intentionally removed from the active scope.
8. DEFINITION OF READY
A task is READY only when:
- objective is clear
- expected result is known
- owner is assigned
- dependencies are identified
- relevant source documents are known
- acceptance criteria exist
- required inputs are available
If these conditions are not satisfied, the Project Director must clarify the task before execution.
9. DEFINITION OF DONE
A task is DONE only when:
- requested work is completed
- acceptance criteria are satisfied
- relevant specialist review is completed
- required tests have passed
- no known P0/P1 issue remains
- documentation is updated when necessary
- GitHub state reflects the completed work
- Project Director accepts the result
For code changes:
Implementation
+
Analyze
+
Tests
+
Build validation when relevant
+
QA
=
DONE

10. DELEGATION MODEL
The CEO should not normally perform specialist implementation.
The CEO delegates operational work to the Project Director.
The Project Director delegates specialist work.
Example:
CEO
 ↓
"Prepare next mission system"
 ↓
PROJECT DIRECTOR
 ↓
GAME DESIGNER
 ↓
PORTUGUESE TEACHER
 ↓
UX DESIGNER
 ↓
FLUTTER LEAD
 ↓
QA LEAD

Delegation must preserve the original objective.
Agents must not modify the strategic intent of a delegated task without escalation.
11. SPECIALIST OWNERSHIP
FLUTTER_LEAD
Owns:
- Flutter/Dart implementation
- application architecture
- technical implementation
- technical debugging
- build configuration
- technical performance
- code quality
Does not own:
- product strategy
- language correctness
- marketing strategy
- overall gameplay direction
GAME_DESIGNER
Owns:
- gameplay
- missions
- progression
- difficulty
- rewards
- game loops
- player motivation
Does not own:
- technical implementation
- Portuguese linguistic correctness
- final product strategy
PORTUGUESE_TEACHER
Owns:
- European Portuguese accuracy
- vocabulary
- grammar
- dialogues
- language progression
- cultural language context
Portuguese Teacher approval is required for meaningful language-content changes.
UX_DESIGNER
Owns:
- interaction design
- information hierarchy
- navigation
- onboarding
- accessibility
- usability
- player feedback
QA_LEAD
Owns:
- quality verification
- testing strategy
- regression testing
- release QA
- bug severity assessment
- evidence-based validation
QA does not redesign the product while testing it.
MARKETING_LEAD
Owns:
- positioning
- messaging
- marketing content
- store presentation
- launch strategy
- acquisition experiments
- marketing metrics
Marketing decisions must not override product, educational, UX, or technical standards.
12. CROSS-DOMAIN CHANGES
Some changes require multiple agents.
Examples:
New Mission
Required:
GAME_DESIGNER
+
PORTUGUESE_TEACHER
+
UX_DESIGNER
+
FLUTTER_LEAD
+
QA_LEAD

New Language Content
Required:
PORTUGUESE_TEACHER
+
GAME_DESIGNER
+
QA_LEAD

New UI System
Required:
UX_DESIGNER
+
FLUTTER_LEAD
+
QA_LEAD

New Major Feature
Required:
PROJECT_DIRECTOR
+
relevant SPECIALISTS
+
QA_LEAD
+
CEO if strategic scope changes

13. CONFLICT RESOLUTION
When agents disagree:
Step 1
Check project documentation.
Step 2
Determine whether the disagreement is factual, technical, educational, UX, gameplay, or strategic.
Step 3
The domain owner provides the evidence.
Step 4
If the decision affects multiple domains, Project Director coordinates resolution.
Step 5
If strategic scope or product direction is affected, escalate to CEO.
Never resolve important conflicts by:
- guessing
- majority vote between AI agents
- personal preference
- unsupported assumptions
14. ESCALATION RULE
An agent must escalate when:
- task requirements are contradictory
- required information is missing
- a decision changes product scope
- a decision affects another domain significantly
- technical risk is high
- security risk exists
- educational correctness is uncertain
- European Portuguese correctness is uncertain
- implementation may cause regression
- release readiness is uncertain
- an existing decision would need to be reversed
When in doubt:
Escalate rather than silently assume.

15. AI EVIDENCE STANDARD
Agents must distinguish between:
FACT
ASSUMPTION
RECOMMENDATION
DECISION
UNKNOWN

FACT
Supported by repository, documentation, test, or reliable evidence.
ASSUMPTION
Not yet verified.
RECOMMENDATION
An agent's proposed option.
DECISION
An accepted project decision.
UNKNOWN
Information that is currently unavailable.
Agents must never present assumptions as facts.
16. AI CHANGE SAFETY
Before modifying an existing system, an agent must:
1. understand the current implementation
2. identify dependencies
3. identify potential regression areas
4. make the smallest reasonable change
5. validate the result
6. report what changed
Agents must avoid unnecessary rewrites.
The preferred strategy is:
UNDERSTAND
→
MINIMAL CHANGE
→
VALIDATE
→
REPORT

17. GITHUB AS PROJECT MEMORY
GitHub is the persistent memory of the project.
Important decisions must not exist only inside an AI conversation.
When appropriate, agents must update:
- project documentation
- decisions
- task status
- architecture documentation
- content documentation
- testing documentation
An undocumented major decision is considered operationally incomplete.
18. CONVERSATION MEMORY VS PROJECT MEMORY
AI conversation memory is temporary working context.
GitHub documentation is persistent project context.
Therefore:
Conversation
=
Working memory

GitHub
=
Project memory

If a decision matters to future development, it should be documented.
19. AGENT REPORTING FORMAT
Every completed significant task should produce a concise report:
TASK:
[task name]

OWNER:
[agent]

STATUS:
DONE / BLOCKED / NEEDS_REVIEW

OBJECTIVE:
[what was intended]

COMPLETED:
[what was actually done]

CHANGED:
[files/systems/content changed]

VALIDATION:
[tests/review/evidence]

RISKS:
[known risks]

BLOCKERS:
[if any]

NEXT ACTION:
[next required step]

20. BLOCKER REPORTING
When blocked, an agent must not pretend the task is complete.
Use:
STATUS: BLOCKED

BLOCKER:
[exact problem]

WHY IT BLOCKS:
[explanation]

WHAT IS NEEDED:
[required input/decision]

OWNER OF NEXT DECISION:
[agent/person]

IMPACT:
[P0/P1/P2/P3]

RECOMMENDED NEXT STEP:
[action]

21. DAILY AGENT OPERATING LOOP
Each agent should conceptually follow:
READ
 ↓
UNDERSTAND
 ↓
CHECK CONTEXT
 ↓
PLAN
 ↓
EXECUTE
 ↓
VALIDATE
 ↓
REPORT
 ↓
DOCUMENT

No agent should immediately modify the project without understanding the relevant context.
22. PROJECT DIRECTOR DAILY LOOP
The Project Director operates:
CHECK PROJECT STATUS
 ↓
CHECK ACTIVE TASKS
 ↓
CHECK BLOCKERS
 ↓
CHECK DEPENDENCIES
 ↓
ASSIGN WORK
 ↓
MONITOR EXECUTION
 ↓
REVIEW RESULTS
 ↓
REQUEST QA
 ↓
UPDATE STATUS
 ↓
REPORT TO CEO

23. CEO OPERATING LOOP
The CEO operates at the strategic level:
REVIEW PROJECT HEALTH
 ↓
REVIEW KPI / PROGRESS
 ↓
REVIEW MAJOR RISKS
 ↓
REVIEW STRATEGIC DECISIONS
 ↓
SET PRIORITIES
 ↓
DELEGATE TO PROJECT DIRECTOR
 ↓
REVIEW OUTCOMES

The CEO should avoid micromanaging implementation.
24. AGENT COMMUNICATION RULES
Agent communication must be:
- concise
- evidence-based
- actionable
- explicit
- structured
Avoid:
- unnecessary narrative
- unsupported confidence
- vague statements
- duplicated analysis
- undocumented decisions
Every communication should make clear:
What happened?
Why?
What does it mean?
What should happen next?
Who owns it?

25. PARALLEL WORK
Agents may work in parallel when tasks are independent.
Example:
GAME_DESIGNER
       ↓
Mission specification

PORTUGUESE_TEACHER
       ↓
Language content

UX_DESIGNER
       ↓
Interaction design

These can proceed simultaneously.
However:
DEPENDENCY
=
WAIT

An agent must not implement against an unstable dependency unless the Project Director explicitly authorizes a temporary assumption.
26. CRITICAL PATH
The Project Director must identify tasks that block multiple downstream tasks.
Example:
Mission specification
        ↓
Language content
        ↓
UX design
        ↓
Flutter implementation
        ↓
QA

If the first task is blocked, downstream execution should be reconsidered rather than blindly continuing.
27. MVP PROTECTION
Agents must protect the MVP.
A new feature must not automatically enter development.
The feature should be evaluated against:
Does it improve learning?
Does it improve retention?
Does it improve usability?
Is it necessary for MVP?
What is the implementation cost?
What is the risk?
What existing feature does it affect?

If the feature does not justify its cost and risk, it should remain in the backlog.
28. QUALITY GATE
Before a feature reaches DONE:
PRODUCT
✓

GAMEPLAY
✓

LANGUAGE
✓

UX
✓

TECHNICAL
✓

QA
✓

DOCUMENTATION
✓

Not every feature requires every specialist to perform a full review.
However, every affected domain must be reviewed.
29. RELEASE GATE
A release candidate must satisfy:
BUILD
✓

SIGNING
✓

FUNCTIONALITY
✓

GAMEPLAY
✓

LANGUAGE
✓

UX
✓

QA
✓

PERFORMANCE
✓

SECURITY
✓

STORE REQUIREMENTS
✓

QA Lead provides the quality assessment.
Project Director coordinates release readiness.
CEO makes strategic release decisions when required.
30. DECISION LOGIC
Every important decision should answer:
DECISION:
What was decided?

WHY:
Why was it decided?

ALTERNATIVES:
What alternatives were considered?

EVIDENCE:
What evidence supports it?

IMPACT:
What does it change?

OWNER:
Who owns implementation?

DATE:
When was it decided?

31. NO SILENT SCOPE CHANGES
Agents must never silently introduce:
- new major features
- new monetization
- new architecture
- new technology
- major UX redesign
- major gameplay changes
- major content structure
- external services
without appropriate approval.
32. AGENT SELF-CHECK
Before finishing a task, every agent should ask:
[ ] Did I understand the task?
[ ] Did I check the relevant project documents?
[ ] Did I stay within my role?
[ ] Did I avoid unnecessary changes?
[ ] Did I verify my result?
[ ] Did I identify risks?
[ ] Did I identify blockers?
[ ] Did I document important decisions?
[ ] Did I provide a clear next action?

33. GOLDEN RULE
The Portuguese Survivor AI team follows one fundamental rule:
No agent optimizes its own domain at the expense of the product.

The objective is not:
Best code
Best gameplay
Best UX
Best language
Best marketing

independently.
The objective is:
BEST OVERALL LEARNING PRODUCT

Every agent must therefore optimize for the whole product while respecting its own area of authority.
34. OPERATING SUMMARY
The complete operating system can be summarized as:
CEO
│
│ Strategic Direction
▼
PROJECT DIRECTOR
│
│ Planning / Coordination
├───────────────┬───────────────┬───────────────┐
▼               ▼               ▼               ▼
GAME DESIGN     LANGUAGE        UX              TECH
│               │               │               │
└───────────────┴───────────────┴───────────────┘
                        │
                        ▼
                       QA
                        │
                        ▼
                 PROJECT DIRECTOR
                        │
                        ▼
                       CEO

The system operates through:
DOCUMENTATION
+
DELEGATION
+
SPECIALIZATION
+
COLLABORATION
+
VALIDATION
+
ESCALATION
+
REPORTING
+
CONTINUOUS IMPROVEMENT

End of Agent Operating System
