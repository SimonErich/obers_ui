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


**Frontend/UX focus:**
- Test widget rendering across screen sizes and orientations.
- Verify accessibility properties (semantics, labels, contrast).
- Test navigation flows and deep-linking scenarios.
- Validate loading, error, and empty-state rendering.


**Feature/Bugfix focus:**
- Write regression tests that reproduce the original bug.
- Test feature-flag on/off paths independently.
- Verify backward compatibility with existing callers.
- Test upgrade/migration paths from previous versions.


## Specialist Considerations

Also consider the perspective of these specialists: UX/UI Expert, DevOps / SRE, Technical Writer. Apply their domain expertise where relevant.

IMPORTANT: You MUST respond with ONLY a JSON object. No markdown, no code fences, no prose, no explanation. Start your response with { and end with }.

# Verification Phase

## Work Item: Accessibility Enforcement (Part 1/6)

**ID:** WI-0001
**Description:** - Accessibility Enforcement: **OiImage** requires `alt`. Use `OiImage.decorative()` to explicitly opt out.
- Accessibility Enforcement: **OiButton** (all variants including `.icon()`) requires `label`.
- Accessibility Enforcement: **OiIcon** requires `label`. Use `OiIcon.decorative()` to opt out.
**Risk:** medium

### Definition of Done

- [ ] Atom REQ-0018 fully implemented: Accessibility Enforcement: **OiImage** requires `alt`. Use `OiImage.decorative()` to explicitly opt out.
- [ ] Atom REQ-0019 fully implemented: Accessibility Enforcement: **OiButton** (all variants including `.icon()`) requires `label`.
- [ ] Atom REQ-0020 fully implemented: Accessibility Enforcement: **OiIcon** requires `label`. Use `OiIcon.decorative()` to opt out.
- [ ] All project checks pass (format, analyze, test)
- [ ] Coverage ledger updated for all atoms

## Requirement Atoms to Verify

- [ ] REQ-0018: **OiImage** requires `alt`. Use `OiImage.decorative()` to explicitly opt out.
- [ ] REQ-0019: **OiButton** (all variants including `.icon()`) requires `label`.
- [ ] REQ-0020: **OiIcon** requires `label`. Use `OiIcon.decorative()` to opt out.

Every item above must be verified individually. Do not skip any.

## Changed Files (STRICT SCOPE)

CRITICAL: You MUST ONLY read the files listed below. Do NOT explore, search, or read any other files in the codebase. Base your verification ENTIRELY on the diff content and these changed files.

- `.broins/requirements/atoms.json`
- `.broins/requirements/source.md`
- `.broins/tmp/drivers/claude/last_invocation.txt`
- `.broins/tmp/drivers/claude/last_pid.txt`
- `.broins/tmp/drivers/claude/last_raw_stream.jsonl`
- `.broins/work/autopilot/ap-1773727433798/state.json`
- `.broins/work/backlog.json`
- `.broins/work/runs/run-1773733505170/context/repo_digest.md`
- `.broins/work/runs/run-1773733505170/events.jsonl`
- `.broins/work/runs/run-1773733505170/sentinel_WI-0001.txt`
- `.broins/work/runs/run-1773733505170/wi/WI-0001/classification.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0001/events.jsonl`
- `.broins/work/runs/run-1773733505170/wi/WI-0001/prompts/implement.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0001/prompts/implement_completion.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0001/prompts/plan.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0001/prompts/self_critique.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0001/results/implement.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0001/task_packet.json`
- `lib/obers_ui.dart`
- `lib/src/components/buttons/oi_button.dart`
- `lib/src/composites/editors/oi_rich_editor.dart`
- `lib/src/composites/editors/oi_smart_input.dart`
- `lib/src/composites/forms/oi_form.dart`
- `lib/src/composites/forms/oi_stepper.dart`
- `lib/src/composites/forms/oi_wizard.dart`
- `lib/src/composites/media/oi_gallery.dart`
- `lib/src/composites/media/oi_image_cropper.dart`
- `lib/src/composites/media/oi_lightbox.dart`
- `lib/src/composites/media/oi_video_player.dart`
- `lib/src/composites/navigation/oi_arrow_nav.dart`
- `lib/src/composites/navigation/oi_filter_bar.dart`
- `lib/src/composites/navigation/oi_nav_menu.dart`
- `lib/src/composites/navigation/oi_shortcuts.dart`
- `lib/src/composites/navigation/oi_sidebar.dart`
- `lib/src/composites/onboarding/oi_spotlight.dart`
- `lib/src/composites/onboarding/oi_tour.dart`
- `lib/src/composites/onboarding/oi_whats_new.dart`
- `lib/src/composites/scheduling/oi_calendar.dart`
- `lib/src/composites/scheduling/oi_gantt.dart`
- `lib/src/composites/scheduling/oi_timeline.dart`
- `lib/src/composites/search/oi_combo_box.dart`
- `lib/src/composites/search/oi_command_bar.dart`
- `lib/src/composites/search/oi_search.dart`
- `lib/src/composites/social/oi_avatar_stack.dart`
- `lib/src/composites/social/oi_cursor_presence.dart`
- `lib/src/composites/social/oi_live_ring.dart`
- `lib/src/composites/social/oi_selection_presence.dart`
- `lib/src/composites/social/oi_typing_indicator.dart`
- `lib/src/composites/visualization/oi_funnel_chart.dart`
- `lib/src/composites/visualization/oi_gauge.dart`
- `lib/src/composites/visualization/oi_heatmap.dart`
- `lib/src/composites/visualization/oi_radar_chart.dart`
- `lib/src/composites/visualization/oi_sankey.dart`
- `lib/src/composites/visualization/oi_treemap.dart`
- `lib/src/composites/workflow/oi_flow_graph.dart`
- `lib/src/composites/workflow/oi_pipeline.dart`
- `lib/src/composites/workflow/oi_state_diagram.dart`
- `lib/src/models/settings/oi_dashboard_settings.dart`
- `lib/src/models/settings/oi_file_explorer_settings.dart`
- `lib/src/models/settings/oi_kanban_settings.dart`
- `lib/src/models/settings/oi_list_view_settings.dart`
- `lib/src/models/settings/oi_sidebar_settings.dart`
- `lib/src/models/settings/oi_split_pane_settings.dart`
- `lib/src/modules/oi_activity_feed.dart`
- `lib/src/modules/oi_chat.dart`
- `lib/src/modules/oi_comments.dart`
- `lib/src/modules/oi_dashboard.dart`
- `lib/src/modules/oi_file_manager.dart`
- `lib/src/modules/oi_kanban.dart`
- `lib/src/modules/oi_list_view.dart`
- `lib/src/modules/oi_metadata_editor.dart`
- `lib/src/modules/oi_notification_center.dart`
- `lib/src/modules/oi_permissions.dart`
- `lib/src/tools/oi_theme_exporter.dart`
- `lib/src/tools/oi_theme_preview.dart`
- `lib/src/utils/.gitkeep`
- `lib/src/utils/calendar_utils.dart`
- `lib/src/utils/color_utils.dart`
- `lib/src/utils/file_utils.dart`
- `lib/src/utils/formatters.dart`
- `lib/src/utils/fuzzy_search.dart`
- `lib/src/utils/spring_physics.dart`
- `test/src/components/buttons/oi_button_test.dart`
- `test/src/composites/editors/oi_rich_editor_test.dart`
- `test/src/composites/editors/oi_smart_input_test.dart`
- `test/src/composites/forms/oi_form_test.dart`
- `test/src/composites/forms/oi_stepper_test.dart`
- `test/src/composites/forms/oi_wizard_test.dart`
- `test/src/composites/media/oi_gallery_test.dart`
- `test/src/composites/media/oi_image_cropper_test.dart`
- `test/src/composites/media/oi_lightbox_test.dart`
- `test/src/composites/media/oi_video_player_test.dart`
- `test/src/composites/navigation/oi_arrow_nav_test.dart`
- `test/src/composites/navigation/oi_filter_bar_test.dart`
- `test/src/composites/navigation/oi_nav_menu_test.dart`
- `test/src/composites/navigation/oi_shortcuts_test.dart`
- `test/src/composites/navigation/oi_sidebar_test.dart`
- `test/src/composites/onboarding/oi_spotlight_test.dart`
- `test/src/composites/onboarding/oi_tour_test.dart`
- `test/src/composites/onboarding/oi_whats_new_test.dart`
- `test/src/composites/scheduling/oi_calendar_test.dart`
- `test/src/composites/scheduling/oi_gantt_test.dart`
- `test/src/composites/scheduling/oi_timeline_test.dart`
- `test/src/composites/search/oi_combo_box_test.dart`
- `test/src/composites/search/oi_command_bar_test.dart`
- `test/src/composites/search/oi_search_test.dart`
- `test/src/composites/social/oi_avatar_stack_test.dart`
- `test/src/composites/social/oi_cursor_presence_test.dart`
- `test/src/composites/social/oi_live_ring_test.dart`
- `test/src/composites/social/oi_selection_presence_test.dart`
- `test/src/composites/social/oi_typing_indicator_test.dart`
- `test/src/composites/visualization/oi_funnel_chart_test.dart`
- `test/src/composites/visualization/oi_gauge_test.dart`
- `test/src/composites/visualization/oi_heatmap_test.dart`
- `test/src/composites/visualization/oi_radar_chart_test.dart`
- `test/src/composites/visualization/oi_sankey_test.dart`
- `test/src/composites/visualization/oi_treemap_test.dart`
- `test/src/composites/workflow/oi_flow_graph_test.dart`
- `test/src/composites/workflow/oi_pipeline_test.dart`
- `test/src/composites/workflow/oi_state_diagram_test.dart`
- `test/src/models/settings/oi_dashboard_settings_test.dart`
- `test/src/models/settings/oi_file_explorer_settings_test.dart`
- `test/src/models/settings/oi_kanban_settings_test.dart`
- `test/src/models/settings/oi_list_view_settings_test.dart`
- `test/src/models/settings/oi_sidebar_settings_test.dart`
- `test/src/models/settings/oi_split_pane_settings_test.dart`
- `test/src/modules/oi_activity_feed_test.dart`
- `test/src/modules/oi_chat_test.dart`
- `test/src/modules/oi_comments_test.dart`
- `test/src/modules/oi_dashboard_test.dart`
- `test/src/modules/oi_file_manager_test.dart`
- `test/src/modules/oi_kanban_test.dart`
- `test/src/modules/oi_list_view_test.dart`
- `test/src/modules/oi_metadata_editor_test.dart`
- `test/src/modules/oi_notification_center_test.dart`
- `test/src/modules/oi_permissions_test.dart`
- `test/src/tools/oi_theme_exporter_test.dart`
- `test/src/tools/oi_theme_preview_test.dart`
- `test/src/utils/calendar_utils_test.dart`
- `test/src/utils/color_utils_test.dart`
- `test/src/utils/file_utils_test.dart`
- `test/src/utils/formatters_test.dart`
- `test/src/utils/fuzzy_search_test.dart`
- `test/src/utils/spring_physics_test.dart`

## Diff Content

```diff
diff --git a/.broins/requirements/atoms.json b/.broins/requirements/atoms.json
new file mode 100644
index 0000000..8601372
--- /dev/null
+++ b/.broins/requirements/atoms.json
@@ -0,0 +1,22074 @@
+{
+  "schemaVersion": 3,
+  "source": {
+    "path": ".broins/requirements/source.md",
+    "sha256": "cbf935e6a5ec061d9faba2c099bcf9d1dd510e674f74af0a0afdd251c871df1b"
+  },
+  "generatedAt": "2026-03-17T07:45:05.065219Z",
+  "atomCount": 809,
+  "atoms": [
+    {
+      "id": "REQ-0001",
+      "text": "[Naming & Conventions](#naming--conventions)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 12,
+        "lineEnd": 12
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0002",
+      "text": "[Package Structure](#package-structure)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 13,
+        "lineEnd": 13
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0003",
+      "text": "[Theming System](#theming-system)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 14,
+        "lineEnd": 14
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0004",
+      "text": "[Accessibility Enforcement](#accessibility-enforcement)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 15,
+        "lineEnd": 15
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0005",
+      "text": "[Composition Map](#composition-map)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 16,
+        "lineEnd": 16
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0006",
+      "text": "[Tier 0: Foundation](#tier-0-foundation)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 17,
+        "lineEnd": 17
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0007",
+      "text": "[Tier 1: Primitives](#tier-1-primitives)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 18,
+        "lineEnd": 18
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0008",
+      "text": "[Tier 2: Components](#tier-2-components)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 19,
+        "lineEnd": 19
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0009",
+      "text": "[Tier 3: Composites](#tier-3-composites)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 20,
+        "lineEnd": 20
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0010",
+      "text": "[Tier 4: Modules](#tier-4-modules)",
+      "type": "functional",
+      "priority": "should",
+      "source": {
+        "file": "./concept/base_concept.md",
+        "headingPath": [
+          "obers_ui — Complete Library Specification v4",
+          "Table of Contents"
+        ],
+        "lineStart": 21,
+        "lineEnd": 21
+      },
+      "tags": [
+        "obersui-complete-library-specification-v4",
+        "table-of-contents"
+      ],
+      "acceptanceHints": [],
+      "candidateRefs": [],
+      "needsClarification": false,
+      "clarificationHints": [],
+      "epicId": "EPIC-0004",
+      "epicTitle": "Obersui Complete Library Specification V4"
+    },
+    {
+      "id": "REQ-0011",
+      "text": "[Testing Strategy](#testing-strategy)",
+      "type": "functional",
+      "priority": "should",
[truncated]
```


## Task Packet (living document)

## Task Packet Summary
Work Item: WI-0001 — verifying
Classification: ux, feature
Specialists: frontend_architect, ux_researcher, qa_engineer, dx_engineer, technical_writer

### Plan (v1)
---

## Implementation Plan: WI-0001 — Accessibility Enforcement (Part 1/6)

---

### Concept

This work item enforces compile-time accessibility contracts on three UI primitives: `OiImage`, `OiButton`, and `OiIcon`. Callers are forced to supply meaningful labels or explicitly opt out via a named constructor, eliminating the class of accessibility bugs where interactive/informative widgets are silently invisible to screen readers.

---

### Current State Assessment (from code audit)

| Atom | Component | Status |
|---|---|---|
| REQ-0018 | `OiImage` | ✅ Already implemented — `required String alt`, `.decorative()` exists, tests pass |
| REQ-0019 | `OiButton` (standard variants) | ✅ All six standard variants + split/countdown/confirm already have `required String label` |
| REQ-0019 | `OiButton.icon()` | ❌ **Gap** — `semanticLabel` is `String?` (optional), no label enforced |
| REQ-0020 | `OiIcon` | ✅ Already implemented — `required String label`, `.decorative()` exists, tests pass |

The only source change needed is in `OiButton.icon()`: rename the parameter from optional `String? semanticLabel` to required `String label`.

---

### Sub-tasks

- **ST1:** Modify `OiButton.icon()` constructor — change `String? semanticLabel` to `required String label`, delegate to private constructor as `semanticLabel: label`
- **ST2:** Update `oi_button_test.dart` — fix two existing call sites that omit a label for `.icon()`, add a new semantic label test for the icon variant
- **ST3:** Audit `obers_ui.dart` exports to confirm all three classes are exported (no change expected)
- **ST4:** Verify REQ-0018 and REQ-0020 tests are present and sufficient (read-only confirmation, no changes expected)

---

### Method signatures

```dart
// MODIFIED — OiButton.icon() (lib/src/components/buttons/oi_button.dart:282)
const OiButton.icon({
  required IconData icon,
  required String label,          // was: String? semanticLabel
  VoidCallback? onTap,
  OiButtonSize size = OiButtonSize.medium,
  
... [truncated, 17162 chars total]

### Implementation Notes
Changed OiButton.icon() from optional String? semanticLabel to required String label. Updated 3 call sites in tests and added 1 new semantic label test. REQ-0018 (OiImage) and REQ-0020 (OiIcon) were already fully implemented. All 45 tests pass.

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

Also write your verification results to `.broins/work/runs/run-1773733505170/wi/WI-0001/results/verify.json`.

## Required JSON Output Format

Respond with EXACTLY this structure (concrete example):

{
  "atomResults": [
    {
      "atomId": "REQ-0018",
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
