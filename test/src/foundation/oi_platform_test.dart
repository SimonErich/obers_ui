// Tests are internal; doc comments on local helpers are not required.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';

/// Wraps [child] with [OiPlatform] providing [data], plus a [Directionality].
Widget buildWithPlatform(OiPlatformData data, Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: OiPlatform(data: data, child: child),
  );
}

void main() {
  group('OiPlatform.of', () {
    testWidgets('throws when not in tree', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (ctx) {
              expect(() => OiPlatform.of(ctx), throwsAssertionError);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('provides data to descendants', (tester) async {
      const data = OiPlatformData(
        platform: TargetPlatform.android,
        keyboardHeight: 0,
        keyboardVisible: false,
        inputModality: OiInputModality.pointer,
      );
      late OiPlatformData captured;

      await tester.pumpWidget(
        buildWithPlatform(
          data,
          Builder(
            builder: (ctx) {
              captured = OiPlatform.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, equals(data));
    });
  });

  group('OiPlatformData', () {
    testWidgets('keyboardHeight comes from viewInsets.bottom', (tester) async {
      const keyboardH = 300.0;
      late OiPlatformData captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: keyboardH),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (ctx) {
                final widget = OiPlatform.fromContext(
                  context: ctx,
                  child: Builder(
                    builder: (innerCtx) {
                      captured = OiPlatform.of(innerCtx);
                      return const SizedBox.shrink();
                    },
                  ),
                );
                return widget;
              },
            ),
          ),
        ),
      );

      expect(captured.keyboardHeight, keyboardH);
    });

    testWidgets('keyboardVisible is true when keyboard is up', (tester) async {
      late OiPlatformData captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 250)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (ctx) {
                return OiPlatform.fromContext(
                  context: ctx,
                  child: Builder(
                    builder: (innerCtx) {
                      captured = OiPlatform.of(innerCtx);
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(captured.keyboardVisible, isTrue);
    });

    testWidgets('keyboardVisible is false when keyboard is hidden', (
      tester,
    ) async {
      late OiPlatformData captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (ctx) {
                return OiPlatform.fromContext(
                  context: ctx,
                  child: Builder(
                    builder: (innerCtx) {
                      captured = OiPlatform.of(innerCtx);
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(captured.keyboardVisible, isFalse);
    });
  });

  group('OiPlatformExt', () {
    testWidgets('context.platform returns OiPlatformData', (tester) async {
      const data = OiPlatformData(
        platform: TargetPlatform.iOS,
        keyboardHeight: 0,
        keyboardVisible: false,
        inputModality: OiInputModality.pointer,
      );
      late OiPlatformData captured;

      await tester.pumpWidget(
        buildWithPlatform(
          data,
          Builder(
            builder: (ctx) {
              captured = ctx.platform;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, equals(data));
      expect(captured.platform, TargetPlatform.iOS);
    });

    testWidgets('context.inputModality returns the modality', (tester) async {
      const data = OiPlatformData(
        platform: TargetPlatform.iOS,
        keyboardHeight: 0,
        keyboardVisible: false,
        inputModality: OiInputModality.touch,
      );
      late OiInputModality captured;

      await tester.pumpWidget(
        buildWithPlatform(
          data,
          Builder(
            builder: (ctx) {
              captured = ctx.inputModality;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, OiInputModality.touch);
    });
  });

  group('OiPlatform.maybeOf', () {
    testWidgets('returns null when no OiPlatform in tree', (tester) async {
      late OiPlatformData? captured;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (ctx) {
              captured = OiPlatform.maybeOf(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });
  });

  group('OiPlatform.updateShouldNotify', () {
    test('returns false when data is unchanged', () {
      const data = OiPlatformData(
        platform: TargetPlatform.android,
        keyboardHeight: 0,
        keyboardVisible: false,
        inputModality: OiInputModality.pointer,
      );
      const child = SizedBox.shrink();
      const oldWidget = OiPlatform(data: data, child: child);
      const newWidget = OiPlatform(data: data, child: child);
      expect(newWidget.updateShouldNotify(oldWidget), isFalse);
    });

    test('returns true when data changes', () {
      const child = SizedBox.shrink();
      const oldData = OiPlatformData(
        platform: TargetPlatform.android,
        keyboardHeight: 0,
        keyboardVisible: false,
        inputModality: OiInputModality.pointer,
      );
      const newData = OiPlatformData(
        platform: TargetPlatform.android,
        keyboardHeight: 300,
        keyboardVisible: true,
        inputModality: OiInputModality.pointer,
      );
      const oldWidget = OiPlatform(data: oldData, child: child);
      const newWidget = OiPlatform(data: newData, child: child);
      expect(newWidget.updateShouldNotify(oldWidget), isTrue);
    });
  });

  group('OiInputModality in OiPlatformData', () {
    test('equality includes inputModality', () {
      const a = OiPlatformData(
        platform: TargetPlatform.android,
        keyboardHeight: 0,
        keyboardVisible: false,
        inputModality: OiInputModality.pointer,
      );
      const b = OiPlatformData(
        platform: TargetPlatform.android,
        keyboardHeight: 0,
        keyboardVisible: false,
        inputModality: OiInputModality.touch,
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes inputModality', () {
      const data = OiPlatformData(
        platform: TargetPlatform.android,
        keyboardHeight: 0,
        keyboardVisible: false,
        inputModality: OiInputModality.touch,
      );
      expect(data.toString(), contains('inputModality'));
      expect(data.toString(), contains('touch'));
    });

    testWidgets('fromContext defaults inputModality to pointer', (
      tester,
    ) async {
      late OiPlatformData captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (ctx) {
                return OiPlatform.fromContext(
                  context: ctx,
                  child: Builder(
                    builder: (innerCtx) {
                      captured = OiPlatform.of(innerCtx);
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(captured.inputModality, OiInputModality.pointer);
    });
  });

  group('OiPlatform aspects', () {
    Widget host({required double inset, required Widget child}) {
      return MediaQuery(
        data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: inset)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (ctx) =>
                OiPlatform.fromContext(context: ctx, child: child),
          ),
        ),
      );
    }

    testWidgets('minTouchTarget readers are not rebuilt by keyboard insets', (
      tester,
    ) async {
      var builds = 0;
      final probe = Builder(
        builder: (ctx) {
          builds++;
          OiA11y.minTouchTarget(ctx);
          return const SizedBox.shrink();
        },
      );

      for (var frame = 0; frame <= 10; frame++) {
        await tester.pumpWidget(host(inset: frame * 30.0, child: probe));
      }

      expect(builds, 1);
    });

    testWidgets('inputModalityOf and context.inputModality ignore insets', (
      tester,
    ) async {
      var builds = 0;
      final probe = Builder(
        builder: (ctx) {
          builds++;
          OiPlatform.inputModalityOf(ctx);
          ctx.inputModality;
          OiPlatform.platformOf(ctx);
          return const SizedBox.shrink();
        },
      );

      for (var frame = 0; frame <= 10; frame++) {
        await tester.pumpWidget(host(inset: frame * 30.0, child: probe));
      }

      expect(builds, 1);
    });

    testWidgets('keyboardHeightOf and of() still follow the insets', (
      tester,
    ) async {
      final heights = <double>[];
      var fullBuilds = 0;
      final probe = Column(
        children: [
          Builder(
            builder: (ctx) {
              heights.add(OiPlatform.keyboardHeightOf(ctx));
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (ctx) {
              fullBuilds++;
              OiPlatform.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ],
      );

      for (var frame = 0; frame < 3; frame++) {
        await tester.pumpWidget(host(inset: frame * 30.0, child: probe));
      }

      expect(heights, [0.0, 30.0, 60.0]);
      expect(fullBuilds, 3);
    });

    testWidgets('inputModalityOf rebuilds when the modality changes', (
      tester,
    ) async {
      final seen = <OiInputModality>[];
      final probe = Builder(
        builder: (ctx) {
          seen.add(OiPlatform.inputModalityOf(ctx));
          return const SizedBox.shrink();
        },
      );
      Widget withModality(OiInputModality modality) => Directionality(
        textDirection: TextDirection.ltr,
        child: OiPlatform(
          data: OiPlatformData(
            platform: TargetPlatform.android,
            keyboardHeight: 0,
            keyboardVisible: false,
            inputModality: modality,
          ),
          child: probe,
        ),
      );

      await tester.pumpWidget(withModality(OiInputModality.pointer));
      await tester.pumpWidget(withModality(OiInputModality.touch));

      expect(seen, [OiInputModality.pointer, OiInputModality.touch]);
    });
  });
}
