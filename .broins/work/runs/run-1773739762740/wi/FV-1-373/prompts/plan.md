## Product Manager Role

You are the **Product Manager** on this task.
Key focus: - Define clear acceptance criteria and success metrics for the work item. - Prioritise scope: identify what is essential (must-have) versus nice-to-have.

## Software Architect Role

You are the **Software Architect** on this task.
Key focus: - Design the high-level solution architecture and component interactions. - Choose appropriate patterns, abstractions, and technology trade-offs.

## Specialist Considerations

Also consider the perspective of these specialists: DevOps / SRE, Technical Writer, UX/UI Expert. Apply their domain expertise where relevant.

# Planning Phase

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

## Requirement Atoms

- [ ] REQ-0017: Booleans are descriptive. `enabled`, `dismissible`, `searchable`, `loading`.

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

## Delta Planning

A previous plan was attempted but encountered failures. Fix ONLY the specific issues below. Preserve all working code and do not re-implement what already works.

### Previous Plan (summary)

Now let me check existing tests and the tracking JSON structure:

### Failure Summary

QA NOT_READY: REQ-0017: Seven is/has-prefixed boolean parameters remain unfixed in files not present in this diff: (1) OiInfiniteScroll.hasMore → moreAvailable (lib/src/primitives/scroll/oi_infinite_scroll.dart:38); (2) OiListView.hasMore → moreAvailable (lib/src/modules/oi_list_view.dart:134); (3) OiActivityFeed.hasMore → moreAvailable and internal _OiActivityFeedState.hasMore → moreAvailable (lib/src/modules/oi_activity_feed.dart:90,221); (4) OiChat.hasOlderMessages → olderMessagesAvailable (lib/src/modules/oi_chat.dart:153); (5) OiFileNode.isFolder → folder (lib/src/modules/oi_file_manager.dart:26); (6) OiPlatformData.isKeyboardVisible → keyboardVisible (lib/src/foundation/oi_platform.dart:29); (7) OiGradient.isLinear → linear (lib/src/foundation/theme/oi_decoration_theme.dart:219). No dedicated naming-convention tests validate boolean naming discipline. Coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 are absent.

### Verification Details

The verifier found these specific gaps. Address each one explicitly in your revised plan:

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

### Previous Attempts

These attempts have already been tried and failed. Do NOT repeat the same approach:

- Iteration 0: QA NOT_READY: REQ-0017: Seven is/has-prefixed boolean parameters remain unfixed in files not present in this diff: (1) OiInfiniteScroll.hasMore → moreAvailable (lib/src/primitives/scroll/oi_infinite_scroll.dart:38); (2) OiListView.hasMore → moreAvailable (lib/src/modules/oi_list_view.dart:134); (3) OiActivityFeed.hasMore → moreAvailable and internal _OiActivityFeedState.hasMore → moreAvailable (lib/src/modules/oi_activity_feed.dart:90,221); (4) OiChat.hasOlderMessages → olderMessagesAvailable (lib/src/modules/oi_chat.dart:153); (5) OiFileNode.isFolder → folder (lib/src/modules/oi_file_manager.dart:26); (6) OiPlatformData.isKeyboardVisible → keyboardVisible (lib/src/foundation/oi_platform.dart:29); (7) OiGradient.isLinear → linear (lib/src/foundation/theme/oi_decoration_theme.dart:219). No dedicated naming-convention tests validate boolean naming discipline. Coverage tracking JSON files for REQ-0015, REQ-0016, REQ-0017 are absent.

Focus on what needs to change. Do not repeat steps that succeeded.
