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

Also consider the perspective of these specialists: DevOps / SRE, UX/UI Expert, Technical Writer. Apply their domain expertise where relevant.

IMPORTANT: You MUST respond with ONLY a JSON object. No markdown, no code fences, no prose, no explanation. Start your response with { and end with }.

# Verification Phase

## Work Item: Naming Conventions (Part 1/2)

**ID:** WI-0064
**Description:** - Naming & Conventions: Name by what it _is_ in the UI. `OiTable`, `OiButton`, `OiSidebar`.
- Naming & Conventions: Props read like English. `multiSelect: true`, `reorderColumns: true`, `stickyHeader: true`.
- Naming & Conventions: Required props enforce correctness. Images require `alt`, buttons require `label`.
**Risk:** medium

### Definition of Done

- [ ] Atom REQ-0012 fully implemented: Naming & Conventions: Name by what it _is_ in the UI. `OiTable`, `OiButton`, `OiSidebar`.
- [ ] Atom REQ-0013 fully implemented: Naming & Conventions: Props read like English. `multiSelect: true`, `reorderColumns: true`, `stickyHeader: true`.
- [ ] Atom REQ-0014 fully implemented: Naming & Conventions: Required props enforce correctness. Images require `alt`, buttons require `label`.
- [ ] All project checks pass (format, analyze, test)
- [ ] Coverage ledger updated for all atoms

## Requirement Atoms to Verify

- [ ] REQ-0012: Name by what it _is_ in the UI. `OiTable`, `OiButton`, `OiSidebar`.
- [ ] REQ-0013: Props read like English. `multiSelect: true`, `reorderColumns: true`, `stickyHeader: true`.
- [ ] REQ-0014: Required props enforce correctness. Images require `alt`, buttons require `label`.

Every item above must be verified individually. Do not skip any.

## Changed Files (STRICT SCOPE)

CRITICAL: You MUST ONLY read the files listed below. Do NOT explore, search, or read any other files in the codebase. Base your verification ENTIRELY on the diff content and these changed files.

- `.broins/tmp/drivers/claude/last_invocation.txt`
- `.broins/tmp/drivers/claude/last_pid.txt`
- `.broins/tmp/drivers/claude/last_raw_stream.jsonl`
- `.broins/work/autopilot/ap-1773727433798/epic-verification-checklist.json`
- `.broins/work/autopilot/ap-1773727433798/verification/epic-EPIC-0001-cycle-1.json`
- `.broins/work/backlog.json`
- `.broins/work/runs/run-1773733505170/sentinel_WI-0007.txt`
- `.broins/work/runs/run-1773733505170/sentinel_WI-0064.txt`
- `.broins/work/runs/run-1773733505170/state.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/classification.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/events.jsonl`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompt_manifest.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/format_correction.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/implement.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/plan.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/verify.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/verify_retry.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/results/verify.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/results/verify_raw_0.txt`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/results/verify_raw_1.txt`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/task_packet.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/classification.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/events.jsonl`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/prompts/implement.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/prompts/plan.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/prompts/qa_fix.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/prompts/self_critique.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/prompts/verify.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/results/verify.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/results/verify_raw_0.txt`
- `.broins/work/runs/run-1773733505170/wi/WI-0064/task_packet.json`
- `lib/src/components/buttons/oi_button_group.dart`
- `lib/src/components/buttons/oi_icon_button.dart`
- `lib/src/components/buttons/oi_toggle_button.dart`
- `lib/src/components/display/oi_diff_view.dart`
- `lib/src/composites/data/oi_tree.dart`
- `lib/src/composites/media/oi_gallery.dart`
- `lib/src/composites/media/oi_lightbox.dart`
- `lib/src/composites/media/oi_video_player.dart`
- `lib/src/composites/onboarding/oi_tour.dart`
- `lib/src/composites/scheduling/oi_timeline.dart`
- `lib/src/composites/search/oi_combo_box.dart`
- `lib/src/composites/search/oi_command_bar.dart`
- `lib/src/composites/search/oi_search.dart`
- `lib/src/composites/workflow/oi_state_diagram.dart`
- `test/src/composites/search/oi_combo_box_test.dart`
- `test/src/composites/search/oi_command_bar_test.dart`

## Diff Content

```diff
diff --git a/.broins/tmp/drivers/claude/last_invocation.txt b/.broins/tmp/drivers/claude/last_invocation.txt
index 427aee5..7004123 100644
--- a/.broins/tmp/drivers/claude/last_invocation.txt
+++ b/.broins/tmp/drivers/claude/last_invocation.txt
@@ -1,6 +1,6 @@
-timestamp: 2026-03-17T08:04:52.179675Z
+timestamp: 2026-03-17T09:19:39.747176Z
 executable: claude
-args: --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
-prompt_length: 12235 chars (~3058 tokens)
+args: --max-turns 10 --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
+prompt_length: 23145 chars (~5786 tokens)
 timeout: 1800s
 working_directory: /home/simonerich/Flutters/obers_ui
diff --git a/.broins/tmp/drivers/claude/last_pid.txt b/.broins/tmp/drivers/claude/last_pid.txt
index 0c678fb..1d1a0df 100644
--- a/.broins/tmp/drivers/claude/last_pid.txt
+++ b/.broins/tmp/drivers/claude/last_pid.txt
@@ -1 +1 @@
-746068
+837928
diff --git a/.broins/tmp/drivers/claude/last_raw_stream.jsonl b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
index bde27cf..131ae9c 100644
--- a/.broins/tmp/drivers/claude/last_raw_stream.jsonl
+++ b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
@@ -1,102 +1,34 @@
-{"type":"system","subtype":"init","cwd":"/home/simonerich/Flutters/obers_ui","session_id":"089a8030-532e-4087-b58e-0b4f404a83ee","tools":["Task","TaskOutput","Bash","Glob","Grep","ExitPlanMode","Read","Edit","Write","NotebookEdit","WebFetch","TodoWrite","WebSearch","TaskStop","AskUserQuestion","Skill","EnterPlanMode","EnterWorktree","ExitWorktree","CronCreate","CronDelete","CronList","ToolSearch"],"mcp_servers":[],"model":"claude-sonnet-4-6","permissionMode":"bypassPermissions","slash_commands":["keybindings-help","debug","simplify","batch","loop","claude-api","compact","context","cost","heapdump","init","pr-comments","release-notes","review","security-review","extra-usage","insights"],"apiKeySource":"none","claude_code_version":"2.1.72","output_style":"default","agents":["general-purpose","statusline-setup","Explore","Plan"],"skills":["keybindings-help","debug","simplify","batch","loop","claude-api"],"plugins":[],"uuid":"d93d9ab2-ff6b-45ad-8c1a-a5e1573cf071","fast_mode_state":"off"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_01GdR5tW1DkJTGrpLCACgpWm","type":"message","role":"assistant","content":[{"type":"thinking","thinking":"Let me read the atoms.json and the key implementation files to assess coverage of each requirement atom.","signature":"EpACCkYICxgCKkCrql9F8Hn96nZ78J8YKiMjz9gL1jeD0BX8xnXaDXOiHoWwGB9AZQ+PuYi4LQyc3BGf+TG4ng3ttelUtEjqV82UEgwaSoNtadIDQfmqIwsaDP0/GcQoHwpIbFlZ0iIwGCkAIdpXxkUziUEP6wRzDNKd6udgDPhGwhJx8VshPwppnZWNOTQBUs2uhznJINakKngkGDKZeH6Ai0ia26YRpdPoj6ig5a+9vxTQrog2LOTJBmbPBiSyPRGav20us6GGMPuSefExpAJDCmaJcSKwb6YQzSBxV6niwMRHSi1A8nPq2qnN59TgNwGrnjKY7hjP+OQuKgrJrdl4IBRYMUH1RlbYsDGIkfZBPYQYAQ=="}],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":2,"cache_creation_input_tokens":13479,"cache_read_input_tokens":8567,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":13479},"output_tokens":8,"service_tier":"standard","inference_geo":"not_available"},"context_management":null},"parent_tool_use_id":null,"session_id":"089a8030-532e-4087-b58e-0b4f404a83ee","uuid":"54bc0760-2d4c-4a0a-b989-b80531e80fb3"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_01GdR5tW1DkJTGrpLCACgpWm","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_01NF8S7uG6uYWuzuVNq3mU5S","name":"Agent","input":{"description":"QA review of accessibility atoms","subagent_type":"Explore","prompt":"Read the following files and return their FULL contents. I need to review accessibility implementation across all these files. Read ALL of them:\n\n1. /home/simonerich/Flutters/obers_ui/.broins/requirements/atoms.json\n2. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_button.dart\n3. /home/simonerich/Flutters/obers_ui/lib/src/composites/editors/oi_rich_editor.dart\n4. /home/simonerich/Flutters/obers_ui/lib/src/composites/editors/oi_smart_input.dart\n5. /home/simonerich/Flutters/obers_ui/lib/src/composites/forms/oi_form.dart\n6. /home/simonerich/Flutters/obers_ui/lib/src/composites/forms/oi_stepper.dart\n7. /home/simonerich/Flutters/obers_ui/lib/src/composites/forms/oi_wizard.dart\n8. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_gallery.dart\n9. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_image_cropper.dart\n10. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_lightbox.dart\n11. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_video_player.dart\n12. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_arrow_nav.dart\n13. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_filter_bar.dart\n14. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_nav_menu.dart\n15. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_shortcuts.dart\n16. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_sidebar.dart\n17. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_spotlight.dart\n18. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_tour.dart\n19. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_whats_new.dart\n20. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_calendar.dart\n21. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_gantt.dart\n22. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_timeline.dart\n23. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_combo_box.dart\n24. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_command_bar.dart\n25. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_search.dart\n26. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_avatar_stack.dart\n27. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_cursor_presence.dart\n28. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_live_ring.dart\n29. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_selection_presence.dart\n30. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_typing_indicator.dart\n31. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_funnel_chart.dart\n32. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_gauge.dart\n33. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_heatmap.dart\n34. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_radar_chart.dart\n35. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_sankey.dart\n36. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_treemap.dart\n37. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_flow_graph.dart\n38. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_pipeline.dart\n39. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_state_diagram.dart\n40. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_activity_feed.dart\n41. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_chat.dart\n42. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_comments.dart\n43. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_dashboard.dart\n44. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_file_manager.dart\n45. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_kanban.dart\n46. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_list_view.dart\n47. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_metadata_editor.dart\n48. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_notification_center.dart\n49. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_permissions.dart
[truncated]
```


## Task Packet (living document)

## Task Packet Summary
Work Item: WI-0064 — qa_not_ready
Classification: dx
Specialists: dx_engineer, frontend_architect, qa_engineer, ux_researcher, technical_writer

### Plan (v1)
Now I have enough context to write a comprehensive implementation plan. Let me produce it.

---

## Implementation Plan: WI-0064 — Naming Conventions (Part 1/2)

---

### Concept

This work item establishes and enforces a uniform naming convention across the Obers UI library: every public widget is named `OiXxx` after what it represents in the UI, every boolean prop reads as natural English without `is`/`has` prefixes, and structural props on image/button widgets are required to prevent accessibility errors at compile time.

---

### Sub-tasks

- **ST1** — Audit all public widget class names for `Oi` prefix compliance; produce a coverage note (no code changes expected; current state is 100% compliant)
- **ST2** — Rename all `is`/`has`-prefixed boolean props on public widget and data-model constructors across the library
- **ST3** — Audit all button-like widgets (`OiButton`, `OiIconButton`, `OiToggleButton`, `OiButtonGroup`) to verify `label`/`semanticLabel` is `required`; fix any gaps
- **ST4** — Audit all image-like widgets (`OiImage`, `OiAvatar`) to verify `alt` or equivalent accessibility string is `required`; fix any gaps
- **ST5** — Run `dart analyze` and all project checks; fix any cascade failures from renames

---

### Method signatures

Each rename below is a field declaration on a public API class. Changed signatures use the final name:

```dart
// OiButtonGroup - ST2
final bool selected;           // was isSelected

// OiTree data model - ST2
final bool leaf;               // was isLeaf

// OiDiffView line descriptor - ST2
final bool added;              // was isAdded
final bool removed;            // was isRemoved
final bool unchanged;          // was isContext (avoids collision with BuildContext)

// OiStateDiagram node descriptor - ST2
final bool initial;            // was isInitial
final bool terminal;           // was isFinal  (final is a Dart keyword — must rename)

// OiTimeline item descriptor - ST2
final bool leftAligned;        // was isLeft
fin
... [truncated, 21790 chars total]

### Implementation Notes
(none yet)

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

Also write your verification results to `.broins/work/runs/run-1773733505170/wi/WI-0064/results/verify.json`.

## Required JSON Output Format

Respond with EXACTLY this structure (concrete example):

{
  "atomResults": [
    {
      "atomId": "REQ-0012",
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
