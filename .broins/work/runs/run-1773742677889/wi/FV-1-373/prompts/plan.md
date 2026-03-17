# Repository Context

## Git Status
- Branch: main
- HEAD: 014042a40b4e037c6816a57ad44d0fbe9047c2a0
- Clean: no
- Last commit: EPIC-0004: Obersui Complete Library Specification V4

## Project Structure
lib/
  src/
test/
  helpers/
  src/

## Module Map
- **components/**
  - _internal/
  - buttons/
  - display/
  - feedback/
  - inline_edit/
  - inputs/
  - navigation/
  - overlays/
  - panels/
- **composites/**
  - data/
  - editors/
  - forms/
  - media/
  - navigation/
  - onboarding/
  - scheduling/
  - search/
  - social/
  - visualization/
  - workflow/
- **foundation/**
  - persistence/
  - theme/
- **layouts/**
- **models/**
  - settings/
- **modules/**
- **primitives/**
  - animation/
  - clipboard/
  - display/
  - drag_drop/
  - gesture/
  - input/
  - interaction/
  - layout/
  - overlay/
  - scroll/
- **theme/**
- **tools/**
- **utils/**
- **widgets/**

## Check Commands
_No check commands configured._


## Product Manager Role

You are the **Product Manager** on this task.

Your responsibilities:
- Define clear acceptance criteria and success metrics for the work item.
- Prioritise scope: identify what is essential (must-have) versus nice-to-have.
- Ensure the solution aligns with the broader product vision and roadmap.
- Surface trade-offs between scope, quality, and delivery speed.
- Validate that assumptions are documented and open questions are tracked.
- Coordinate across specialist agents to ensure coherent delivery.

Guidelines:
- Write acceptance criteria in Given/When/Then or checklist format.
- Keep requirements atomic — one verifiable behaviour per criterion.
- Flag any ambiguity in the original task description as an open question.
- Consider backward compatibility and migration impact.
- Think about observability: how will we know this works in production?

Required Output:
- Problem statement (2–3 sentences describing what this solves).
- In-scope / out-of-scope boundary list.
- Numbered acceptance criteria in Given/When/Then or checklist format.
- Open questions with suggested defaults.


**DX/Refactor focus:**
- Define developer-experience improvement goals.
- Specify backward compatibility requirements for APIs.
- Identify documentation and migration-guide needs.
- Consider impact on CI/CD pipeline and build times.


## Software Architect Role

You are the **Software Architect** on this task.

Your responsibilities:
- Design the high-level solution architecture and component interactions.
- Choose appropriate patterns, abstractions, and technology trade-offs.
- Ensure the design aligns with existing system conventions and constraints.
- Identify integration points, boundaries, and contracts between modules.
- Evaluate scalability, maintainability, and extensibility of the design.
- Document key architectural decisions and their rationale.

Guidelines:
- Prefer composition over inheritance.
- Follow SOLID principles and clean-architecture layering.
- Keep coupling low and cohesion high between modules.
- Design for testability — every component should be independently testable.
- Consider failure modes and graceful degradation.
- Minimise blast radius of changes by respecting existing boundaries.

Required Output:
- File-to-responsibility mapping (which file owns which concern).
- Interface contracts with concrete type signatures.
- Dependency flow showing how components connect.
- Risk or complexity callouts for the implementer.


**DX/Refactor focus:**
- Design the target module structure and public API surface.
- Plan incremental refactoring steps to avoid big-bang changes.
- Define abstraction layers and dependency-injection patterns.
- Consider code-generation and build-tooling integration.


## Specialist Considerations

Also consider the perspective of these specialists: DevOps / SRE, Technical Writer. Apply their domain expertise where relevant.

# Planning Phase

## Work Item: Fix: Package Structure

**ID:** FV-1-373
**Description:** All required files and directories present under lib/src/ matching the spec-defined hierarchy: foundation, primitives, components, composites, modules, tools, utils.

Issues found during full verification:
Empty directories exist: lib/src/layouts/, lib/src/theme/, lib/src/widgets/ — these are listed in git but contain no files, indicating planned but not-yet-used structure; Extra persistence/ subdirectory in foundation/ not in spec (additive, not breaking); No oi_platform.dart listed in spec but lib/src/foundation/oi_platform.dart exists (additive)

Current implementation: 92%

Relevant files:
- lib/src/foundation/ (18 files including theme/ subdirectory with all 9 theme files)
- lib/src/primitives/ (40 files across 10 subdirectories)
- lib/src/components/ (55 files across 9 subdirectories)
- lib/src/composites/ (43 files across 11 subdirectories)
- lib/src/modules/ (10 files)
- lib/src/tools/ (4 files)
- lib/src/utils/ (6 files)
- lib/obers_ui.dart (304-line barrel export)
**Risk:** medium

### Definition of Done

- [ ] All issues resolved: Empty directories exist: lib/src/layouts/, lib/src/theme/, lib/src/widgets/ — these are listed in git but contain no files, indicating planned but not-yet-used structure; Extra persistence/ subdirectory in foundation/ not in spec (additive, not breaking); No oi_platform.dart listed in spec but lib/src/foundation/oi_platform.dart exists (additive)
- [ ] Implementation reaches 100% for: Package Structure
- [ ] All related tests pass

## Requirement Atoms

- [ ] REQ-0002: [Package Structure](#package-structure)

Every item above must be verified individually. Do not skip any.

## Instructions

Create a detailed implementation plan for this work item. Your plan MUST include the following sections (use exactly these headings so the implement phase can follow them):

### Concept
1–2 sentences: what this work item achieves and how it fits the broader feature.

### Sub-tasks
Ordered list with short IDs (e.g. ST1, ST2) and one line each: "ST1: Create X", "ST2: Wire Y to Z". Implement in order.

### Method signatures
List every public method and class you will create or modify using backtick-wrapped signatures, e.g. `MyService.fetchData()`, `_buildAlerts()`. This list is verified after implementation.

### Edge cases and fallbacks
List edge cases (e.g. missing file, empty list, network error) and desired fallback behavior (e.g. show message, disable button).

### UX / requirement matching
Explicit goals that map to requirement atoms (e.g. "Atom REQ-001: User can click Init → show progress").

### Test cases
If the project runs tests (e.g. npm run test), list the test cases or scenarios you will add or run; these will be executed in the check phase.

### Definition of done checklist
Explicit checklist items: [ ] All atoms implemented with evidence, [ ] Format/lint/test pass, [ ] No placeholders. Derive from the work item DoD above.

### Files to create or modify (MANDATORY)
You MUST list EVERY file you will create or modify with its FULL path relative to the project root. Format as a numbered checklist:
1. [ ] path/to/file.dart — description of changes
2. [ ] path/to/other_file.dart — description of changes
This list will be verified against requirement atoms before implementation begins. Missing files will cause re-planning.

### Commands to run in check phase (optional)
If this work item introduces a new test file or custom check, specify which commands must pass (e.g. npm run test or a path).

Also include: key design decisions and rationale, and potential risks with mitigation.
