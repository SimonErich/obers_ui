// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_local_storage_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple test settings class
class _Prefs with OiSettingsData {
  const _Prefs({this.count = 0});

  factory _Prefs.fromJson(Map<String, dynamic> json) =>
      _Prefs(count: (json['count'] as int?) ?? 0);

  final int count;

  @override
  int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() => {'count': count, 'schemaVersion': 1};
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OiLocalStorageDriver', () {
    test('resolveKey prepends default prefix', () {
      const driver = OiLocalStorageDriver();
      expect(driver.resolveKey('oi_table', null), equals('obers_ui.oi_table'));
    });

    test('resolveKey prepends default prefix with key', () {
      const driver = OiLocalStorageDriver();
      expect(driver.resolveKey('oi_table', 'my-key'), equals('obers_ui.oi_table::my-key'));
    });

    test('resolveKey uses custom prefix', () {
      const driver = OiLocalStorageDriver(prefix: 'myapp');
      expect(driver.resolveKey('oi_table', 'my-key'), equals('myapp.oi_table::my-key'));
    });

    test('load returns null when nothing saved', () async {
      const driver = OiLocalStorageDriver();
      final result = await driver.load(
        namespace: 'test',
        deserialize: _Prefs.fromJson,
      );
      expect(result, isNull);
    });

    test('save then load roundtrips data', () async {
      const driver = OiLocalStorageDriver();
      const prefs = _Prefs(count: 42);
      await driver.save(
        namespace: 'test',
        data: prefs,
        serialize: (p) => p.toJson(),
      );
      final loaded = await driver.load(
        namespace: 'test',
        deserialize: _Prefs.fromJson,
      );
      expect(loaded?.count, equals(42));
    });

    test('exists returns false before save', () async {
      const driver = OiLocalStorageDriver();
      expect(await driver.exists(namespace: 'test'), isFalse);
    });

    test('exists returns true after save', () async {
      const driver = OiLocalStorageDriver();
      await driver.save(
        namespace: 'test',
        data: const _Prefs(count: 1),
        serialize: (p) => p.toJson(),
      );
      expect(await driver.exists(namespace: 'test'), isTrue);
    });

    test('delete removes data', () async {
      const driver = OiLocalStorageDriver();
      await driver.save(
        namespace: 'test',
        data: const _Prefs(count: 1),
        serialize: (p) => p.toJson(),
      );
      await driver.delete(namespace: 'test');
      expect(await driver.exists(namespace: 'test'), isFalse);
      expect(await driver.load(namespace: 'test', deserialize: _Prefs.fromJson), isNull);
    });

    test('corrupted JSON returns null', () async {
      // Manually corrupt the storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('obers_ui.test', 'not-valid-json{{{');
      const driver = OiLocalStorageDriver();
      final result = await driver.load(
        namespace: 'test',
        deserialize: _Prefs.fromJson,
      );
      expect(result, isNull);
    });
  });
}
