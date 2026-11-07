// Tests do not require documentation comments.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/primitives/interaction/oi_touch_target.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [child] with [OiApp] and [OiPlatform] set to touch modality.
Widget touchApp(Widget child) => OiApp(
  home: OiPlatform(
    data: OiPlatformData(
      platform: defaultTargetPlatform,
      keyboardHeight: 0,
      keyboardVisible: false,
      inputModality: OiInputModality.touch,
    ),
    child: child,
  ),
);

/// Wraps [child] with [OiApp] and [OiPlatform] set to pointer modality.
Widget pointerApp(Widget child) => OiApp(
  home: OiPlatform(
    data: OiPlatformData(
      platform: defaultTargetPlatform,
      keyboardHeight: 0,
      keyboardVisible: false,
      inputModality: OiInputModality.pointer,
    ),
    child: child,
  ),
);

void main() {
  // ── 1. OiTouchTarget enforces 48dp on touch modality ──────────────────────

  testWidgets(
    'OiTouchTarget enforces 48dp on touch modality',
    (tester) async {
      await tester.pumpWidget(
        touchApp(
          const Center(
            child: OiTouchTarget(child: SizedBox(width: 24, height: 24)),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(OiTouchTarget));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  // ── 2. OiTouchTarget does not inflate on pointer modality ─────────────────

  testWidgets(
    'OiTouchTarget does not inflate on pointer modality',
    (tester) async {
      await tester.pumpWidget(
        pointerApp(
          const Center(
            child: OiTouchTarget(child: SizedBox(width: 24, height: 24)),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(OiTouchTarget));
      expect(size.width, 24);
      expect(size.height, 24);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  // ── 3. OiTouchTarget.custom uses explicit minSize ─────────────────────────

  testWidgets(
    'OiTouchTarget.custom uses explicit minSize',
    (tester) async {
      await tester.pumpWidget(
        pointerApp(
          const Center(
            child: OiTouchTarget.custom(
              minSize: 64,
              child: SizedBox(width: 24, height: 24),
            ),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(OiTouchTarget));
      expect(size.width, greaterThanOrEqualTo(64));
      expect(size.height, greaterThanOrEqualTo(64));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  // ── 4. OiTouchTarget on web-touch returns 48dp ────────────────────────────
  // Desktop platform + touch modality simulates web on a touch device.

  testWidgets(
    'OiTouchTarget on desktop platform with touch modality returns 48dp',
    (tester) async {
      await tester.pumpWidget(
        const OiApp(
          home: OiPlatform(
            data: OiPlatformData(
              platform: TargetPlatform.linux,
              keyboardHeight: 0,
              keyboardVisible: false,
              inputModality: OiInputModality.touch,
            ),
            child: Center(
              child: OiTouchTarget(child: SizedBox(width: 24, height: 24)),
            ),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(OiTouchTarget));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  // ── 5. The child is centred in the inflated area ──────────────────────────

  testWidgets(
    'OiTouchTarget centres the child in the inflated area',
    (tester) async {
      await tester.pumpWidget(
        touchApp(
          const Center(
            child: OiTouchTarget(
              child: SizedBox(key: Key('child'), width: 24, height: 24),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.getSize(find.byType(OiTouchTarget)), const Size(48, 48));
      expect(
        tester.getCenter(find.byKey(const Key('child'))),
        tester.getCenter(find.byType(OiTouchTarget)),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'buttons of different variants line up in a row on touch',
    (tester) async {
      await tester.pumpWidget(
        touchApp(
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OiButton.secondary(
                  key: const Key('filled'),
                  label: 'Save',
                  onTap: () {},
                ),
                OiButton.ghost(
                  key: const Key('ghost'),
                  label: 'Cancel',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getCenter(find.text('Save')).dy,
        tester.getCenter(find.text('Cancel')).dy,
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
