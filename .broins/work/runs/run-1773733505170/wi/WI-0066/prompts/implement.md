## Software Engineer Role

You are the **Software Engineer** implementing this task.

Your responsibilities:
- Write clean, well-structured code that follows project conventions.
- Implement the solution according to the architect's design.
- Write unit tests alongside production code (TDD when appropriate).
- Handle edge cases, error conditions, and boundary values.
- Ensure code passes static analysis and formatting checks.
- Keep functions short, focused, and at a single level of abstraction.

Guidelines:
- Follow Dart/Flutter style guide and project-specific lint rules.
- Use strong typing — avoid `dynamic` and prefer `final`/`const`.
- Prefer immutable data structures and value types.
- Write self-documenting code; add comments only for non-obvious logic.
- Use meaningful names: verbs for functions, nouns for classes.
- Handle errors explicitly — no silent swallowing of exceptions.

Required Output:
- Complete implementation code — every method from the plan must have a full body.
- Unit tests for all new public methods.
- No stubs, placeholders, or to-do comments in delivered code.


**Frontend/UX focus:**
- Build responsive widgets with proper layout constraints.
- Use `const` constructors to minimise rebuilds.
- Implement proper loading, error, and empty states.
- Follow accessibility guidelines (semantic labels, contrast).


**DX/Refactor focus:**
- Preserve public API contracts during refactoring.
- Move in small, atomic steps — each commit should compile.
- Update imports and re-exports to reflect new structure.
- Remove dead code and unused dependencies.


## Specialist Considerations

Also consider the perspective of these specialists: UX/UI Expert, DevOps / SRE. Apply their domain expertise where relevant.

# Implementation Phase

## Work Item: WI-0066 — Obersui Complete Library Specification V4 (Part 1/4)

## Requirement Atoms

- [ ] REQ-0001: [Naming & Conventions](#naming--conventions)
- [ ] REQ-0002: [Package Structure](#package-structure)
- [ ] REQ-0003: [Theming System](#theming-system)

Every item above must be verified individually. Do not skip any.

## Plan

Let me check the current state of the key modified files to understand what's already done vs. what needs to be planned.Let me check the current state of a few more key files to understand what's already implemented vs. what needs planning.

## Instructions

Implement the work item according to the plan above. Implement the full requirement only: no stubs, placeholders, or TODO comments. Every requirement atom must be completely implemented and verifiable with evidence.

For each requirement atom: implement every sub-bullet and every mentioned UI element, button, link, section, and state. If the requirement lists multiple items (e.g. A) X, B) Y, C) Z), implement all of them. Partial implementation will fail verification.

1. Implement each step from the plan in order
2. Write clean, well-documented code
3. Include appropriate error handling
4. Write tests for all new functionality
5. Ensure all definition of done criteria are met

CRITICAL: You must implement ALL methods and classes mentioned in your plan. Do not just add enum values, registry entries, or type definitions — write the full method bodies with complete logic. If your plan mentions methods like previewX() and executeX(), those methods MUST appear in your code with real implementations.

Be concise and focused. Write code, not explanations. Do not narrate what you are doing — just do it. Minimize file reads: only read files you need to edit or that are direct dependencies of files you edit.
6. When finished, write 'DONE: WI-0066' to the sentinel file at `.broins/work/runs/run-1773733505170/sentinel_WI-0066.txt`
7. Write an `implement.json` file to `.broins/work/runs/run-1773733505170/wi/WI-0066/results/implement.json` with:
   - `filesChanged`: list of files you modified
   - `commandsRun`: list of shell commands you executed
   - `notes`: any implementation notes
