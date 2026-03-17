import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_in_memory_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

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

    test('load returns null when nothing saved', () async {
      final result = await driver.load<_TestSettings>(
        namespace: 'ns',
        deserialize: _TestSettings.fromJson,
      );
      expect(result, isNull);
    });

    test('save then load round-trips correctly', () async {
      const settings = _TestSettings(count: 42);
      await driver.save<_TestSettings>(
        namespace: 'ns',
        data: settings,
        serialize: (d) => d.toJson(),
      );
      final loaded = await driver.load<_TestSettings>(
        namespace: 'ns',
        deserialize: _TestSettings.fromJson,
      );
      expect(loaded, isNotNull);
      expect(loaded!.count, 42);
    });

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

    test('exists returns false before save', () async {
      final result = await driver.exists(namespace: 'ns');
      expect(result, isFalse);
    });

    test('exists returns true after save', () async {
      await driver.save<_TestSettings>(
        namespace: 'ns',
        data: const _TestSettings(),
        serialize: (d) => d.toJson(),
      );
      final result = await driver.exists(namespace: 'ns');
      expect(result, isTrue);
    });

    test('delete removes the entry', () async {
      await driver.save<_TestSettings>(
        namespace: 'ns',
        data: const _TestSettings(),
        serialize: (d) => d.toJson(),
      );
      await driver.delete(namespace: 'ns');
      final result = await driver.exists(namespace: 'ns');
      expect(result, isFalse);
    });

    test('load returns null after delete', () async {
      await driver.save<_TestSettings>(
        namespace: 'ns',
        data: const _TestSettings(count: 5),
        serialize: (d) => d.toJson(),
      );
      await driver.delete(namespace: 'ns');
      final loaded = await driver.load<_TestSettings>(
        namespace: 'ns',
        deserialize: _TestSettings.fromJson,
      );
      expect(loaded, isNull);
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

    test('load returns null when deserialize throws', () async {
      driver.store['ns'] = {'bad': 'data'};
      // Override deserialize to throw
      final result = await driver.load<_TestSettings>(
        namespace: 'ns',
        deserialize: (_) => throw const FormatException('bad'),
      );
      expect(result, isNull);
    });

    test('different keys do not interfere', () async {
      await driver.save<_TestSettings>(
        namespace: 'ns',
        key: 'a',
        data: const _TestSettings(count: 1),
        serialize: (d) => d.toJson(),
      );
      await driver.save<_TestSettings>(
        namespace: 'ns',
        key: 'b',
        data: const _TestSettings(count: 2),
        serialize: (d) => d.toJson(),
      );
      final a = await driver.load<_TestSettings>(
        namespace: 'ns',
        key: 'a',
        deserialize: _TestSettings.fromJson,
      );
      final b = await driver.load<_TestSettings>(
        namespace: 'ns',
        key: 'b',
        deserialize: _TestSettings.fromJson,
      );
      expect(a!.count, 1);
      expect(b!.count, 2);
    });
  });
}
