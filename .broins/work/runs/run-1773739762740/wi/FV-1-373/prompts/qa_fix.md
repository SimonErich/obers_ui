# QA Targeted Fix

## Work Item: FV-1-373 — Fix: Booleans are descriptive

## QA Findings (blockers to fix)

- REQ-0017: This run fixed: (1) OiInfiniteScroll.hasMore → moreAvailable (oi_infinite_scroll.dart:38 now shows moreAvailable); (2) OiSelectOption.disabled → enabled (oi_select.dart:17-27); (3) OiSelect.enabled and OiSelect.searchable already correct (oi_select.dart:49-83); (4) OiRadioOption.disabled → enabled (oi_radio.dart:14-24); (5) OiRadio.enabled and OiIconButton.enabled already correct. Still unresolved in files NOT present in this diff: (A) OiListView.hasMore → moreAvailable (lib/src/modules/oi_list_view.dart:134); (B) OiActivityFeed.hasMore → moreAvailable and internal _OiActivityFeedState.hasMore → moreAvailable (lib/src/modules/oi_activity_feed.dart:90,221); (C) OiChat.hasOlderMessages → olderMessagesAvailable (lib/src/modules/oi_chat.dart:153); (D) OiFileNode.isFolder → folder (lib/src/modules/oi_file_manager.dart:26); (E) OiPlatformData.isKeyboardVisible → keyboardVisible (lib/src/foundation/oi_platform.dart:29); (F) OiGradient.isLinear → linear (lib/src/foundation/theme/oi_decoration_theme.dart:219). No dedicated naming-convention tests validate boolean naming discipline across the full public API. Coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 are absent.

## Software Engineer Role

You are the **Software Engineer** implementing this task.
Key focus: - Write clean, well-structured code that follows project conventions. - Implement the solution according to the architect's design.

## QA Engineer Role

You are the **QA Engineer** on this task.
Key focus: - Design the test strategy covering unit, integration, and E2E layers. - Identify edge cases, boundary conditions, and failure scenarios.

## Specialist Considerations

Also consider the perspective of these specialists: DevOps / SRE, UX/UI Expert. Apply their domain expertise where relevant.

## Original Plan (for reference)

Now let me read the specific lines of the files to confirm current state:Let me check the activity feed internal state and the autopilot tracking file format:

## CRITICAL: Verification Gaps (auto-injected — planner output was insufficient)

**REQ-0017** — partial
  Missing: Seven is/has-prefixed boolean parameters remain unfixed in files not present in this diff: (1) OiInfiniteScroll.hasMore → moreAvailable (lib/src/primitives/scroll/oi_infinite_scroll.dart:38); (2) OiListView.hasMore → moreAvailable (lib/src/modules/oi_list_view.dart:134); (3) OiActivityFeed.hasMore → moreAvailable and internal _OiActivityFeedState.hasMore → moreAvailable (lib/src/modules/oi_activity_feed.dart:90,221); (4) OiChat.hasOlderMessages → olderMessagesAvailable (lib/src/modules/oi_chat.dart:153); (5) OiFileNode.isFolder → folder (lib/src/modules/oi_file_manager.dart:26); (6) OiPlatformData.isKeyboardVisible → keyboardVisible (lib/src/foundation/oi_platform.dart:29); (7) OiGradient.isLinear → linear (lib/src/foundation/theme/oi_decoration_theme.dart:219). No dedicated naming-convention tests validate boolean naming discipline. Coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 are absent.
  Fix: 1. Rename hasMore → moreAvailable in oi_infinite_scroll.dart, oi_list_view.dart, and oi_activity_feed.dart (both public param and internal state field). 2. Rename hasOlderMessages → olderMessagesAvailable in oi_chat.dart. 3. Rename isFolder → folder in oi_file_manager.dart. 4. Rename isKeyboardVisible → keyboardVisible in oi_platform.dart. 5. Rename isLinear → linear in oi_decoration_theme.dart. 6. Update all call-sites and tests for each renamed parameter. 7. Add a dedicated naming-convention test file (e.g. test/src/naming_conventions_test.dart) that asserts no public bool parameter in the public API starts with 'is' or 'has'. 8. Add coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 under .broins/work/autopilot.
  Evidence files: lib/src/components/inputs/oi_select.dart:17-27, lib/src/components/inputs/oi_select.dart:49-83, lib/src/components/inputs/oi_radio.dart:14-24, lib/src/components/inputs/oi_radio.dart:40-55, lib/src/components/buttons/oi_icon_button.dart:25-42, test/src/components/inputs/oi_select_test.dart:85-104, test/src/components/inputs/oi_radio_test.dart:13-83, test/src/components/buttons/oi_icon_button_test.dart:27-35

### Files Requiring Changes
The following files need modifications to achieve full coverage:
- lib/src/components/inputs/oi_select.dart
- lib/src/components/inputs/oi_radio.dart
- lib/src/components/buttons/oi_icon_button.dart
- test/src/components/inputs/oi_select_test.dart
- test/src/components/inputs/oi_radio_test.dart
- test/src/components/buttons/oi_icon_button_test.dart

You MUST address each gap above. Create or modify the specific files, classes, and methods needed to satisfy each requirement atom.


## Instructions

Fix ONLY the QA findings listed above. Do not re-implement the entire work item. Preserve all existing working code. Focus on closing the specific gaps identified by the QA review.
