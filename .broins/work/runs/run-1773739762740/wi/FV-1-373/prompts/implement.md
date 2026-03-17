# Implementation Phase

## Work Item: FV-1-373 — Fix: Booleans are descriptive

## Requirement Atoms

- [ ] REQ-0017: Booleans are descriptive. `enabled`, `dismissible`, `searchable`, `loading`.

Every item above must be verified individually. Do not skip any.

## Plan

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

Implement the work item according to the plan above. Implement the full requirement only: no stubs, placeholders, or TODO comments. Every requirement atom must be completely implemented and verifiable with evidence.

For each requirement atom: implement every sub-bullet and every mentioned UI element, button, link, section, and state. If the requirement lists multiple items (e.g. A) X, B) Y, C) Z), implement all of them. Partial implementation will fail verification.

1. Implement each step from the plan in order
2. Write clean, well-documented code
3. Include appropriate error handling
4. Write tests for all new functionality
5. Ensure all definition of done criteria are met

CRITICAL: You must implement ALL methods and classes mentioned in your plan. Do not just add enum values, registry entries, or type definitions — write the full method bodies with complete logic. If your plan mentions methods like previewX() and executeX(), those methods MUST appear in your code with real implementations.

Be concise and focused. Write code, not explanations. Do not narrate what you are doing — just do it. Minimize file reads: only read files you need to edit or that are direct dependencies of files you edit.

## REQUIRED ACTIONS (from previous verification failure)

Your previous implementation was verified and FAILED. You MUST complete ALL actions listed below. Each action is imperative — do exactly what it says. Do NOT repeat the same approach that already failed.

### Required Actions

1. **COMPLETE/REGISTER**: **REQ-0017** — partial
2. **CREATE/ADD**: Missing: Seven is/has-prefixed boolean parameters remain unfixed in files not present in this diff: (1) OiInfiniteScroll.hasMore → moreAvailable (lib/src/primitives/scroll/oi_infinite_scroll.dart:38); (2) OiListView.hasMore → moreAvailable (lib/src/modules/oi_list_view.dart:134); (3) OiActivityFeed.hasMore → moreAvailable and internal _OiActivityFeedState.hasMore → moreAvailable (lib/src/modules/oi_activity_feed.dart:90,221); (4) OiChat.hasOlderMessages → olderMessagesAvailable (lib/src/modules/oi_chat.dart:153); (5) OiFileNode.isFolder → folder (lib/src/modules/oi_file_manager.dart:26); (6) OiPlatformData.isKeyboardVisible → keyboardVisible (lib/src/foundation/oi_platform.dart:29); (7) OiGradient.isLinear → linear (lib/src/foundation/theme/oi_decoration_theme.dart:219). No dedicated naming-convention tests validate boolean naming discipline. Coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 are absent.
3. **CREATE/ADD**: Fix: 1. Rename hasMore → moreAvailable in oi_infinite_scroll.dart, oi_list_view.dart, and oi_activity_feed.dart (both public param and internal state field). 2. Rename hasOlderMessages → olderMessagesAvailable in oi_chat.dart. 3. Rename isFolder → folder in oi_file_manager.dart. 4. Rename isKeyboardVisible → keyboardVisible in oi_platform.dart. 5. Rename isLinear → linear in oi_decoration_theme.dart. 6. Update all call-sites and tests for each renamed parameter. 7. Add a dedicated naming-convention test file (e.g. test/src/naming_conventions_test.dart) that asserts no public bool parameter in the public API starts with 'is' or 'has'. 8. Add coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 under .broins/work/autopilot.
4. **FIX**: Evidence files: lib/src/components/inputs/oi_select.dart:17-27, lib/src/components/inputs/oi_select.dart:49-83, lib/src/components/inputs/oi_radio.dart:14-24, lib/src/components/inputs/oi_radio.dart:40-55, lib/src/components/buttons/oi_icon_button.dart:25-42, test/src/components/inputs/oi_select_test.dart:85-104, test/src/components/inputs/oi_radio_test.dart:13-83, test/src/components/buttons/oi_icon_button_test.dart:27-35
5. **FIX**: ### Files Requiring Changes
6. **FIX**: The following files need modifications to achieve full coverage:
7. **FIX**: - lib/src/components/inputs/oi_select.dart
8. **FIX**: - lib/src/components/inputs/oi_radio.dart
9. **FIX**: - lib/src/components/buttons/oi_icon_button.dart
10. **FIX**: - test/src/components/inputs/oi_select_test.dart
11. **FIX**: - test/src/components/inputs/oi_radio_test.dart
12. **FIX**: - test/src/components/buttons/oi_icon_button_test.dart

You MUST address every numbered action above. After implementation, verify each action is complete.

### Attempt History (do NOT repeat these)

- Iteration 0: QA NOT_READY: REQ-0017: Seven is/has-prefixed boolean parameters remain unfixed in files not present in this diff: (1) OiInfiniteScroll.hasMore → moreAvailable (lib/src/primitives/scroll/oi_infinite_scroll.dart:38); (2) OiListView.hasMore → moreAvailable (lib/src/modules/oi_list_view.dart:134); (3) OiActivityFeed.hasMore → moreAvailable and internal _OiActivityFeedState.hasMore → moreAvailable (lib/src/modules/oi_activity_feed.dart:90,221); (4) OiChat.hasOlderMessages → olderMessagesAvailable (lib/src/modules/oi_chat.dart:153); (5) OiFileNode.isFolder → folder (lib/src/modules/oi_file_manager.dart:26); (6) OiPlatformData.isKeyboardVisible → keyboardVisible (lib/src/foundation/oi_platform.dart:29); (7) OiGradient.isLinear → linear (lib/src/foundation/theme/oi_decoration_theme.dart:219). No dedicated naming-convention tests validate boolean naming discipline. Coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 are absent.
6. When finished, write 'DONE: FV-1-373' to the sentinel file at `.broins/work/runs/run-1773739762740/sentinel_FV-1-373.txt`
7. Write an `implement.json` file to `.broins/work/runs/run-1773739762740/wi/FV-1-373/results/implement.json` with:
   - `filesChanged`: list of files you modified
   - `commandsRun`: list of shell commands you executed
   - `notes`: any implementation notes
