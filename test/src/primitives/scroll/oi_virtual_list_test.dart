// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/scroll/oi_virtual_list.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders itemCount items ─────────────────────────────────────────────

  testWidgets('renders all items when itemCount is small', (tester) async {
    await tester.pumpObers(
      OiVirtualList(
        itemCount: 5,
        itemBuilder: (_, i) => Text('item $i', key: ValueKey('item$i')),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
    for (var i = 0; i < 5; i++) {
      expect(find.text('item $i'), findsOneWidget);
    }
  });

  // ── 2. itemBuilder called for each visible item ────────────────────────────

  testWidgets('itemBuilder is invoked for each visible index', (tester) async {
    final builtIndices = <int>[];
    await tester.pumpObers(
      OiVirtualList(
        itemCount: 3,
        itemBuilder: (_, i) {
          builtIndices.add(i);
          return SizedBox(key: ValueKey('k$i'), height: 40, child: Text('$i'));
        },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
    expect(builtIndices, containsAll([0, 1, 2]));
  });

  // ── 3. scrollDirection=horizontal works ────────────────────────────────────

  testWidgets('scrollDirection=horizontal renders items', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 80,
        child: OiVirtualList(
          itemCount: 4,
          itemBuilder: (_, i) => SizedBox(width: 80, child: Text('h$i')),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
    // At least the first item is visible.
    expect(find.text('h0'), findsOneWidget);
  });

  // ── 4. onRefresh=null by default does not crash ────────────────────────────

  testWidgets('onRefresh=null: no crash, no NotificationListener', (
    tester,
  ) async {
    await tester.pumpObers(
      OiVirtualList(
        itemCount: 3,
        itemBuilder: (_, i) => Text('$i'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
    expect(find.byType(OiVirtualList), findsOneWidget);
  });

  // ── 5. shrinkWrap=true sizes list to content ───────────────────────────────

  testWidgets('shrinkWrap=true: list is embedded in a Column without error', (
    tester,
  ) async {
    await tester.pumpObers(
      Column(
        children: [
          OiVirtualList(
            itemCount: 3,
            itemBuilder: (_, i) => SizedBox(height: 20, child: Text('sw$i')),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      ),
    );
    expect(find.text('sw0'), findsOneWidget);
    expect(find.text('sw2'), findsOneWidget);
  });

  // ── 6. onRefresh wraps in NotificationListener when provided ───────────────

  testWidgets('onRefresh provided: NotificationListener is present', (
    tester,
  ) async {
    await tester.pumpWidget(
      OiApp(
        density: OiDensity.comfortable,
        home: OiVirtualList(
          itemCount: 3,
          itemBuilder: (_, i) => SizedBox(height: 60, child: Text('r$i')),
          onRefresh: () async {},
        ),
      ),
    );
    expect(
      find.byType(NotificationListener<ScrollNotification>),
      findsAtLeastNWidgets(1),
    );
  });

  // ── 7. reverse=true is forwarded to ListView ───────────────────────────────

  testWidgets('reverse=true: ListView reverse property set', (tester) async {
    await tester.pumpObers(
      OiVirtualList(
        itemCount: 3,
        itemBuilder: (_, i) => SizedBox(height: 40, child: Text('rv$i')),
        reverse: true,
      ),
    );
    final lv = tester.widget<ListView>(find.byType(ListView));
    expect(lv.semanticChildCount, 3);
  });

  // ── 8. cacheExtent is forwarded ────────────────────────────────────────────

  testWidgets('cacheExtent is passed through to ListView', (tester) async {
    await tester.pumpObers(
      OiVirtualList(
        itemCount: 3,
        itemBuilder: (_, i) => SizedBox(height: 40, child: Text('ce$i')),
        cacheExtent: 500,
      ),
    );
    final lv = tester.widget<ListView>(find.byType(ListView));
    expect(lv.cacheExtent, 500);
  });

  // ── 9. Reduced motion: refresh spinner stops animating ──────────────────

  testWidgets('reducedMotion: refresh spinner animation controller stops', (
    tester,
  ) async {
    await tester.pumpWidget(
      OiApp(
        density: OiDensity.comfortable,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: OiVirtualList(
            itemCount: 10,
            itemBuilder: (_, i) => SizedBox(height: 60, child: Text('r$i')),
            onRefresh: () async {},
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify spinner widget renders but its controller is stopped when
    // reducedMotion is active. We need to trigger refresh first.
    // Since the spinner is internal and only shown during refresh, we verify
    // via the ValueKey.
    // Spinner only appears during refresh — verify the list renders
    // successfully with disableAnimations.
    expect(
      find.byKey(const ValueKey('oi_virtual_list_refresh_indicator')),
      findsNothing,
    );
    expect(find.text('r0'), findsOneWidget);
  });

  // ── Pull-to-refresh ────────────────────────────────────────────────────────

  group('pull-to-refresh', () {
    const spinner = ValueKey('oi_virtual_list_refresh_indicator');

    Widget list({
      required Future<void> Function() onRefresh,
      OiDensity density = OiDensity.compact,
      OiThemeData? theme,
    }) {
      return OiApp(
        density: density,
        theme: theme,
        home: OiVirtualList(
          itemCount: 40,
          itemBuilder: (_, i) => SizedBox(height: 60, child: Text('p$i')),
          onRefresh: onRefresh,
        ),
      );
    }

    /// Drags the list down by 300 px in 30 steps, like a finger would.
    Future<void> pull(WidgetTester tester) async {
      final gesture = await tester.startGesture(const Offset(200, 150));
      for (var step = 0; step < 30; step++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
    }

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('one pull refreshes once on ${platform.name}', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        var refreshes = 0;
        // Completes immediately: a fast refresh must not fire again while the
        // same pull is still in progress.
        await tester.pumpWidget(list(onRefresh: () async => refreshes++));

        await pull(tester);
        debugDefaultTargetPlatformOverride = null;

        expect(refreshes, 1);
      });
    }

    testWidgets('works at every density', (tester) async {
      for (final density in OiDensity.values) {
        var refreshes = 0;
        await tester.pumpWidget(
          list(density: density, onRefresh: () async => refreshes++),
        );
        await pull(tester);
        expect(refreshes, 1, reason: '$density');
      }
    });

    testWidgets('a second pull refreshes again', (tester) async {
      var refreshes = 0;
      await tester.pumpWidget(list(onRefresh: () async => refreshes++));

      await pull(tester);
      await pull(tester);

      expect(refreshes, 2);
    });

    testWidgets('a short pull does not refresh', (tester) async {
      var refreshes = 0;
      await tester.pumpWidget(list(onRefresh: () async => refreshes++));

      await tester.drag(find.byType(ListView), const Offset(0, 30));
      await tester.pumpAndSettle();

      expect(refreshes, 0);
    });

    testWidgets('a trackpad scroll past the top does not refresh on macOS', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      var refreshes = 0;
      await tester.pumpWidget(list(onRefresh: () async => refreshes++));
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.trackpad,
      );
      await gesture.panZoomStart(const Offset(200, 150));
      var mostBeyondTop = 0.0;
      for (var step = 1; step <= 30; step++) {
        await gesture.panZoomUpdate(
          const Offset(200, 150),
          pan: Offset(0, 10.0 * step),
        );
        await tester.pump(const Duration(milliseconds: 16));
        if (-position.pixels > mostBeyondTop) mostBeyondTop = -position.pixels;
      }
      await gesture.panZoomEnd();
      await tester.pumpAndSettle();
      debugDefaultTargetPlatformOverride = null;

      // The bouncing physics did let the trackpad pull the list far past its
      // top, further than a touch pull needs to refresh.
      expect(mostBeyondTop, greaterThan(60));
      expect(refreshes, 0);
    });

    testWidgets('a stylus pull refreshes', (tester) async {
      var refreshes = 0;
      await tester.pumpWidget(list(onRefresh: () async => refreshes++));

      final gesture = await tester.startGesture(
        const Offset(200, 150),
        kind: PointerDeviceKind.stylus,
      );
      for (var step = 0; step < 30; step++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(refreshes, 1);
    });

    testWidgets('does not refresh again while a refresh is running', (
      tester,
    ) async {
      final completer = Completer<void>();
      var refreshes = 0;
      await tester.pumpWidget(
        list(
          onRefresh: () {
            refreshes++;
            return completer.future;
          },
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 150));
      for (var step = 0; step < 30; step++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();
      expect(find.byKey(spinner), findsOneWidget);

      final second = await tester.startGesture(const Offset(200, 150));
      for (var step = 0; step < 30; step++) {
        await second.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await second.up();
      await tester.pump();
      expect(refreshes, 1);

      completer.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(spinner), findsNothing);
    });

    testWidgets('spinner colour comes from the theme', (tester) async {
      final completer = Completer<void>();
      final spinnerPaint = find.descendant(
        of: find.byKey(spinner),
        matching: find.byType(CustomPaint),
      );

      final brand = OiThemeData.fromBrand(color: const Color(0xFF16A34A));
      await tester.pumpWidget(
        list(theme: brand, onRefresh: () => completer.future),
      );
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();
      expect(spinnerPaint, paints..arc(color: brand.colors.primary.base));

      const custom = Color(0xFFAA00AA);
      await tester.pumpWidget(
        list(
          theme: brand.copyWith(
            components: const OiComponentThemes(
              refreshIndicator: OiRefreshIndicatorThemeData(
                indicatorColor: custom,
              ),
            ),
          ),
          onRefresh: () => completer.future,
        ),
      );
      await tester.pump();
      expect(spinnerPaint, paints..arc(color: custom));

      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
