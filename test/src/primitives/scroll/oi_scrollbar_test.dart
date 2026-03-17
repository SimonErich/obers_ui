// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/primitives/scroll/oi_scrollbar.dart';

import '../../../helpers/pump_app.dart';

/// Wraps [child] in a pointer-density [OiApp].
Widget pointerApp(Widget child) =>
    OiApp(density: OiDensity.compact, home: child);

/// Wraps [child] in a touch-density [OiApp].
Widget touchApp(Widget child) =>
    OiApp(density: OiDensity.comfortable, home: child);

void main() {
  // ── 1. Renders RawScrollbar wrapping child ─────────────────────────────────

  testWidgets('renders RawScrollbar containing the child', (tester) async {
    await tester.pumpObers(
      OiScrollbar(child: ListView(children: const [Text('item')])),
    );
    expect(find.byType(RawScrollbar), findsOneWidget);
    expect(find.text('item'), findsOneWidget);
  });

  // ── 2. Pointer device: thumbVisibility defaults to true ────────────────────

  testWidgets('pointer density: thumb always visible by default', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      pointerApp(
        OiScrollbar(
          controller: controller,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
    expect(scrollbar.thumbVisibility, isTrue);
  });

  // ── 3. Touch device: thumbVisibility defaults to false ─────────────────────

  testWidgets('touch density: thumb not always visible by default', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      touchApp(
        OiScrollbar(
          controller: controller,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
    expect(scrollbar.thumbVisibility, isFalse);
  });

  // ── 4. alwaysShow passed through ──────────────────────────────────────────

  testWidgets('alwaysShow=true overrides default on touch device', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      touchApp(
        OiScrollbar(
          controller: controller,
          alwaysShow: true,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
    expect(scrollbar.thumbVisibility, isTrue);
  });

  testWidgets(
    'alwaysShow=false overrides default on pointer device and suppresses track',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        pointerApp(
          OiScrollbar(
            controller: controller,
            alwaysShow: false,
            // showTrack must also be false to satisfy RawScrollbar invariant
            // (track cannot be shown without thumb).
            showTrack: false,
            child: ListView(
              controller: controller,
              children: const [SizedBox(height: 2000)],
            ),
          ),
        ),
      );

      final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
      expect(scrollbar.thumbVisibility, isFalse);
      expect(scrollbar.trackVisibility, isFalse);
    },
  );

  // ── 5. thickness configurable ─────────────────────────────────────────────

  testWidgets('custom thickness is forwarded to RawScrollbar', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      pointerApp(
        OiScrollbar(
          controller: controller,
          thickness: 12,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
    expect(scrollbar.thickness, 12);
  });

  // ── 6. pointer device: default thickness is 8 ────────────────────────────

  testWidgets('pointer density: default thickness is 8', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      pointerApp(
        OiScrollbar(
          controller: controller,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
    expect(scrollbar.thickness, 8);
  });

  // ── 7. touch device: default thickness is 3 ──────────────────────────────

  testWidgets('touch density: default thickness is 3', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      touchApp(
        OiScrollbar(
          controller: controller,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
    expect(scrollbar.thickness, 3);
  });

  // ── 8. radius configurable ────────────────────────────────────────────────

  testWidgets('custom radius is forwarded to RawScrollbar', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    const customRadius = Radius.circular(10);

    await tester.pumpWidget(
      pointerApp(
        OiScrollbar(
          controller: controller,
          radius: customRadius,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
    expect(scrollbar.radius, customRadius);
  });

  // ── 9. showTrack defaults on pointer device ───────────────────────────────

  testWidgets('pointer density: track visible by default', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      pointerApp(
        OiScrollbar(
          controller: controller,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
    expect(scrollbar.trackVisibility, isTrue);
  });

  // ── 10. showTrack defaults on touch device ────────────────────────────────

  testWidgets('touch density: track not visible by default', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      touchApp(
        OiScrollbar(
          controller: controller,
          child: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
    expect(scrollbar.trackVisibility, isFalse);
  });
}
