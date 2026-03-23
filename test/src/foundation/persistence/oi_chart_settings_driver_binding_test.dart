// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_in_memory_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_chart_settings_driver_binding.dart';
import 'package:obers_ui/src/models/settings/oi_chart_settings.dart';

void main() {
  group('OiChartSettingsDriverBinding', () {
    late OiInMemorySettingsDriver driver;

    setUp(() {
      driver = OiInMemorySettingsDriver();
    });

    // ── init / restore ────────────────────────────────────────────────────

    test('init with restoreOnInit loads saved settings', () async {
      // Pre-save settings.
      await driver.save<OiChartSettings>(
        namespace: 'oi_chart',
        key: 'test-chart',
        data: const OiChartSettings(hiddenSeriesIds: {'revenue'}),
        serialize: (s) => s.toJson(),
      );

      final binding = OiChartSettingsDriverBinding(
        key: 'test-chart',
        driver: driver,
      );
      await binding.init();

      expect(binding.initialized, isTrue);
      expect(binding.currentSettings.hiddenSeriesIds, {'revenue'});
      binding.dispose();
    });

    test('init without restoreOnInit keeps defaults', () async {
      // Pre-save settings.
      await driver.save<OiChartSettings>(
        namespace: 'oi_chart',
        key: 'test-chart',
        data: const OiChartSettings(hiddenSeriesIds: {'revenue'}),
        serialize: (s) => s.toJson(),
      );

      final binding = OiChartSettingsDriverBinding(
        key: 'test-chart',
        driver: driver,
        restoreOnInit: false,
      );
      await binding.init();

      expect(binding.initialized, isTrue);
      expect(binding.currentSettings.hiddenSeriesIds, isEmpty);
      binding.dispose();
    });

    test('init without saved data keeps defaults', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'new-chart',
        driver: driver,
      );
      await binding.init();

      expect(binding.initialized, isTrue);
      expect(binding.currentSettings, const OiChartSettings());
      binding.dispose();
    });

    test('init respects defaultSettings parameter', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'chart',
        driver: driver,
        defaultSettings: const OiChartSettings(
          comparisonMode: OiChartComparisonMode.baseline,
        ),
      );
      await binding.init();

      expect(
        binding.currentSettings.comparisonMode,
        OiChartComparisonMode.baseline,
      );
      binding.dispose();
    });

    // ── update / autoSave ─────────────────────────────────────────────────

    test('update changes currentSettings', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'chart',
        driver: driver,
        autoSave: false,
      );
      await binding.init();

      binding.update(
        const OiChartSettings(hiddenSeriesIds: {'costs'}),
      );
      expect(binding.currentSettings.hiddenSeriesIds, {'costs'});
      binding.dispose();
    });

    test('update notifies listeners', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'chart',
        driver: driver,
        autoSave: false,
      );
      await binding.init();

      var notified = false;
      binding.addListener(() => notified = true);
      binding.update(
        const OiChartSettings(hiddenSeriesIds: {'costs'}),
      );
      expect(notified, isTrue);
      binding.dispose();
    });

    test('update does not notify when settings are unchanged', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'chart',
        driver: driver,
        autoSave: false,
      );
      await binding.init();

      var notifyCount = 0;
      binding.addListener(() => notifyCount++);
      binding.update(const OiChartSettings());
      expect(notifyCount, 0);
      binding.dispose();
    });

    // ── saveNow ───────────────────────────────────────────────────────────

    test('saveNow persists to driver immediately', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'chart',
        driver: driver,
        autoSave: false,
      );
      await binding.init();

      binding.update(
        const OiChartSettings(hiddenSeriesIds: {'a'}),
      );
      await binding.saveNow();

      final loaded = await driver.load<OiChartSettings>(
        namespace: 'oi_chart',
        key: 'chart',
        deserialize: OiChartSettings.fromJson,
      );
      expect(loaded?.hiddenSeriesIds, {'a'});
      binding.dispose();
    });

    // ── reset ─────────────────────────────────────────────────────────────

    test('reset deletes persisted settings and resets to defaults', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'chart',
        driver: driver,
      );
      await binding.init();

      binding.update(
        const OiChartSettings(hiddenSeriesIds: {'a'}),
      );
      await binding.saveNow();
      await binding.reset();

      expect(binding.currentSettings, const OiChartSettings());
      final exists = await driver.exists(namespace: 'oi_chart', key: 'chart');
      expect(exists, isFalse);
      binding.dispose();
    });

    test('reset accepts custom defaults', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'chart',
        driver: driver,
      );
      await binding.init();

      await binding.reset(
        const OiChartSettings(
          comparisonMode: OiChartComparisonMode.yearOverYear,
        ),
      );
      expect(
        binding.currentSettings.comparisonMode,
        OiChartComparisonMode.yearOverYear,
      );
      binding.dispose();
    });

    // ── reload ────────────────────────────────────────────────────────────

    test('reload refreshes from driver', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'chart',
        driver: driver,
      );
      await binding.init();

      // External save.
      await driver.save<OiChartSettings>(
        namespace: 'oi_chart',
        key: 'chart',
        data: const OiChartSettings(legendExpandedGroups: {'g1'}),
        serialize: (s) => s.toJson(),
      );

      await binding.reload();
      expect(binding.currentSettings.legendExpandedGroups, {'g1'});
      binding.dispose();
    });

    // ── dispose safety ────────────────────────────────────────────────────

    test('update after dispose is a no-op', () async {
      final binding = OiChartSettingsDriverBinding(
        key: 'chart',
        driver: driver,
        autoSave: false,
      );
      await binding.init();
      binding.dispose();

      // Should not throw.
      binding.update(
        const OiChartSettings(hiddenSeriesIds: {'a'}),
      );
    });

    // ── namespace ─────────────────────────────────────────────────────────

    test('namespace is oi_chart', () {
      expect(OiChartSettingsDriverBinding.namespace, 'oi_chart');
    });
  });
}
