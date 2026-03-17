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


**Frontend/UX focus:**
- Define user stories with clear persona and motivation.
- Specify responsive behaviour across breakpoints.
- Identify accessibility requirements (WCAG level).
- Consider loading states, empty states, and error states.


**Feature/Bugfix focus:**
- Clarify the exact reproduction steps for bugs.
- Define the feature flag strategy if applicable.
- Specify rollback criteria and blast-radius limits.
- Identify affected user segments and notification needs.


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


**Frontend/UX focus:**
- Design widget/component hierarchy and state-management approach.
- Define navigation flow and routing architecture.
- Plan theming and design-token integration.
- Consider code-splitting and lazy-loading boundaries.


**Feature/Bugfix focus:**
- Map the feature to existing domain modules and identify touchpoints.
- Design the feature-flag integration if applicable.
- Plan the rollout sequence and dependency ordering.
- Identify shared utilities that can be reused or extended.


## Specialist Considerations

Also consider the perspective of these specialists: UX/UI Expert, DevOps / SRE, Technical Writer. Apply their domain expertise where relevant.

# Planning Phase

## Work Item: Fix: Theming System

**ID:** FV-1-375
**Description:** Complete theme system: OiThemeData with all factories, OiColorScheme, OiTextTheme, OiSpacingScale, OiRadiusScale, OiShadowScale, OiAnimationConfig, OiEffectsTheme (with OiHaloStyle and OiInteractiveStyle), OiDecorationTheme (with OiBorderStyle and OiGradientStyle), OiComponentThemes with per-component overrides, BuildContext theme extension, and OiThemeScope + per-component scopes.

Issues found during full verification:
OiButtonThemeScope does not exist anywhere in the codebase — spec explicitly requires `OiButtonThemeScope(theme: OiButtonThemeData(height: 48), child: MyArea())`; Theme access extension is named `OiBuildContextThemeExt` not `OiThemeExt` as specified — functionally equivalent but API name differs; OiPerformanceConfig exists in oi_animation_config.dart but is not exposed via OiThemeData.components or OiApp constructor — referenced in comments in oi_surface.dart but not wired up; OiColorScheme lacks `chart` field (List<Color>) documented in spec

Current implementation: 83%

Relevant files:
- lib/src/foundation/theme/oi_theme_data.dart:1-291 (light(), dark(), fromBrand(), copyWith(), merge(), lerp())
- lib/src/foundation/theme/oi_color_scheme.dart:1-378 (23 color fields, light/dark factories, lerp)
- lib/src/foundation/theme/oi_effects_theme.dart:1-218 (OiHaloStyle, OiInteractiveStyle, 6 state styles)
- lib/src/foundation/theme/oi_decoration_theme.dart:1-415 (OiBorderStyle factories, OiGradientStyle)
- lib/src/foundation/theme/oi_component_themes.dart:1-803 (per-component theme data classes)
- lib/src/foundation/theme/oi_theme.dart:67-81 (OiThemeScope)
- lib/src/foundation/theme/oi_theme.dart:88-118 (OiBuildContextThemeExt on BuildContext)
**Risk:** medium

### Definition of Done

- [ ] All issues resolved: OiButtonThemeScope does not exist anywhere in the codebase — spec explicitly requires `OiButtonThemeScope(theme: OiButtonThemeData(height: 48), child: MyArea())`; Theme access extension is named `OiBuildContextThemeExt` not `OiThemeExt` as specified — functionally equivalent but API name differs; OiPerformanceConfig exists in oi_animation_config.dart but is not exposed via OiThemeData.components or OiApp constructor — referenced in comments in oi_surface.dart but not wired up; OiColorScheme lacks `chart` field (List<Color>) documented in spec
- [ ] Implementation reaches 100% for: Theming System
- [ ] All related tests pass

## Requirement Atoms

- [ ] REQ-0003: [Theming System](#theming-system)

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

### Cross-atom dependencies
This work item has multiple requirement atoms. Describe how they interact: shared state, ordering constraints, and files that serve multiple atoms. Address dependencies before dependents.
