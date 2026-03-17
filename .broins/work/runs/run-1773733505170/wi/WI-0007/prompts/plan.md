CRITICAL ESCALATION: Previous delta-planning attempts failed with the same gaps. You MUST take a COMPLETELY DIFFERENT approach. Do NOT refine the previous plan — start fresh. Consider:
- A different file structure or architecture
- Breaking the problem into smaller pieces
- Using different APIs, patterns, or libraries
- Simplifying the scope to the core requirement

## Product Manager Role

You are the **Product Manager** on this task.
Key focus: - Define clear acceptance criteria and success metrics for the work item. - Prioritise scope: identify what is essential (must-have) versus nice-to-have.

## Software Architect Role

You are the **Software Architect** on this task.
Key focus: - Design the high-level solution architecture and component interactions. - Choose appropriate patterns, abstractions, and technology trade-offs.

# Planning Phase

## Work Item: Forms (Part 1/57)

**ID:** WI-0007
**Description:** - Forms > OiForm: All Tier 2 input components (`OiTextInput`, `OiNumberInput`, `OiDateInput`, `OiSelect`, etc.)
- Forms > OiForm: `OiColumn` (layout)
- Forms > OiForm: `OiLabel` (section titles)
**Risk:** medium

### Definition of Done

- [ ] Atom REQ-0493 fully implemented: Forms > OiForm: All Tier 2 input components (`OiTextInput`, `OiNumberInput`, `OiDateInput`, `OiSelect`, etc.)
- [ ] Atom REQ-0494 fully implemented: Forms > OiForm: `OiColumn` (layout)
- [ ] Atom REQ-0495 fully implemented: Forms > OiForm: `OiLabel` (section titles)
- [ ] All project checks pass (format, analyze, test)
- [ ] Coverage ledger updated for all atoms

## Requirement Atoms

- [ ] REQ-0493: All Tier 2 input components (`OiTextInput`, `OiNumberInput`, `OiDateInput`, `OiSelect`, etc.)
- [ ] REQ-0494: `OiColumn` (layout)
- [ ] REQ-0495: `OiLabel` (section titles)

Every item above must be verified individually. Do not skip any.

## Question Answers

- **WI-0007-Q001**: How should "All Tier 2 input components (`OiTextInput`, `OiNumberInput`, `OiDateInput`, `OiSelect`, etc.)" be verified? No acceptance hints were provided. → _(no answer)_
- **WI-0007-Q002**: How should "`OiColumn` (layout)" be verified? No acceptance hints were provided. → _(no answer)_
- **WI-0007-Q003**: How should "`OiLabel` (section titles)" be verified? No acceptance hints were provided. → _(no answer)_

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

## Delta Planning

A previous plan was attempted but encountered failures. Fix ONLY the specific issues below. Preserve all working code and do not re-implement what already works.

### Previous Plan (summary)

API Error: Unable to connect to API (EAI_AGAIN)API Error: Unable to connect to API (EAI_AGAIN)

## CRITICAL: Verification Gaps (auto-injected — planner output was insufficient)

**REQ-0493** — missing
  Missing: Could not parse verification output
  Evidence: No implementation files found for this atom.
**REQ-0494** — missing
  Missing: Could not parse verification output
  Evidence: No implementation files found for this atom.
**REQ-0495** — missing
  Missing: Could not parse verification output
  Evidence: No implementation files found for this atom.

You MUST address each gap above. Create or modify the specific files, classes, and methods needed to satisfy each requirement atom.


### Failure Summary

QA NOT_READY (structural): REQ-0493: Could not parse verification output; REQ-0494: Could not parse verification output; REQ-0495: Could not parse verification output

### Verification Details

The verifier found these specific gaps. Address each one explicitly in your revised plan:

**REQ-0493** — missing
  Missing: Could not parse verification output
  Evidence: No implementation files found for this atom.
**REQ-0494** — missing
  Missing: Could not parse verification output
  Evidence: No implementation files found for this atom.
**REQ-0495** — missing
  Missing: Could not parse verification output
  Evidence: No implementation files found for this atom.

Focus on what needs to change. Do not repeat steps that succeeded.
