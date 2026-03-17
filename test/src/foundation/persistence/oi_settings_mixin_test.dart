// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs
// Tests for OiSettingsMixin – load, save, debounce, reset, and dispose.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_in_memory_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';

class _S with OiSettingsData {
  const _S({this.n = 0});

  factory _S.fromJson(Map<String, dynamic> j) => _S(n: (j['n'] as int?) ?? 0);

  final int n;

  @override
  int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() => {'n': n, 'schemaVersion': 1};
}

// OiSettingsMixin is `on State<StatefulWidget>` (exact type). To satisfy this
// constraint, _WState must extend State<StatefulWidget>, which requires _W to
// also be typed as StatefulWidget in the createState return. We achieve this
// by overriding createState with return type State<StatefulWidget>.
class _W extends StatefulWidget {
  const _W({this.driver});

  final OiSettingsDriver? driver;

  @override
  // The return type must be State<StatefulWidget> so _WState (which mixes in
  // OiSettingsMixin that is `on State<StatefulWidget>`) satisfies the constraint.
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _WState();
}

class _WState extends State<StatefulWidget> with OiSettingsMixin<_S> {
  _W get _w => widget as _W;

  @override
  String get settingsNamespace => 'test';

  @override
  String? get settingsKey => null;

  @override
  OiSettingsDriver? get settingsDriver => _w.driver;

  @override
  _S get defaultSettings => const _S();

  @override
  _S deserializeSettings(Map<String, dynamic> j) => _S.fromJson(j);

  @override
  _S mergeSettings(_S saved, _S defaults) => saved;

  void runUpdate(
    _S s, {
    Duration debounce = const Duration(milliseconds: 500),
  }) =>
      updateSettings(s, debounce: debounce);

  Future<void> runSaveNow() => saveSettingsNow();

  Future<void> runReset() => resetSettings();

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  Widget wrap(Widget w) =>
      Directionality(textDirection: TextDirection.ltr, child: w);

  group('OiSettingsMixin', () {
    testWidgets('no driver: currentSettings equals defaultSettings', (t) async {
      await t.pumpWidget(wrap(const _W()));
      final state = t.state<_WState>(find.byType(_W));
      expect(state.currentSettings.n, equals(0));
    });

    testWidgets('no driver: settingsLoaded is true after pump', (t) async {
      await t.pumpWidget(wrap(const _W()));
      await t.pump();
      final state = t.state<_WState>(find.byType(_W));
      expect(state.settingsLoaded, isTrue);
    });

    testWidgets(
        'driver with no saved data: currentSettings equals defaults', (t) async {
      final driver = OiInMemorySettingsDriver();
      await t.pumpWidget(wrap(_W(driver: driver)));
      await t.pump();
      final state = t.state<_WState>(find.byType(_W));
      expect(state.currentSettings.n, equals(0));
    });

    testWidgets('driver with saved data: currentSettings is restored',
        (t) async {
      final driver = OiInMemorySettingsDriver();
      await driver.save(
        namespace: 'test',
        data: const _S(n: 99),
        serialize: (s) => s.toJson(),
      );
      await t.pumpWidget(wrap(_W(driver: driver)));
      await t.pump();
      final state = t.state<_WState>(find.byType(_W));
      expect(state.currentSettings.n, equals(99));
    });

    testWidgets('updateSettings changes currentSettings immediately', (t) async {
      await t.pumpWidget(wrap(const _W()));
      final state = t.state<_WState>(find.byType(_W))
        ..runUpdate(const _S(n: 7), debounce: const Duration(seconds: 60));
      expect(state.currentSettings.n, equals(7));
    });

    testWidgets('updateSettings saves after debounce', (t) async {
      final driver = OiInMemorySettingsDriver();
      await t.pumpWidget(wrap(_W(driver: driver)));
      t.state<_WState>(find.byType(_W)).runUpdate(
        const _S(n: 5),
        debounce: const Duration(milliseconds: 100),
      );
      final store = driver.store;
      expect(store.isEmpty, isTrue);
      await t.pump(const Duration(milliseconds: 150));
      expect(store.isNotEmpty, isTrue);
    });

    testWidgets('saveSettingsNow saves immediately', (t) async {
      final driver = OiInMemorySettingsDriver();
      await t.pumpWidget(wrap(_W(driver: driver)));
      final state = t.state<_WState>(find.byType(_W))
        ..runUpdate(const _S(n: 42), debounce: const Duration(seconds: 60));
      await state.runSaveNow();
      expect(driver.store.isNotEmpty, isTrue);
    });

    testWidgets(
        'resetSettings reverts to defaults and deletes from driver', (t) async {
      final driver = OiInMemorySettingsDriver();
      await driver.save(
        namespace: 'test',
        data: const _S(n: 10),
        serialize: (s) => s.toJson(),
      );
      await t.pumpWidget(wrap(_W(driver: driver)));
      await t.pump();
      final state = t.state<_WState>(find.byType(_W));
      await state.runReset();
      expect(state.currentSettings.n, equals(0));
      expect(await driver.exists(namespace: 'test'), isFalse);
    });

    testWidgets('dispose cancels pending save timer', (t) async {
      final driver = OiInMemorySettingsDriver();
      await t.pumpWidget(wrap(_W(driver: driver)));
      t.state<_WState>(find.byType(_W)).runUpdate(
        const _S(n: 1),
        debounce: const Duration(seconds: 10),
      );
      await t.pumpWidget(const SizedBox());
    });
  });
}
