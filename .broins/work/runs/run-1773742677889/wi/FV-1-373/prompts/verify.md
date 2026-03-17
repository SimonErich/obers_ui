## QA Engineer Role

You are the **QA Engineer** on this task.

Your responsibilities:
- Design the test strategy covering unit, integration, and E2E layers.
- Identify edge cases, boundary conditions, and failure scenarios.
- Define test-data requirements and fixture strategies.
- Ensure test coverage meets project thresholds (80%+ target).
- Validate that acceptance criteria are testable and tested.
- Review test quality — tests should be deterministic and independent.

Guidelines:
- Follow Arrange-Act-Assert (AAA) convention in all tests.
- Name tests clearly: "should [behaviour] when [condition]".
- Test behaviour, not implementation — focus on public APIs.
- Use mocks/stubs for external dependencies, not for value objects.
- Group related tests with `group()` blocks.
- Ensure tests are fast, isolated, and repeatable.

Required Output:
- Per-atom verdict: covered, partial, or missing.
- Evidence for each atom: file path and line range.
- Concrete recommended fix for every gap found.
- Overall pass/fail verdict with justification.


**DX/Refactor focus:**
- Verify existing tests still pass after refactoring.
- Test new public API surface for completeness.
- Validate code-generation output if applicable.
- Ensure migration-guide examples compile and run.


## Specialist Considerations

Also consider the perspective of these specialists: DevOps / SRE, Technical Writer. Apply their domain expertise where relevant.

IMPORTANT: You MUST respond with ONLY a JSON object. No markdown, no code fences, no prose, no explanation. Start your response with { and end with }.

# Verification Phase

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

## Requirement Atoms to Verify

- [ ] REQ-0002: [Package Structure](#package-structure)

Every item above must be verified individually. Do not skip any.

## Changed Files (STRICT SCOPE)

CRITICAL: You MUST ONLY read the files listed below. Do NOT explore, search, or read any other files in the codebase. Base your verification ENTIRELY on the diff content and these changed files.

- `.broins/tmp/drivers/claude/last_invocation.txt`
- `.broins/tmp/drivers/claude/last_pid.txt`
- `.broins/tmp/drivers/claude/last_raw_stream.jsonl`
- `.broins/work/autopilot/ap-1773727433798/verification/epic-EPIC-0004-cycle-1.json`
- `.broins/work/backlog.json`
- `.broins/work/runs/run-1773742677889/context/repo_digest.md`
- `.broins/work/runs/run-1773742677889/events.jsonl`
- `.broins/work/runs/run-1773742677889/sentinel_FV-1-373.txt`
- `.broins/work/runs/run-1773742677889/wi/FV-1-373/classification.json`
- `.broins/work/runs/run-1773742677889/wi/FV-1-373/events.jsonl`
- `.broins/work/runs/run-1773742677889/wi/FV-1-373/prompts/implement.md`
- `.broins/work/runs/run-1773742677889/wi/FV-1-373/prompts/plan.md`
- `.broins/work/runs/run-1773742677889/wi/FV-1-373/prompts/plan_retry.md`
- `.broins/work/runs/run-1773742677889/wi/FV-1-373/prompts/self_critique.md`
- `.broins/work/runs/run-1773742677889/wi/FV-1-373/results/implement.json`
- `.broins/work/runs/run-1773742677889/wi/FV-1-373/task_packet.json`
- `lib/src/layouts/.gitkeep`
- `lib/src/theme/.gitkeep`
- `lib/src/widgets/.gitkeep`

## Diff Content

```diff
diff --git a/.broins/tmp/drivers/claude/last_invocation.txt b/.broins/tmp/drivers/claude/last_invocation.txt
index 962dc13..a101086 100644
--- a/.broins/tmp/drivers/claude/last_invocation.txt
+++ b/.broins/tmp/drivers/claude/last_invocation.txt
@@ -1,6 +1,6 @@
-timestamp: 2026-03-17T10:02:14.812434Z
+timestamp: 2026-03-17T10:23:40.370700Z
 executable: claude
-args: --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
-prompt_length: 21916 chars (~5479 tokens)
+args: --max-turns 30 --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
+prompt_length: 498 chars (~124 tokens)
 timeout: 1800s
 working_directory: /home/simonerich/Flutters/obers_ui
diff --git a/.broins/tmp/drivers/claude/last_pid.txt b/.broins/tmp/drivers/claude/last_pid.txt
index 5bc304f..dee0097 100644
--- a/.broins/tmp/drivers/claude/last_pid.txt
+++ b/.broins/tmp/drivers/claude/last_pid.txt
@@ -1 +1 @@
-935860
+965296
diff --git a/.broins/tmp/drivers/claude/last_raw_stream.jsonl b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
index 37cbd48..081c23f 100644
--- a/.broins/tmp/drivers/claude/last_raw_stream.jsonl
+++ b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
@@ -1,220 +1,96 @@
-{"type":"system","subtype":"init","cwd":"/home/simonerich/Flutters/obers_ui","session_id":"c5481fa8-923a-483f-a7a8-06f047c0ff9c","tools":["Task","TaskOutput","Bash","Glob","Grep","ExitPlanMode","Read","Edit","Write","NotebookEdit","WebFetch","TodoWrite","WebSearch","TaskStop","AskUserQuestion","Skill","EnterPlanMode","EnterWorktree","ExitWorktree","CronCreate","CronDelete","CronList","ToolSearch"],"mcp_servers":[],"model":"claude-sonnet-4-6","permissionMode":"bypassPermissions","slash_commands":["keybindings-help","debug","simplify","batch","loop","claude-api","compact","context","cost","heapdump","init","pr-comments","release-notes","review","security-review","extra-usage","insights"],"apiKeySource":"none","claude_code_version":"2.1.72","output_style":"default","agents":["general-purpose","statusline-setup","Explore","Plan"],"skills":["keybindings-help","debug","simplify","batch","loop","claude-api"],"plugins":[],"uuid":"61e4c28f-f28d-4835-8b42-6fb5bdd4154e","fast_mode_state":"off"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_01LrzwdKgWAVYDPS8m7LFDGr","type":"message","role":"assistant","content":[{"type":"thinking","thinking":"I need to review the changed files to assess coverage of each requirement atom. Let me read the key files to understand what's been implemented.\n\nLet me start by reading some of the most important files to understand the structure and implementation.","signature":"EqEDCkYICxgCKkB2XK6N62iLLYVQkNZAVmBzhD6ML+q4efCGIg0iHXHptSxkO0IW9hTT7hCsx1Osc/xlG13Gbdw2x2z8zP1MjrQoEgw+aiPGSm7KQ83glN8aDEcBIx+ZLDbrIqX12yIwrPQoJ/hrl1i/6c1GkNS93XfM031LvDqFlv91MRgTOlWpNOGTWg6w8ZR2Pxic9nYPKogCRj28se67HaXCu0Bp0WQaW6ANLBoKREmhcZ52UIkHGzQd47fvTETHe53mgdUQxyDmpBgWjBGRqDV6TxGEGL5jU1xMDvR919uYHvo5jV78MeMyDgQMCNybwAW3eDhIVkG7KvTOrlb/zNVxiFDhFgLHjwS7h9j16s3M9vmfW+i7KcCWZgru1oUE3JOhgHNVGiS8xATOVHRFoseuzT6UTp0lnDXUIQDScqTgTOMT8gTLenYq0tyKCF3Xl5Eh9u7xDWmPtOFf0pFwUY4ygLznXgj9Gna6yaM0Tr31jtJhcJOMXBOmf6F8VxskIL6xUlANifZhYd1Hl/+PW0HZnHpgD/eB4Q7calfQH/X7GAE="}],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":2,"cache_creation_input_tokens":22402,"cache_read_input_tokens":8567,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":22402},"output_tokens":7,"service_tier":"standard","inference_geo":"not_available"},"context_management":null},"parent_tool_use_id":null,"session_id":"c5481fa8-923a-483f-a7a8-06f047c0ff9c","uuid":"140d4a5e-b945-4bcf-9a25-dbdf7c844e9e"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_01LrzwdKgWAVYDPS8m7LFDGr","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_013F5ztK1wuHYRB4Viucvs4v","name":"Agent","input":{"description":"Review changed files for epic QA","subagent_type":"Explore","prompt":"Read these specific files and report their contents thoroughly. I need to assess coverage of requirements for a QA review. Read ONLY these files:\n\n1. lib/obers_ui.dart\n2. lib/src/foundation/theme/oi_theme_data.dart\n3. lib/src/foundation/oi_accessibility.dart\n4. lib/src/foundation/theme/oi_theme.dart\n5. lib/src/foundation/theme/oi_color_scheme.dart\n6. lib/src/foundation/theme/oi_text_theme.dart\n7. lib/src/foundation/theme/oi_spacing_scale.dart\n8. lib/src/foundation/theme/oi_animation_config.dart\n9. lib/src/foundation/theme/oi_component_themes.dart\n10. lib/src/foundation/theme/oi_decoration_theme.dart\n11. lib/src/foundation/theme/oi_effects_theme.dart\n12. lib/src/foundation/theme/oi_shadow_scale.dart\n13. lib/src/foundation/theme/oi_color_swatch.dart\n14. test/src/naming_conventions_test.dart\n15. lib/src/tools/oi_dynamic_theme.dart\n16. lib/src/tools/oi_playground.dart\n17. lib/src/tools/oi_theme_exporter.dart\n18. lib/src/tools/oi_theme_preview.dart\n\nFor each file, report:\n- File path\n- Key classes/widgets defined\n- Key properties/features present\n- Any notable patterns\n\nBe thorough and complete."},"caller":{"type":"direct"}}],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":2,"cache_creation_input_tokens":22402,"cache_read_input_tokens":8567,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":22402},"output_tokens":7,"service_tier":"standard","inference_geo":"not_available"},"context_management":null},"parent_tool_use_id":null,"session_id":"c5481fa8-923a-483f-a7a8-06f047c0ff9c","uuid":"c4d2e4bb-77eb-4242-b8ba-20083120d68a"}
-{"type":"system","subtype":"task_started","task_id":"a540c97ff84e853ce","tool_use_id":"toolu_013F5ztK1wuHYRB4Viucvs4v","description":"Review changed files for epic QA","task_type":"local_agent","prompt":"Read these specific files and report their contents thoroughly. I need to assess coverage of requirements for a QA review. Read ONLY these files:\n\n1. lib/obers_ui.dart\n2. lib/src/foundation/theme/oi_theme_data.dart\n3. lib/src/foundation/oi_accessibility.dart\n4. lib/src/foundation/theme/oi_theme.dart\n5. lib/src/foundation/theme/oi_color_scheme.dart\n6. lib/src/foundation/theme/oi_text_theme.dart\n7. lib/src/foundation/theme/oi_spacing_scale.dart\n8. lib/src/foundation/theme/oi_animation_config.dart\n9. lib/src/foundation/theme/oi_component_themes.dart\n10. lib/src/foundation/theme/oi_decoration_theme.dart\n11. lib/src/foundation/theme/oi_effects_theme.dart\n12. lib/src/foundation/theme/oi_shadow_scale.dart\n13. lib/src/foundation/theme/oi_color_swatch.dart\n14. test/src/naming_conventions_test.dart\n15. lib/src/tools/oi_dynamic_theme.dart\n16. lib/src/tools/oi_playground.dart\n17. lib/src/tools/oi_theme_exporter.dart\n18. lib/src/tools/oi_theme_preview.dart\n\nFor each file, report:\n- File path\n- Key classes/widgets defined\n- Key properties/features present\n- Any notable patterns\n\nBe thorough and complete.","uuid":"37ec8625-97d9-4fa5-86be-5ffe6cdb2e76","session_id":"c5481fa8-923a-483f-a7a8-06f047c0ff9c"}
-{"type":"user","message":{"role":"user","content":[{"type":"text","text":"Read these specific files and report their contents thoroughly. I need to assess coverage of requirements for a QA review. Read ONLY these files:\n\n1. lib/obers_ui.dart\n2. lib/src/foundation/theme/oi_theme_data.dart\n3. lib/src/foundation/oi_accessibility.dart\n4. lib/src/foundation/theme/oi_theme.dart\n5. lib/src/foundation/theme/oi_color_scheme.dart\n6. lib/src/foundation/theme/oi_text_theme.dart\n7. lib/src/foundation/theme/oi_spacing_scale.dart\n8. lib/src/foundation/theme/oi_animation_config.dart\n9. lib/src/foundation/theme/oi_component_themes.dart\n10. lib/src/foundation/theme/oi_decoration_theme.dart\n11. lib/src/foundation/theme/oi_effects_theme.dart\n12. lib/src/foundation/theme/oi_shadow_scale.dart\n13. lib/src/foundation/theme/oi_color_swatch.dart\n14. test/src/
[truncated]
```


## Task Packet (living document)

## Task Packet Summary
Work Item: FV-1-373 — verifying
Classification: dx
Specialists: dx_engineer, qa_engineer, technical_writer, frontend_architect

### Plan (v1)
## Plan

### Concept
Remove three empty placeholder directories (`lib/src/layouts/`, `lib/src/theme/`, `lib/src/widgets/`) that exist in git via `.gitkeep` files but have no Dart content and are absent from the spec-defined hierarchy (foundation, primitives, components, composites, modules, tools, utils). Removing them aligns the on-disk package structure exactly with the spec, resolving the only outstanding structural issue.

### Key Design Decisions & Rationale

| Decision | Rationale |
|---|---|
| Delete `.gitkeep` files, not move/rename | The spec hierarchy omits layouts/, theme/, widgets/ entirely — no stub barrel needed |
| Leave `persistence/` and `oi_platform.dart` untouched | Marked "additive, not breaking" in the work item; removal would be a breaking API change |
| No barrel-export changes | `lib/obers_ui.dart` has no sections for layouts, top-level theme, or widgets — no import cleanup required |

**Potential risk:** If any future EPIC adds layouts/widgets/theme tiers, the directories will need to be re-created. Mitigation: that is a separate work item; out of scope here.

---

### Sub-tasks
- **ST1:** Delete `lib/src/layouts/.gitkeep` — removes the empty `layouts/` placeholder
- **ST2:** Delete `lib/src/theme/.gitkeep` — removes the empty top-level `theme/` placeholder (distinct from `lib/src/foundation/theme/` which is populated)
- **ST3:** Delete `lib/src/widgets/.gitkeep` — removes the empty `widgets/` placeholder
- **ST4:** Run `dart analyze lib/` to confirm zero new errors introduced

---

### Method signatures
No new classes or methods. No existing signatures changed.

---

### Edge cases and fallbacks

| Edge case | Handling |
|---|---|
| Git still shows empty dir after `.gitkeep` removal | Git auto-prunes untracked empty dirs; no manual action needed |
| Another file accidentally in those dirs | Check with `ls` before deletion; abort ST if dir is non-empty |
| `lib/obers_ui.dart` references removed dirs | Pre-check with grep; none exist — safe t
... [truncated, 6684 chars total]

### Implementation Notes
Deleted three empty placeholder directories (layouts/, theme/, widgets/) that existed only via .gitkeep files and are absent from the spec-defined hierarchy. dart analyze shows 80 pre-existing info-level lint issues, zero errors or warnings introduced by this change. lib/obers_ui.dart has no references to the removed paths.

### Test Runner Results
(none yet)

### Previous Iterations (0)
(none)


## Instructions

Verify each requirement atom individually. For each atom:

- **covered**: every sub-requirement is implemented with citable evidence.
- **partial**: some parts exist but others are missing, stubbed, or placeholder.
- **missing**: the requirement is not implemented.

For each atom you MUST provide at least one evidence entry with a file path and line range (e.g. `lib/auth/login.dart:42-58`). If you cannot find evidence, mark as "missing" and explain in missingDetails which specific file should contain the implementation.

Every atom listed above MUST have a corresponding entry in atomResults. If you cannot verify an atom, include it with status "missing" — never omit atoms.

Also write your verification results to `.broins/work/runs/run-1773742677889/wi/FV-1-373/results/verify.json`.

## Required JSON Output Format

Respond with EXACTLY this structure (concrete example):

{
  "atomResults": [
    {
      "atomId": "REQ-0002",
      "status": "covered",
      "evidence": ["lib/example.dart:10-20"],
      "missingDetails": null,
      "recommendedFix": null
    }
  ],
  "overallStatus": "pass",
  "notes": "All requirements verified"
}

Use overallStatus "pass" only when ALL atoms have status "covered".

BEGIN JSON OUTPUT:
