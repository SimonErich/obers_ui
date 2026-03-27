// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/primitives/gesture/oi_double_tap.dart';

import '../../../helpers/pump_app.dart';

Widget _touchApp(Widget child) => OiApp(
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

void main() {
  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(const OiDoubleTap(child: Text('hello')));
    expect(find.text('hello'), findsOneWidget);
  });

  // ── 2. onDoubleTap fires on double tap ────────────────────────────────────

  testWidgets('onDoubleTap fires on double tap', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiDoubleTap(
        onDoubleTap: () => count++,
        child: const SizedBox(width: 80, height: 80, child: Text('x')),
      ),
    );
    await tester.tap(find.byType(OiDoubleTap));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(OiDoubleTap));
    await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
    expect(count, 1);
  });

  // ── 3. onTap fires on single tap ─────────────────────────────────────────

  testWidgets('onTap fires on single tap', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiDoubleTap(
        onTap: () => tapped = true,
        child: const SizedBox(width: 80, height: 80, child: Text('x')),
      ),
    );
    await tester.tap(find.byType(OiDoubleTap));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  // ── 4. enabled=false suppresses onDoubleTap ───────────────────────────────

  testWidgets('enabled=false: onDoubleTap not fired', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiDoubleTap(
        enabled: false,
        onDoubleTap: () => count++,
        child: const SizedBox(width: 80, height: 80, child: Text('x')),
      ),
    );
    await tester.tap(find.byType(OiDoubleTap));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(OiDoubleTap));
    await tester.pumpAndSettle();
    expect(count, 0);
  });

  // ── 5. enabled=false suppresses onTap ────────────────────────────────────

  testWidgets('enabled=false: onTap not fired', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiDoubleTap(
        enabled: false,
        onTap: () => tapped = true,
        child: const SizedBox(width: 80, height: 80, child: Text('x')),
      ),
    );
    await tester.tap(find.byType(OiDoubleTap));
    await tester.pumpAndSettle();
    expect(tapped, isFalse);
  });

  // ── 6. Touch target: enforces 48dp on touch device ──────────────────────

  testWidgets(
    'OiDoubleTap enforces 48dp touch target on touch device',
    (tester) async {
      await tester.pumpWidget(
        _touchApp(
          const Center(
            child: OiDoubleTap(child: SizedBox(width: 24, height: 24)),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(OiDoubleTap));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
