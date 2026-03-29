// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_local_storage_driver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'driver_contract_tests.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OiLocalStorageDriver', () {
    // ── Shared contract tests ───────────────────────────────────────────────

    group('contract', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      runDriverContractTests(() => const OiLocalStorageDriver());
    });

    // ── Driver-specific tests ───────────────────────────────────────────────

    test('resolveKey prepends default prefix', () {
      const driver = OiLocalStorageDriver();
      expect(driver.resolveKey('oi_table', null), equals('obers_ui.oi_table'));
    });

    test('resolveKey prepends default prefix with key', () {
      const driver = OiLocalStorageDriver();
      expect(
        driver.resolveKey('oi_table', 'my-key'),
        equals('obers_ui.oi_table::my-key'),
      );
    });

    test('resolveKey uses custom prefix', () {
      const driver = OiLocalStorageDriver(prefix: 'myapp');
      expect(
        driver.resolveKey('oi_table', 'my-key'),
        equals('myapp.oi_table::my-key'),
      );
    });

    test('corrupted JSON returns null', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('obers_ui.test', 'not-valid-json{{{');
      const driver = OiLocalStorageDriver();
      final result = await driver.load(
        namespace: 'test',
        deserialize: ContractTestSettings.fromJson,
      );
      expect(result, isNull);
    });
  });
}
