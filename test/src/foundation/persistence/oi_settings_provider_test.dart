// Tests for OiSettingsProvider – InheritedWidget driver lookup.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_in_memory_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';

void main() {
  group('OiSettingsProvider', () {
    testWidgets('of returns null when no provider', (t) async {
      late OiSettingsDriver? result;
      await t.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (ctx) {
              result = OiSettingsProvider.of(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, isNull);
    });

    testWidgets('of returns driver when provider present', (t) async {
      final driver = OiInMemorySettingsDriver();
      late OiSettingsDriver? result;
      await t.pumpWidget(
        OiSettingsProvider(
          driver: driver,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (ctx) {
                result = OiSettingsProvider.of(ctx);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(result, equals(driver));
    });

    test('updateShouldNotify returns false for same driver', () {
      final driver = OiInMemorySettingsDriver();
      final w1 = OiSettingsProvider(driver: driver, child: const SizedBox());
      final w2 = OiSettingsProvider(driver: driver, child: const SizedBox());
      expect(w1.updateShouldNotify(w2), isFalse);
    });

    test('updateShouldNotify returns true for different driver', () {
      final w1 = OiSettingsProvider(
        driver: OiInMemorySettingsDriver(),
        child: const SizedBox(),
      );
      final w2 = OiSettingsProvider(
        driver: OiInMemorySettingsDriver(),
        child: const SizedBox(),
      );
      expect(w1.updateShouldNotify(w2), isTrue);
    });
  });
}
