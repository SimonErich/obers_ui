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

Also consider the perspective of these specialists: DevOps / SRE, Technical Writer, UX/UI Expert. Apply their domain expertise where relevant.

IMPORTANT: You MUST respond with ONLY a JSON object. No markdown, no code fences, no prose, no explanation. Start your response with { and end with }.

# Verification Phase

## Work Item: Fix: Booleans are descriptive

**ID:** FV-1-373
**Description:** Boolean parameters use descriptive adjective/noun names (enabled, dismissible, searchable, loading) rather than is/has-prefixed names.

Issues found during full verification:
lib/src/primitives/scroll/oi_infinite_scroll.dart:38 — public widget OiInfiniteScroll has `hasMore` prop; should be `moreAvailable`; lib/src/modules/oi_list_view.dart:134 — public widget OiListView has `hasMore` prop; should be `moreAvailable`; lib/src/modules/oi_activity_feed.dart:90 — public widget OiActivityFeed has `hasMore` prop; should be `moreAvailable`; lib/src/modules/oi_activity_feed.dart:221 — internal _OiActivityFeedState uses `hasMore`; should be `moreAvailable`; lib/src/modules/oi_chat.dart:153 — public widget OiChat has `hasOlderMessages` prop; should be `olderMessagesAvailable`; lib/src/modules/oi_file_manager.dart:26 — public data class OiFileNode has `isFolder`; should be `folder`; lib/src/foundation/oi_platform.dart:29 — public data class OiPlatformData has `isKeyboardVisible`; should be `keyboardVisible`; lib/src/foundation/theme/oi_decoration_theme.dart:219 — public class OiGradient has `isLinear`; should be `linear`; No dedicated naming-convention tests exist — no test file validates boolean naming discipline; Coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 are absent from the EPIC-0003 commit (only REQ-0012, REQ-0013, REQ-0014 have tracking files)

Current implementation: 62%

Relevant files:
- lib/src/components/buttons/oi_button.dart (loading, disabled, fullWidth — correct)
- lib/src/composites/data/oi_table.dart (sortable, resizable, multiSelect — correct)
- lib/src/composites/media/oi_video_player.dart:37 (autoPlay — correct)
**Risk:** medium

### Definition of Done

- [ ] All issues resolved: lib/src/primitives/scroll/oi_infinite_scroll.dart:38 — public widget OiInfiniteScroll has `hasMore` prop; should be `moreAvailable`; lib/src/modules/oi_list_view.dart:134 — public widget OiListView has `hasMore` prop; should be `moreAvailable`; lib/src/modules/oi_activity_feed.dart:90 — public widget OiActivityFeed has `hasMore` prop; should be `moreAvailable`; lib/src/modules/oi_activity_feed.dart:221 — internal _OiActivityFeedState uses `hasMore`; should be `moreAvailable`; lib/src/modules/oi_chat.dart:153 — public widget OiChat has `hasOlderMessages` prop; should be `olderMessagesAvailable`; lib/src/modules/oi_file_manager.dart:26 — public data class OiFileNode has `isFolder`; should be `folder`; lib/src/foundation/oi_platform.dart:29 — public data class OiPlatformData has `isKeyboardVisible`; should be `keyboardVisible`; lib/src/foundation/theme/oi_decoration_theme.dart:219 — public class OiGradient has `isLinear`; should be `linear`; No dedicated naming-convention tests exist — no test file validates boolean naming discipline; Coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 are absent from the EPIC-0003 commit (only REQ-0012, REQ-0013, REQ-0014 have tracking files)
- [ ] Implementation reaches 100% for: Booleans are descriptive
- [ ] All related tests pass

## Requirement Atoms to Verify

- [ ] REQ-0017: Booleans are descriptive. `enabled`, `dismissible`, `searchable`, `loading`.

Every item above must be verified individually. Do not skip any.

## Changed Files (STRICT SCOPE)

CRITICAL: You MUST ONLY read the files listed below. Do NOT explore, search, or read any other files in the codebase. Base your verification ENTIRELY on the diff content and these changed files.

- `.broins/tmp/drivers/claude/last_invocation.txt`
- `.broins/tmp/drivers/claude/last_pid.txt`
- `.broins/tmp/drivers/claude/last_raw_stream.jsonl`
- `.broins/work/autopilot/ap-1773727433798/verification/epic-EPIC-0003-cycle-1.json`
- `.broins/work/backlog.json`
- `.broins/work/runs/run-1773739762740/context/repo_digest.md`
- `.broins/work/runs/run-1773739762740/events.jsonl`
- `.broins/work/runs/run-1773739762740/sentinel_FV-1-373.txt`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/classification.json`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/events.jsonl`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/implement.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/plan.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/qa_fix.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/self_critique.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/verify.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/results/implement.json`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/results/verify.json`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/results/verify_raw_0.txt`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/task_packet.json`
- `lib/obers_ui.dart`
- `lib/src/components/buttons/oi_icon_button.dart`
- `lib/src/components/inputs/oi_radio.dart`
- `lib/src/components/inputs/oi_select.dart`
- `lib/src/composites/media/oi_image_annotator.dart`
- `lib/src/composites/scheduling/oi_scheduler.dart`
- `lib/src/foundation/oi_platform.dart`
- `lib/src/foundation/theme/oi_decoration_theme.dart`
- `lib/src/modules/oi_activity_feed.dart`
- `lib/src/modules/oi_chat.dart`
- `lib/src/modules/oi_file_manager.dart`
- `lib/src/modules/oi_list_view.dart`
- `lib/src/primitives/scroll/oi_infinite_scroll.dart`
- `lib/src/tools/oi_dynamic_theme.dart`
- `lib/src/tools/oi_playground.dart`
- `lib/src/tools/oi_theme_exporter.dart`
- `test/src/components/buttons/oi_button_test.dart`
- `test/src/components/buttons/oi_icon_button_test.dart`
- `test/src/components/buttons/oi_toggle_button_test.dart`
- `test/src/components/display/oi_diff_view_test.dart`
- `test/src/components/inputs/oi_radio_test.dart`
- `test/src/components/inputs/oi_select_test.dart`
- `test/src/composites/media/oi_image_annotator_test.dart`
- `test/src/composites/scheduling/oi_scheduler_test.dart`
- `test/src/composites/workflow/oi_state_diagram_test.dart`
- `test/src/foundation/theme/oi_decoration_theme_test.dart`
- `test/src/modules/oi_file_manager_test.dart`
- `test/src/naming_conventions_test.dart`
- `test/src/primitives/scroll/oi_infinite_scroll_test.dart`
- `test/src/tools/oi_dynamic_theme_test.dart`
- `test/src/tools/oi_playground_test.dart`

## Diff Content

```diff
diff --git a/.broins/tmp/drivers/claude/last_invocation.txt b/.broins/tmp/drivers/claude/last_invocation.txt
index 3fae4a3..e09809a 100644
--- a/.broins/tmp/drivers/claude/last_invocation.txt
+++ b/.broins/tmp/drivers/claude/last_invocation.txt
@@ -1,6 +1,6 @@
-timestamp: 2026-03-17T09:23:08.745844Z
+timestamp: 2026-03-17T09:46:42.047477Z
 executable: claude
-args: --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
-prompt_length: 5398 chars (~1349 tokens)
+args: --max-turns 10 --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
+prompt_length: 5026 chars (~1256 tokens)
 timeout: 1800s
 working_directory: /home/simonerich/Flutters/obers_ui
diff --git a/.broins/tmp/drivers/claude/last_pid.txt b/.broins/tmp/drivers/claude/last_pid.txt
index 9b3cfc7..19dbe7e 100644
--- a/.broins/tmp/drivers/claude/last_pid.txt
+++ b/.broins/tmp/drivers/claude/last_pid.txt
@@ -1 +1 @@
-843510
+885739
diff --git a/.broins/tmp/drivers/claude/last_raw_stream.jsonl b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
index dea1db7..87d953b 100644
--- a/.broins/tmp/drivers/claude/last_raw_stream.jsonl
+++ b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
@@ -1,88 +1,56 @@
-{"type":"system","subtype":"init","cwd":"/home/simonerich/Flutters/obers_ui","session_id":"46c69f4e-82d2-4fc9-8517-493f85f31b6e","tools":["Task","TaskOutput","Bash","Glob","Grep","ExitPlanMode","Read","Edit","Write","NotebookEdit","WebFetch","TodoWrite","WebSearch","TaskStop","AskUserQuestion","Skill","EnterPlanMode","EnterWorktree","ExitWorktree","CronCreate","CronDelete","CronList","ToolSearch"],"mcp_servers":[],"model":"claude-sonnet-4-6","permissionMode":"bypassPermissions","slash_commands":["keybindings-help","debug","simplify","batch","loop","claude-api","compact","context","cost","heapdump","init","pr-comments","release-notes","review","security-review","extra-usage","insights"],"apiKeySource":"none","claude_code_version":"2.1.72","output_style":"default","agents":["general-purpose","statusline-setup","Explore","Plan"],"skills":["keybindings-help","debug","simplify","batch","loop","claude-api"],"plugins":[],"uuid":"ae532583-2a1a-4db5-9102-2a6949e83fad","fast_mode_state":"off"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_019EUxKkmqyJzQX1QFMf7LL8","type":"message","role":"assistant","content":[{"type":"thinking","thinking":"Let me read the changed files to assess coverage of each requirement atom. I'll focus on the Dart source files and test files since those are most likely to contain evidence of the naming conventions.","signature":"EvECCkYICxgCKkAe2NhwEvo1QxVR9BC6h9v81PkHIk5TqukdjKhtWYMpBo+uMF3QHJyuRAyO671EDEo8PfeiufD7Hpl6VQ/6kHWBEgzLzqGjdzrnna9jAVIaDEzwtv5n+EMB2JirtCIwKr7GyEkQj1WKjrdx1g9RH2c4/rrQWO/r6+h0n7qk3NcRA2wLDWGsvSc01JYf3dA0KtgB+i1LiCWxQNuvvzLtwb+UYX3rsfec3mtws/zQBAIzvr42GQrp8ulG6tvUs8jPzWiMGyML2OUyi8WmR20LFYtK15SYpV0I5h/82wy6uzMxMialC2EVHPSO2DKyvlpCem124VhTiBZc4sHyQgvSo8qCy2ESEqkLRlXKngRsKd1BnPPOiWRYbOKxusNGi9aa9j9b4S/IBz29Ql21yViwW1gR/YqfInGcSq2aNc/Q63BTw68ED8owmtUSgNI1oazvxTqMJN3V2jmEy5RFG+Ro2tTDkGo7JbvHPFtwGAE="}],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":2,"cache_creation_input_tokens":9499,"cache_read_input_tokens":8567,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":9499},"output_tokens":8,"service_tier":"standard","inference_geo":"not_available"},"context_management":null},"parent_tool_use_id":null,"session_id":"46c69f4e-82d2-4fc9-8517-493f85f31b6e","uuid":"bc66e7c5-47cf-4613-9c55-2744c044a5f5"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_019EUxKkmqyJzQX1QFMf7LL8","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_01L9oWRHmYdDJfxC4pgYAVTK","name":"Agent","input":{"description":"Read all changed Dart files for QA review","subagent_type":"Explore","prompt":"Read ALL of the following files completely and return their full contents. Do not summarize - return the actual file contents with line numbers for each file:\n\n1. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_button_group.dart\n2. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_icon_button.dart\n3. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_toggle_button.dart\n4. /home/simonerich/Flutters/obers_ui/lib/src/components/display/oi_diff_view.dart\n5. /home/simonerich/Flutters/obers_ui/lib/src/composites/data/oi_tree.dart\n6. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_gallery.dart\n7. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_lightbox.dart\n8. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_video_player.dart\n9. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_tour.dart\n10. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_timeline.dart\n11. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_combo_box.dart\n12. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_command_bar.dart\n13. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_search.dart\n14. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_state_diagram.dart\n15. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_combo_box_test.dart\n16. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_command_bar_test.dart\n17. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_search_test.dart\n18. /home/simonerich/Flutters/obers_ui/test/src/modules/oi_file_manager_test.dart\n\nReturn the full content of each file with line numbers."},"caller":{"type":"direct"}}],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":2,"cache_creation_input_tokens":9499,"cache_read_input_tokens":8567,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":9499},"output_tokens":8,"service_tier":"standard","inference_geo":"not_available"},"context_management":null},"parent_tool_use_id":null,"session_id":"46c69f4e-82d2-4fc9-8517-493f85f31b6e","uuid":"c3625c66-1fbb-4378-89f5-80f28302d94b"}
-{"type":"system","subtype":"task_started","task_id":"a35c1fd28f4f6ef32","tool_use_id":"toolu_01L9oWRHmYdDJfxC4pgYAVTK","description":"Read all changed Dart files for QA review","task_type":"local_agent","prompt":"Read ALL of the following files completely and return their full contents. Do not summarize - return the actual file contents with line numbers for each file:\n\n1. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_button_group.dart\n2. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_icon_button.dart\n3. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_toggle_button.dart\n4. /home/simonerich/Flutters/obers_ui/lib/src/components/display/oi_diff_view.dart\n5. /home/simonerich/Flutters/obers_ui/lib/src/composites/data/oi_tree.dart\n6. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_gallery.dart\n7. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_lightbox.dart\n8. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_video_player.dart\n9. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_tour.dart\n10. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_timeline.dart\n11. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_combo_box.dart\n12. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_command_bar.dart\n13. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_search.dart\n14. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_state_diagram.dart\n15. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_combo_box_test.dart\n16. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_command_bar_test.dart\n17. /home/simonerich/Flutters/obers_ui/test/src/composites/sear
[truncated]
```


## Task Packet (living document)

## Task Packet Summary
Work Item: FV-1-373 — qa_not_ready
Classification: dx
Specialists: dx_engineer, qa_engineer, technical_writer, frontend_architect, backend_architect

### Plan (v1)
Now let me check existing tests and the tracking JSON structure:

### Implementation Notes
Renamed OiSelectOption.disabled (default false) → OiSelectOption.enabled (default true) and OiRadioOption.disabled (default false) → OiRadioOption.enabled (default true). Flipped all internal boolean logic accordingly. Updated tests to use enabled: false instead of disabled: true. OiButton.enabled, OiButton.loading, OiSheet.dismissible, OiPanel.dismissible, OiSwipeable.dismissible, OiSelect.searchable, and OiSelect.enabled were already correctly named. All 62 tests pass.

### Test Runner Results
(none yet)

### Previous Iterations (1)
- Iteration 0: qa_not_ready — {"atomResults":[{"atomId":"REQ-0017","status":"partial","evidence":["lib/src/components/inputs/oi_select.dart:17-27","lib/src/components/inputs/oi_select.dart:49-83","lib/src/components/inputs/oi_radi


## Instructions

Verify each requirement atom individually. For each atom:

- **covered**: every sub-requirement is implemented with citable evidence.
- **partial**: some parts exist but others are missing, stubbed, or placeholder.
- **missing**: the requirement is not implemented.

For each atom you MUST provide at least one evidence entry with a file path and line range (e.g. `lib/auth/login.dart:42-58`). If you cannot find evidence, mark as "missing" and explain in missingDetails which specific file should contain the implementation.

Every atom listed above MUST have a corresponding entry in atomResults. If you cannot verify an atom, include it with status "missing" — never omit atoms.

Also write your verification results to `.broins/work/runs/run-1773739762740/wi/FV-1-373/results/verify.json`.

## Required JSON Output Format

Respond with EXACTLY this structure (concrete example):

{
  "atomResults": [
    {
      "atomId": "REQ-0017",
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
