// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';

/// Wraps [child] with [OiPlatform] providing [data], plus a [Directionality].
Widget buildWithPlatform(OiPlatformData data, Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: OiPlatform(
      data: data,
      child: child,
    ),
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
        isKeyboardVisible: false,
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

    testWidgets('isKeyboardVisible is true when keyboard is up', (tester) async {
      late OiPlatformData captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: 250),
          ),
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

      expect(captured.isKeyboardVisible, isTrue);
    });

    testWidgets('isKeyboardVisible is false when keyboard is hidden',
        (tester) async {
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

      expect(captured.isKeyboardVisible, isFalse);
    });
  });

  group('OiPlatformExt', () {
    testWidgets('context.platform returns OiPlatformData', (tester) async {
      const data = OiPlatformData(
        platform: TargetPlatform.iOS,
        keyboardHeight: 0,
        isKeyboardVisible: false,
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
        isKeyboardVisible: false,
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
        isKeyboardVisible: false,
      );
      const newData = OiPlatformData(
        platform: TargetPlatform.android,
        keyboardHeight: 300,
        isKeyboardVisible: true,
      );
      const oldWidget = OiPlatform(data: oldData, child: child);
      const newWidget = OiPlatform(data: newData, child: child);
      expect(newWidget.updateShouldNotify(oldWidget), isTrue);
    });
  });
}
