// Tests are internal; doc comments on local helpers are not required.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_input_modality_detector.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';

void main() {
  Widget buildDetector({required ValueChanged<OiInputModality> onBuild}) {
    return MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OiInputModalityDetector(
          child: Builder(
            builder: (ctx) {
              onBuild(OiPlatform.of(ctx).inputModality);
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
  }

  group('OiInputModalityDetector', () {
    // The suite pins the starting modality to pointer in
    // flutter_test_config.dart; these tests exercise the platform seed itself.
    for (final (platform, expected) in [
      (TargetPlatform.android, OiInputModality.touch),
      (TargetPlatform.iOS, OiInputModality.touch),
      (TargetPlatform.fuchsia, OiInputModality.touch),
      (TargetPlatform.linux, OiInputModality.pointer),
      (TargetPlatform.macOS, OiInputModality.pointer),
      (TargetPlatform.windows, OiInputModality.pointer),
    ]) {
      testWidgets('starts in ${expected.name} on ${platform.name}', (
        tester,
      ) async {
        final pinned = OiInputModalityDetector.debugInitialModalityOverride;
        OiInputModalityDetector.debugInitialModalityOverride = null;
        addTearDown(
          () => OiInputModalityDetector.debugInitialModalityOverride = pinned,
        );
        debugDefaultTargetPlatformOverride = platform;
        late OiInputModality modality;

        await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));
        debugDefaultTargetPlatformOverride = null;

        expect(modality, expected);
      });
    }

    testWidgets('a phone has 48 dp touch targets on the first frame', (
      tester,
    ) async {
      final pinned = OiInputModalityDetector.debugInitialModalityOverride;
      OiInputModalityDetector.debugInitialModalityOverride = null;
      addTearDown(
        () => OiInputModalityDetector.debugInitialModalityOverride = pinned,
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      late double minTarget;

      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (ctx) {
              minTarget = OiA11y.minTouchTarget(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      debugDefaultTargetPlatformOverride = null;

      expect(minTarget, 48);
    });

    testWidgets('debugInitialModalityOverride pins the starting modality', (
      tester,
    ) async {
      late OiInputModality modality;

      await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));

      expect(
        OiInputModalityDetector.debugInitialModalityOverride,
        OiInputModality.pointer,
      );
      expect(modality, OiInputModality.pointer);
    });

    testWidgets('touch event sets modality to touch', (tester) async {
      late OiInputModality modality;

      await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));
      expect(modality, OiInputModality.pointer);

      final center = tester.getCenter(find.byType(SizedBox));
      final gesture = await tester.startGesture(center);
      await tester.pump();

      expect(modality, OiInputModality.touch);
      await gesture.up();
    });

    testWidgets('stylus event sets modality to touch', (tester) async {
      late OiInputModality modality;

      await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));

      final center = tester.getCenter(find.byType(SizedBox));
      final gesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.stylus,
      );
      await tester.pump();

      expect(modality, OiInputModality.touch);
      await gesture.up();
    });

    testWidgets('mouse event sets modality to pointer', (tester) async {
      late OiInputModality modality;

      await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));

      // Start with touch first to verify mouse switches back
      final center = tester.getCenter(find.byType(SizedBox));
      final touchGesture = await tester.startGesture(center);
      await tester.pump();
      expect(modality, OiInputModality.touch);
      await touchGesture.up();

      final mouseGesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();

      expect(modality, OiInputModality.pointer);
      await mouseGesture.up();
    });

    testWidgets('trackpad event sets modality to pointer', (tester) async {
      late OiInputModality modality;

      await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));

      // Start with touch
      final center = tester.getCenter(find.byType(SizedBox));
      final touchGesture = await tester.startGesture(center);
      await tester.pump();
      expect(modality, OiInputModality.touch);
      await touchGesture.up();

      final trackpadGesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.trackpad,
      );
      await tester.pump();

      expect(modality, OiInputModality.pointer);
      await trackpadGesture.up();
    });

    testWidgets('dynamic switch: touch → mouse', (tester) async {
      late OiInputModality modality;

      await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));
      final center = tester.getCenter(find.byType(SizedBox));

      // Touch
      final touch = await tester.startGesture(center);
      await tester.pump();
      expect(modality, OiInputModality.touch);
      await touch.up();

      // Mouse
      final mouse = await tester.startGesture(
        center,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      expect(modality, OiInputModality.pointer);
      await mouse.up();
    });

    testWidgets('dynamic switch: mouse → touch', (tester) async {
      late OiInputModality modality;

      await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));
      final center = tester.getCenter(find.byType(SizedBox));

      // Mouse — modality starts at pointer (default), sending mouse won't
      // change it, so we verify it stays pointer and then switch to touch.
      expect(modality, OiInputModality.pointer);

      // Touch
      final touch = await tester.startGesture(center);
      await tester.pump();
      expect(modality, OiInputModality.touch);
      await touch.up();
    });

    testWidgets('unknown PointerDeviceKind is ignored', (tester) async {
      late OiInputModality modality;

      await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));
      final center = tester.getCenter(find.byType(SizedBox));

      // Switch to touch first
      final touch = await tester.startGesture(center);
      await tester.pump();
      expect(modality, OiInputModality.touch);
      await touch.up();

      // Send unknown — should keep touch
      final unknown = await tester.startGesture(
        center,
        kind: PointerDeviceKind.unknown,
      );
      await tester.pump();
      expect(modality, OiInputModality.touch);
      await unknown.up();
    });

    testWidgets('invertedStylus maps to touch', (tester) async {
      late OiInputModality modality;

      await tester.pumpWidget(buildDetector(onBuild: (m) => modality = m));
      final center = tester.getCenter(find.byType(SizedBox));

      final gesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.invertedStylus,
      );
      await tester.pump();

      expect(modality, OiInputModality.touch);
      await gesture.up();
    });
  });
}
