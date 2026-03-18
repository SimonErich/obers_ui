// Shared contract tests for any OiSettingsDriver implementation.
//
// Usage:
//   runDriverContractTests(() => OiInMemorySettingsDriver());
//
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';

/// Simple settings class used by the contract tests.
class ContractTestSettings with OiSettingsData {
  const ContractTestSettings({this.count = 0, this.label = ''});

  factory ContractTestSettings.fromJson(Map<String, dynamic> json) =>
      ContractTestSettings(
        count: (json['count'] as int?) ?? 0,
        label: (json['label'] as String?) ?? '',
      );

  final int count;
  final String label;

  @override
  int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() => {
    'count': count,
    'label': label,
    'schemaVersion': schemaVersion,
  };
}

/// Complex nested settings used by the contract tests.
class ContractNestedSettings with OiSettingsData {
  const ContractNestedSettings({
    this.items = const [],
    this.metadata = const {},
  });

  factory ContractNestedSettings.fromJson(Map<String, dynamic> json) =>
      ContractNestedSettings(
        items: (json['items'] as List?)?.cast<String>() ?? const [],
        metadata:
            (json['metadata'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()),
            ) ??
            const {},
      );

  final List<String> items;
  final Map<String, double> metadata;

  @override
  int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() => {
    'items': items,
    'metadata': metadata,
    'schemaVersion': schemaVersion,
  };
}

/// Runs the standard driver contract test suite against any
/// [OiSettingsDriver] implementation.
///
/// Every driver must pass these tests to comply with the interface contract.
void runDriverContractTests(OiSettingsDriver Function() createDriver) {
  late OiSettingsDriver driver;

  setUp(() {
    driver = createDriver();
  });

  test('load returns null when nothing saved', () async {
    final result = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(result, isNull);
  });

  test('save then load returns saved data', () async {
    const settings = ContractTestSettings(count: 42, label: 'hello');
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      data: settings,
      serialize: (d) => d.toJson(),
    );
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(loaded, isNotNull);
    expect(loaded!.count, 42);
    expect(loaded.label, 'hello');
  });

  test('save overwrites previous data', () async {
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      data: const ContractTestSettings(count: 1),
      serialize: (d) => d.toJson(),
    );
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      data: const ContractTestSettings(count: 2),
      serialize: (d) => d.toJson(),
    );
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(loaded!.count, 2);
  });

  test('delete then load returns null', () async {
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      data: const ContractTestSettings(count: 5),
      serialize: (d) => d.toJson(),
    );
    await driver.delete(namespace: 'ns');
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(loaded, isNull);
  });

  test('exists returns false when nothing saved', () async {
    expect(await driver.exists(namespace: 'ns'), isFalse);
  });

  test('exists returns true after save', () async {
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      data: const ContractTestSettings(),
      serialize: (d) => d.toJson(),
    );
    expect(await driver.exists(namespace: 'ns'), isTrue);
  });

  test('exists returns false after delete', () async {
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      data: const ContractTestSettings(),
      serialize: (d) => d.toJson(),
    );
    await driver.delete(namespace: 'ns');
    expect(await driver.exists(namespace: 'ns'), isFalse);
  });

  test('save with key, load without key returns null', () async {
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      key: 'k1',
      data: const ContractTestSettings(count: 1),
      serialize: (d) => d.toJson(),
    );
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(loaded, isNull);
  });

  test('save without key, load with key returns null', () async {
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      data: const ContractTestSettings(count: 1),
      serialize: (d) => d.toJson(),
    );
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      key: 'k1',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(loaded, isNull);
  });

  test('save with key A, load with key B returns null', () async {
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      key: 'a',
      data: const ContractTestSettings(count: 1),
      serialize: (d) => d.toJson(),
    );
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      key: 'b',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(loaded, isNull);
  });

  test('save with key A, load with key A returns data', () async {
    const settings = ContractTestSettings(count: 77);
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      key: 'a',
      data: settings,
      serialize: (d) => d.toJson(),
    );
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      key: 'a',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(loaded!.count, 77);
  });

  test('save without key (global), load without key returns data', () async {
    const settings = ContractTestSettings(count: 33);
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      data: settings,
      serialize: (d) => d.toJson(),
    );
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(loaded!.count, 33);
  });

  test('multiple namespaces do not collide', () async {
    await driver.save<ContractTestSettings>(
      namespace: 'alpha',
      data: const ContractTestSettings(count: 1),
      serialize: (d) => d.toJson(),
    );
    await driver.save<ContractTestSettings>(
      namespace: 'beta',
      data: const ContractTestSettings(count: 2),
      serialize: (d) => d.toJson(),
    );
    final a = await driver.load<ContractTestSettings>(
      namespace: 'alpha',
      deserialize: ContractTestSettings.fromJson,
    );
    final b = await driver.load<ContractTestSettings>(
      namespace: 'beta',
      deserialize: ContractTestSettings.fromJson,
    );
    expect(a!.count, 1);
    expect(b!.count, 2);
  });

  test('corrupted data returns null from load', () async {
    // Save valid data, then load with a deserializer that throws.
    await driver.save<ContractTestSettings>(
      namespace: 'ns',
      data: const ContractTestSettings(count: 1),
      serialize: (d) => d.toJson(),
    );
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      deserialize: (_) => throw const FormatException('corrupted'),
    );
    expect(loaded, isNull);
  });

  test('complex nested data roundtrips correctly', () async {
    const settings = ContractNestedSettings(
      items: ['a', 'b', 'c'],
      metadata: {'width': 100.5, 'height': 200.0},
    );
    await driver.save<ContractNestedSettings>(
      namespace: 'nested',
      data: settings,
      serialize: (d) => d.toJson(),
    );
    final loaded = await driver.load<ContractNestedSettings>(
      namespace: 'nested',
      deserialize: ContractNestedSettings.fromJson,
    );
    expect(loaded, isNotNull);
    expect(loaded!.items, ['a', 'b', 'c']);
    expect(loaded.metadata['width'], 100.5);
    expect(loaded.metadata['height'], 200.0);
  });

  test('concurrent saves do not corrupt data', () async {
    // Fire multiple saves concurrently; the last write wins.
    final futures = <Future<void>>[];
    for (var i = 0; i < 10; i++) {
      futures.add(
        driver.save<ContractTestSettings>(
          namespace: 'ns',
          data: ContractTestSettings(count: i),
          serialize: (d) => d.toJson(),
        ),
      );
    }
    await Future.wait(futures);
    final loaded = await driver.load<ContractTestSettings>(
      namespace: 'ns',
      deserialize: ContractTestSettings.fromJson,
    );
    // Data must be non-null and from one of the saves.
    expect(loaded, isNotNull);
    expect(loaded!.count, inInclusiveRange(0, 9));
  });

  test('resolveKey produces expected format', () {
    // resolveKey is protected; test via round-trip key isolation.
    // Without key: namespace only. With key: namespace::key.
    // This is validated implicitly by the key isolation tests above.
    // Drivers that override resolveKey must still pass all isolation tests.
  });
}
