## QA Engineer Role

You are the **QA Engineer** on this task.
Key focus: - Design the test strategy covering unit, integration, and E2E layers. - Identify edge cases, boundary conditions, and failure scenarios.

IMPORTANT: You MUST respond with ONLY a JSON object. No markdown, no code fences, no prose, no explanation. Start your response with { and end with }.

# Verification Phase

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

## Requirement Atoms to Verify

- [ ] REQ-0493: All Tier 2 input components (`OiTextInput`, `OiNumberInput`, `OiDateInput`, `OiSelect`, etc.)
- [ ] REQ-0494: `OiColumn` (layout)
- [ ] REQ-0495: `OiLabel` (section titles)

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
- `.broins/work/runs/run-1773733505170/wi/WI-0007/classification.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/events.jsonl`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/format_correction.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/implement.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/plan.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/verify.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/prompts/verify_retry.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/results/verify_raw_0.txt`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/results/verify_raw_1.txt`
- `.broins/work/runs/run-1773733505170/wi/WI-0007/task_packet.json`

## Diff Content

```diff
diff --git a/.broins/tmp/drivers/claude/last_invocation.txt b/.broins/tmp/drivers/claude/last_invocation.txt
index 427aee5..7a89193 100644
--- a/.broins/tmp/drivers/claude/last_invocation.txt
+++ b/.broins/tmp/drivers/claude/last_invocation.txt
@@ -1,6 +1,6 @@
-timestamp: 2026-03-17T08:04:52.179675Z
+timestamp: 2026-03-17T08:55:01.176278Z
 executable: claude
-args: --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
-prompt_length: 12235 chars (~3058 tokens)
+args: --max-turns 30 --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
+prompt_length: 3591 chars (~897 tokens)
 timeout: 1800s
 working_directory: /home/simonerich/Flutters/obers_ui
diff --git a/.broins/tmp/drivers/claude/last_pid.txt b/.broins/tmp/drivers/claude/last_pid.txt
index 0c678fb..d8bcd79 100644
--- a/.broins/tmp/drivers/claude/last_pid.txt
+++ b/.broins/tmp/drivers/claude/last_pid.txt
@@ -1 +1 @@
-746068
+802373
diff --git a/.broins/tmp/drivers/claude/last_raw_stream.jsonl b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
index bde27cf..611e235 100644
--- a/.broins/tmp/drivers/claude/last_raw_stream.jsonl
+++ b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
@@ -1,102 +1,3 @@
-{"type":"system","subtype":"init","cwd":"/home/simonerich/Flutters/obers_ui","session_id":"089a8030-532e-4087-b58e-0b4f404a83ee","tools":["Task","TaskOutput","Bash","Glob","Grep","ExitPlanMode","Read","Edit","Write","NotebookEdit","WebFetch","TodoWrite","WebSearch","TaskStop","AskUserQuestion","Skill","EnterPlanMode","EnterWorktree","ExitWorktree","CronCreate","CronDelete","CronList","ToolSearch"],"mcp_servers":[],"model":"claude-sonnet-4-6","permissionMode":"bypassPermissions","slash_commands":["keybindings-help","debug","simplify","batch","loop","claude-api","compact","context","cost","heapdump","init","pr-comments","release-notes","review","security-review","extra-usage","insights"],"apiKeySource":"none","claude_code_version":"2.1.72","output_style":"default","agents":["general-purpose","statusline-setup","Explore","Plan"],"skills":["keybindings-help","debug","simplify","batch","loop","claude-api"],"plugins":[],"uuid":"d93d9ab2-ff6b-45ad-8c1a-a5e1573cf071","fast_mode_state":"off"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_01GdR5tW1DkJTGrpLCACgpWm","type":"message","role":"assistant","content":[{"type":"thinking","thinking":"Let me read the atoms.json and the key implementation files to assess coverage of each requirement atom.","signature":"EpACCkYICxgCKkCrql9F8Hn96nZ78J8YKiMjz9gL1jeD0BX8xnXaDXOiHoWwGB9AZQ+PuYi4LQyc3BGf+TG4ng3ttelUtEjqV82UEgwaSoNtadIDQfmqIwsaDP0/GcQoHwpIbFlZ0iIwGCkAIdpXxkUziUEP6wRzDNKd6udgDPhGwhJx8VshPwppnZWNOTQBUs2uhznJINakKngkGDKZeH6Ai0ia26YRpdPoj6ig5a+9vxTQrog2LOTJBmbPBiSyPRGav20us6GGMPuSefExpAJDCmaJcSKwb6YQzSBxV6niwMRHSi1A8nPq2qnN59TgNwGrnjKY7hjP+OQuKgrJrdl4IBRYMUH1RlbYsDGIkfZBPYQYAQ=="}],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":2,"cache_creation_input_tokens":13479,"cache_read_input_tokens":8567,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":13479},"output_tokens":8,"service_tier":"standard","inference_geo":"not_available"},"context_management":null},"parent_tool_use_id":null,"session_id":"089a8030-532e-4087-b58e-0b4f404a83ee","uuid":"54bc0760-2d4c-4a0a-b989-b80531e80fb3"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_01GdR5tW1DkJTGrpLCACgpWm","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_01NF8S7uG6uYWuzuVNq3mU5S","name":"Agent","input":{"description":"QA review of accessibility atoms","subagent_type":"Explore","prompt":"Read the following files and return their FULL contents. I need to review accessibility implementation across all these files. Read ALL of them:\n\n1. /home/simonerich/Flutters/obers_ui/.broins/requirements/atoms.json\n2. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_button.dart\n3. /home/simonerich/Flutters/obers_ui/lib/src/composites/editors/oi_rich_editor.dart\n4. /home/simonerich/Flutters/obers_ui/lib/src/composites/editors/oi_smart_input.dart\n5. /home/simonerich/Flutters/obers_ui/lib/src/composites/forms/oi_form.dart\n6. /home/simonerich/Flutters/obers_ui/lib/src/composites/forms/oi_stepper.dart\n7. /home/simonerich/Flutters/obers_ui/lib/src/composites/forms/oi_wizard.dart\n8. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_gallery.dart\n9. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_image_cropper.dart\n10. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_lightbox.dart\n11. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_video_player.dart\n12. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_arrow_nav.dart\n13. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_filter_bar.dart\n14. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_nav_menu.dart\n15. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_shortcuts.dart\n16. /home/simonerich/Flutters/obers_ui/lib/src/composites/navigation/oi_sidebar.dart\n17. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_spotlight.dart\n18. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_tour.dart\n19. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_whats_new.dart\n20. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_calendar.dart\n21. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_gantt.dart\n22. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_timeline.dart\n23. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_combo_box.dart\n24. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_command_bar.dart\n25. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_search.dart\n26. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_avatar_stack.dart\n27. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_cursor_presence.dart\n28. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_live_ring.dart\n29. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_selection_presence.dart\n30. /home/simonerich/Flutters/obers_ui/lib/src/composites/social/oi_typing_indicator.dart\n31. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_funnel_chart.dart\n32. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_gauge.dart\n33. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_heatmap.dart\n34. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_radar_chart.dart\n35. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_sankey.dart\n36. /home/simonerich/Flutters/obers_ui/lib/src/composites/visualization/oi_treemap.dart\n37. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_flow_graph.dart\n38. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_pipeline.dart\n39. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_state_diagram.dart\n40. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_activity_feed.dart\n41. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_chat.dart\n42. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_comments.dart\n43. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_dashboard.dart\n44. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_file_manager.dart\n45. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_kanban.dart\n46. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_list_view.dart\n47. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_metadata_editor.dart\n48. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_notification_center.dart\n49. /home/simonerich/Flutters/obers_ui/lib/src/modules/oi_permissions.dart\n5
[truncated]
```


## Task Packet (living document)

## Task Packet Summary
Work Item: WI-0007 — verifying
Classification: feature
Specialists: 

### Plan (v1)
API Error: Unable to connect to API (EAI_AGAIN)API Error: Unable to connect to API (EAI_AGAIN)

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

Also write your verification results to `.broins/work/runs/run-1773733505170/wi/WI-0007/results/verify.json`.

## Required JSON Output Format

Respond with EXACTLY this structure (concrete example):

{
  "atomResults": [
    {
      "atomId": "REQ-0493",
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
