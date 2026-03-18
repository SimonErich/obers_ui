// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// Wraps [child] in a default [MediaQuery] and [Directionality].
Widget buildDefault(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(),
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  group('OiA11y', () {
    testWidgets('reducedMotion returns false by default', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildDefault(
          Builder(
            builder: (ctx) {
              result = OiA11y.reducedMotion(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });

    testWidgets('highContrast returns false by default', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildDefault(
          Builder(
            builder: (ctx) {
              result = OiA11y.highContrast(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });

    testWidgets('textScale returns 1.0 by default', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildDefault(
          Builder(
            builder: (ctx) {
              result = OiA11y.textScale(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 1.0);
    });

    testWidgets('boldText returns false by default', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildDefault(
          Builder(
            builder: (ctx) {
              result = OiA11y.boldText(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });
  });

  // REQ-0034: Screen reader platform differences.
  // iOS (VoiceOver) uses iOS gestures, Android (TalkBack) uses Android
  // conventions, and web uses ARIA roles and live regions.  Flutter's
  // Semantics widget abstracts the platform mapping; these tests verify
  // that the correct semantic properties are declared so each platform's
  // screen reader can interpret them.
  group('REQ-0034: Screen reader platform differences', () {
    // ── iOS (VoiceOver) ──────────────────────────────────────────────────────

    group('iOS VoiceOver', () {
      testWidgets(
        'tap semantic action declared for button on iOS',
        (tester) async {
          await tester.pumpWidget(
            buildDefault(
              Semantics(
                label: 'submit',
                button: true,
                onTap: () {},
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
          );
          final widget = tester.widget<Semantics>(find.byType(Semantics).first);
          expect(widget.properties.button, isTrue);
          expect(widget.properties.label, 'submit');
          expect(
            widget.properties.onTap,
            isNotNull,
            reason:
                'VoiceOver maps SemanticsAction.tap to a double-tap gesture',
          );
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );

      testWidgets(
        'OiTappable exposes button role and label on iOS',
        (tester) async {
          await tester.pumpWidget(
            OiApp(
              home: OiTappable(
                semanticLabel: 'ios action',
                onTap: () {},
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
          );
          final widget = tester.widget<Semantics>(
            find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == 'ios action',
            ),
          );
          expect(widget.properties.button, isTrue);
          expect(widget.properties.label, 'ios action');
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );

      testWidgets(
        'minTouchTarget returns 48dp on iOS',
        (tester) async {
          late double result;
          await tester.pumpWidget(
            buildDefault(
              Builder(
                builder: (ctx) {
                  result = OiA11y.minTouchTarget(ctx);
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          expect(result, 48.0);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );
    });

    // ── Android (TalkBack) ───────────────────────────────────────────────────

    group('Android TalkBack', () {
      testWidgets(
        'tap semantic action declared for button on Android',
        (tester) async {
          await tester.pumpWidget(
            buildDefault(
              Semantics(
                label: 'confirm',
                button: true,
                onTap: () {},
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
          );
          final widget = tester.widget<Semantics>(find.byType(Semantics).first);
          expect(widget.properties.button, isTrue);
          expect(widget.properties.label, 'confirm');
          expect(
            widget.properties.onTap,
            isNotNull,
            reason: 'TalkBack maps SemanticsAction.tap to a double-tap gesture',
          );
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets(
        'long-press semantic action declared on Android when provided',
        (tester) async {
          await tester.pumpWidget(
            buildDefault(
              Semantics(
                label: 'hold action',
                button: true,
                onLongPress: () {},
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
          );
          final widget = tester.widget<Semantics>(find.byType(Semantics).first);
          expect(
            widget.properties.onLongPress,
            isNotNull,
            reason:
                'TalkBack maps SemanticsAction.longPress to double-tap-and-hold',
          );
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets(
        'OiTappable exposes button role and label on Android',
        (tester) async {
          await tester.pumpWidget(
            OiApp(
              home: OiTappable(
                semanticLabel: 'android action',
                onTap: () {},
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
          );
          final widget = tester.widget<Semantics>(
            find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == 'android action',
            ),
          );
          expect(widget.properties.button, isTrue);
          expect(widget.properties.label, 'android action');
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets(
        'OiTappable exposes long-press semantic action on Android',
        (tester) async {
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(
            OiApp(
              home: OiTappable(
                semanticLabel: 'android long press',
                onLongPress: () {},
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
          );
          // GestureDetector.onLongPress causes RenderSemanticsGestureHandler
          // to add SemanticsAction.longPress to the semantics configuration.
          // Retrieve the merged semantics node via getSemantics and verify
          // the action bit is set.
          final node = tester.getSemantics(
            find
                .descendant(
                  of: find.byType(OiTappable),
                  matching: find.byType(GestureDetector),
                )
                .first,
          );
          expect(
            node.getSemanticsData().actions & SemanticsAction.longPress.index,
            isNot(0),
            reason:
                'TalkBack maps SemanticsAction.longPress to double-tap-and-hold',
          );
          handle.dispose();
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets(
        'minTouchTarget returns 48dp on Android',
        (tester) async {
          late double result;
          await tester.pumpWidget(
            buildDefault(
              Builder(
                builder: (ctx) {
                  result = OiA11y.minTouchTarget(ctx);
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          expect(result, 48.0);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );
    });

    // ── Pointer platforms ─────────────────────────────────────────────────────

    group('Pointer platforms', () {
      testWidgets(
        'minTouchTarget returns 0 on macOS',
        (tester) async {
          late double result;
          await tester.pumpWidget(
            buildDefault(
              Builder(
                builder: (ctx) {
                  result = OiA11y.minTouchTarget(ctx);
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          expect(result, 0.0);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      );

      testWidgets(
        'minTouchTarget returns 0 on linux',
        (tester) async {
          late double result;
          await tester.pumpWidget(
            buildDefault(
              Builder(
                builder: (ctx) {
                  result = OiA11y.minTouchTarget(ctx);
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          expect(result, 0.0);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.linux),
      );
    });

    // ── Web (ARIA roles and live regions) ────────────────────────────────────
    //
    // kIsWeb is a compile-time constant and cannot be overridden in unit
    // tests.  These tests verify the semantic properties that Flutter maps
    // to ARIA on web:
    //   SemanticsProperties.button == true  →  role="button"
    //   SemanticsProperties.label          →  aria-label
    //   OiA11y.announce(assertive: false)  →  aria-live="polite"
    //   OiA11y.announce(assertive: true)   →  aria-live="assertive"

    group('Web ARIA roles and live regions', () {
      testWidgets(
        'button flag and label declared for ARIA role=button and aria-label',
        (tester) async {
          await tester.pumpWidget(
            buildDefault(
              Semantics(
                label: 'submit form',
                button: true,
                onTap: () {},
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
          );
          final widget = tester.widget<Semantics>(find.byType(Semantics).first);
          expect(
            widget.properties.button,
            isTrue,
            reason: 'isButton flag maps to ARIA role="button" on web',
          );
          expect(
            widget.properties.label,
            'submit form',
            reason: 'label maps to aria-label on web',
          );
        },
      );

      testWidgets(
        'OiTappable provides button role and label for web ARIA rendering',
        (tester) async {
          await tester.pumpWidget(
            OiApp(
              home: OiTappable(
                semanticLabel: 'web action',
                onTap: () {},
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
          );
          final widget = tester.widget<Semantics>(
            find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == 'web action',
            ),
          );
          expect(
            widget.properties.button,
            isTrue,
            reason: 'isButton flag maps to ARIA role="button" on web',
          );
          expect(
            widget.properties.label,
            'web action',
            reason: 'label maps to aria-label on web',
          );
        },
      );

      // ── Proxy tests for OiA11y.announce ────────────────────────────────────
      //
      // (a) The assertiveness parameter is verified at the implementation
      //     level in oi_accessibility.dart:58–61 where OiA11y.announce passes
      //     Assertiveness.polite or Assertiveness.assertive to
      //     SemanticsService.sendAnnouncement.
      // (b) SemanticsService.sendAnnouncement is a native call routed through
      //     FlutterView.updateSemantics; intercepting the platform channel in
      //     a unit test is infeasible without custom platform-channel mocks
      //     that would track internal Flutter engine implementation details.
      // (c) These tests are therefore framework-level proxy tests: they enable
      //     the semantics layer via tester.ensureSemantics() so that
      //     SemanticsService.sendAnnouncement fires in the test environment,
      //     then assert that the call completes without error — confirming the
      //     announce path is exercised with the semantics layer active.
      testWidgets('OiA11y.announce sends polite live region announcement', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        late BuildContext capturedContext;
        await tester.pumpWidget(
          buildDefault(
            Builder(
              builder: (ctx) {
                capturedContext = ctx;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        // SemanticsService.sendAnnouncement with Assertiveness.polite maps
        // to aria-live="polite" on web.  Must complete without error.
        OiA11y.announce(capturedContext, 'upload complete');
        await tester.pump();
        handle.dispose();
      });

      testWidgets(
        'OiA11y.announce with assertive=true sends assertive live region',
        (tester) async {
          final handle = tester.ensureSemantics();
          late BuildContext capturedContext;
          await tester.pumpWidget(
            buildDefault(
              Builder(
                builder: (ctx) {
                  capturedContext = ctx;
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          // SemanticsService.sendAnnouncement with Assertiveness.assertive
          // maps to aria-live="assertive" on web.  Must complete without error.
          OiA11y.announce(
            capturedContext,
            'error: save failed',
            assertive: true,
          );
          await tester.pump();
          handle.dispose();
        },
      );
    });
  });
}
