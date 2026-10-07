import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  testWidgets('native auto density follows each platform unless authored', (
    tester,
  ) async {
    final previous = debugDefaultTargetPlatformOverride;
    OiDensity? captured;
    final content = Builder(
      builder: (context) {
        captured = OiDensityScope.of(context);
        return const SizedBox();
      },
    );
    try {
      for (final platform in TargetPlatform.values) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          OiApp(key: ValueKey(platform), home: content),
        );
        expect(
          captured,
          platform == TargetPlatform.iOS || platform == TargetPlatform.android
              ? OiDensity.comfortable
              : OiDensity.compact,
          reason: platform.name,
        );
        await tester.pumpWidget(
          OiApp(
            key: ValueKey('${platform.name}-authored'),
            density: OiDensity.dense,
            home: content,
          ),
        );
        expect(captured, OiDensity.dense, reason: platform.name);
        expect(tester.takeException(), isNull);
      }
    } finally {
      debugDefaultTargetPlatformOverride = previous;
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('settings driver is usable in descendants and can be removed', (
    tester,
  ) async {
    final driver = OiInMemorySettingsDriver();
    OiSettingsDriver? captured;
    final content = Builder(
      builder: (context) {
        captured = OiSettingsProvider.of(context);
        return const SizedBox();
      },
    );
    await tester.pumpWidget(OiApp(settingsDriver: driver, home: content));
    expect(captured, same(driver));
    expect(await captured!.exists(namespace: 'root-app-scope'), isFalse);
    await tester.pumpWidget(OiApp(home: content));
    expect(captured, isNull);
    expect(tester.takeException(), isNull);
  });
}
