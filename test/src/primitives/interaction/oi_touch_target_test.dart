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

  // ── 6. alignment places a small child ──────────────────────────────────────

  testWidgets(
    'OiTouchTarget places a small child by alignment',
    (tester) async {
      await tester.pumpWidget(
        touchApp(
          const Center(
            child: OiTouchTarget(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(key: Key('mark'), width: 24, height: 24),
            ),
          ),
        ),
      );

      final target = tester.getRect(find.byType(OiTouchTarget));
      final mark = tester.getRect(find.byKey(const Key('mark')));
      expect(mark.topLeft, target.topLeft);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  // ── 7. A slot that forces the width keeps the child at full width ──────────

  testWidgets(
    'OiTouchTarget passes a forced width through to the child',
    (tester) async {
      await tester.pumpWidget(
        touchApp(
          const Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 300,
              child: OiTouchTarget(
                child: SizedBox(key: Key('row'), height: 20),
              ),
            ),
          ),
        ),
      );

      final target = tester.getRect(find.byType(OiTouchTarget));
      final row = tester.getRect(find.byKey(const Key('row')));
      expect(target.size, const Size(300, 48));
      expect(row.left, target.left);
      expect(row.width, 300);
      expect(row.center.dy, target.center.dy);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  // ── 8. Intrinsic sizes include the touch target ────────────────────────────

  testWidgets(
    'OiTouchTarget reports the touch target as its intrinsic size',
    (tester) async {
      await tester.pumpWidget(
        touchApp(
          Align(
            alignment: Alignment.topLeft,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const OiTouchTarget(
                    child: SizedBox(key: Key('mark'), width: 24, height: 24),
                  ),
                  Container(key: const Key('neighbour'), width: 10),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const Key('neighbour'))).height, 48);
      final target = tester.getRect(find.byType(OiTouchTarget));
      final mark = tester.getRect(find.byKey(const Key('mark')));
      expect(target.size, const Size(48, 48));
      expect(mark.center, target.center);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  // ── 9. A tap in the padding reaches a gesture detector inside ──────────────

  testWidgets(
    'OiTouchTarget sends a tap in the padding to the child',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        touchApp(
          Center(
            child: OiTouchTarget(
              child: GestureDetector(
                onTap: () => taps++,
                child: const ColoredBox(
                  color: Color(0xFF000000),
                  child: SizedBox(width: 24, height: 24),
                ),
              ),
            ),
          ),
        ),
      );

      final target = tester.getRect(find.byType(OiTouchTarget));
      await tester.tapAt(target.topLeft + const Offset(2, 2));
      await tester.tapAt(target.bottomRight - const Offset(2, 2));
      expect(taps, 2);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  // ── 10. Outside the touch target nothing is hit ────────────────────────────

  testWidgets(
    'OiTouchTarget ignores a tap outside the touch target',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        touchApp(
          Center(
            child: OiTouchTarget(
              child: GestureDetector(
                onTap: () => taps++,
                child: const ColoredBox(
                  color: Color(0xFF000000),
                  child: SizedBox(width: 24, height: 24),
                ),
              ),
            ),
          ),
        ),
      );

      final target = tester.getRect(find.byType(OiTouchTarget));
      await tester.tapAt(target.topLeft - const Offset(4, 4));
      expect(taps, 0);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  // ── 11. A tap above a wide row hits what is below it ──────────────────────

  testWidgets(
    'OiTouchTarget keeps a padding tap in place along a wide child',
    (tester) async {
      final taps = <String>[];
      Widget part(String name) => Expanded(
        child: GestureDetector(
          onTap: () => taps.add(name),
          child: const ColoredBox(color: Color(0xFF000000)),
        ),
      );
      await tester.pumpWidget(
        touchApp(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 300,
              child: OiTouchTarget(
                child: SizedBox(
                  height: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [part('left'), part('middle'), part('right')],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final target = tester.getRect(find.byType(OiTouchTarget));
      await tester.tapAt(target.topLeft + const Offset(10, 2));
      await tester.tapAt(target.bottomRight - const Offset(10, 2));
      expect(taps, ['left', 'right']);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
