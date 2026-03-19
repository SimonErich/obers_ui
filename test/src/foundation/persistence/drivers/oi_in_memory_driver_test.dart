import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_in_memory_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

import 'driver_contract_tests.dart';

// Const constructors omitted in tests for readability.
// ignore_for_file: prefer_const_constructors

class _TestSettings with OiSettingsData {
  const _TestSettings({this.count = 0});

  factory _TestSettings.fromJson(Map<String, dynamic> json) =>
      _TestSettings(count: (json['count'] as int?) ?? 0);

  final int count;

  @override
  int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() => {
    'count': count,
    'schemaVersion': schemaVersion,
  };
}

void main() {
  group('OiInMemorySettingsDriver', () {
    late OiInMemorySettingsDriver driver;

    setUp(() {
      driver = OiInMemorySettingsDriver();
    });

    // ── Shared contract tests ───────────────────────────────────────────────

    group('contract', () {
      runDriverContractTests(OiInMemorySettingsDriver.new);
    });

    // ── Driver-specific tests ───────────────────────────────────────────────

    test('save with key uses namespaced key', () async {
      const settings = _TestSettings(count: 7);
      await driver.save<_TestSettings>(
        namespace: 'ns',
        key: 'item1',
        data: settings,
        serialize: (d) => d.toJson(),
      );
      expect(driver.store.containsKey('ns::item1'), isTrue);
      expect(driver.store.containsKey('ns'), isFalse);
    });

    test('store map is directly inspectable', () async {
      await driver.save<_TestSettings>(
        namespace: 'ns',
        data: const _TestSettings(count: 10),
        serialize: (d) => d.toJson(),
      );
      expect(driver.store['ns'], isNotNull);
      expect(driver.store['ns']!['count'], 10);
    });

    test('clear removes all entries', () async {
      await driver.save<_TestSettings>(
        namespace: 'ns1',
        data: const _TestSettings(count: 1),
        serialize: (d) => d.toJson(),
      );
      await driver.save<_TestSettings>(
        namespace: 'ns2',
        data: const _TestSettings(count: 2),
        serialize: (d) => d.toJson(),
      );
      driver.clear();
      expect(driver.store, isEmpty);
    });

    // ── Goal 6: sync driver returns SynchronousFuture ─────────────────────

    test('load returns SynchronousFuture', () {
      final future = driver.load<_TestSettings>(
        namespace: 'ns',
        deserialize: _TestSettings.fromJson,
      );
      expect(future, isA<SynchronousFuture<_TestSettings?>>());
    });

    test('save returns SynchronousFuture', () {
      final future = driver.save<_TestSettings>(
        namespace: 'ns',
        data: const _TestSettings(count: 1),
        serialize: (d) => d.toJson(),
      );
      expect(future, isA<SynchronousFuture<void>>());
    });

    test('delete returns SynchronousFuture', () {
      final future = driver.delete(namespace: 'ns');
      expect(future, isA<SynchronousFuture<void>>());
    });

    test('exists returns SynchronousFuture', () {
      final future = driver.exists(namespace: 'ns');
      expect(future, isA<SynchronousFuture<bool>>());
    });
  });
}
