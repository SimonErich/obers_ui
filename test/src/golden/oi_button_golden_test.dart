// Golden tests have no public API.
// ignore_for_file: public_member_api_docs

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

void main() {
  // ── Light theme ───────────────────────────────────────────────────────────

  testGoldens('OiButton variants — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      children: {
        'Primary': const OiButton.primary(label: 'Click'),
        'Secondary': const OiButton.secondary(label: 'Click'),
        'Outline': const OiButton.outline(label: 'Click'),
        'Ghost': const OiButton.ghost(label: 'Click'),
        'Destructive': const OiButton.destructive(label: 'Click'),
        'Soft': const OiButton.soft(label: 'Click'),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_button_variants_light');
  });

  testGoldens('OiButton variants — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      theme: OiThemeData.dark(),
      children: {
        'Primary': const OiButton.primary(label: 'Click'),
        'Secondary': const OiButton.secondary(label: 'Click'),
        'Outline': const OiButton.outline(label: 'Click'),
        'Ghost': const OiButton.ghost(label: 'Click'),
        'Destructive': const OiButton.destructive(label: 'Click'),
        'Soft': const OiButton.soft(label: 'Click'),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_button_variants_dark');
  });

  // ── Sizes ─────────────────────────────────────────────────────────────────

  testGoldens('OiButton sizes — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      children: {
        'Small': const OiButton.primary(
          label: 'Click',
          size: OiButtonSize.small,
        ),
        'Medium': const OiButton.primary(label: 'Click'),
        'Large': const OiButton.primary(
          label: 'Click',
          size: OiButtonSize.large,
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_button_sizes_light');
  });

  testGoldens('OiButton sizes — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      theme: OiThemeData.dark(),
      children: {
        'Small': const OiButton.primary(
          label: 'Click',
          size: OiButtonSize.small,
        ),
        'Medium': const OiButton.primary(label: 'Click'),
        'Large': const OiButton.primary(
          label: 'Click',
          size: OiButtonSize.large,
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_button_sizes_dark');
  });

  // ── Disabled state ────────────────────────────────────────────────────────

  testGoldens('OiButton disabled — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      children: {
        'Primary disabled': const OiButton.primary(
          label: 'Click',
          enabled: false,
        ),
        'Secondary disabled': const OiButton.secondary(
          label: 'Click',
          enabled: false,
        ),
        'Outline disabled': const OiButton.outline(
          label: 'Click',
          enabled: false,
        ),
        'Ghost disabled': const OiButton.ghost(label: 'Click', enabled: false),
        'Destructive disabled': const OiButton.destructive(
          label: 'Click',
          enabled: false,
        ),
        'Soft disabled': const OiButton.soft(label: 'Click', enabled: false),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_button_disabled_light');
  });

  testGoldens('OiButton disabled — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      theme: OiThemeData.dark(),
      children: {
        'Primary disabled': const OiButton.primary(
          label: 'Click',
          enabled: false,
        ),
        'Secondary disabled': const OiButton.secondary(
          label: 'Click',
          enabled: false,
        ),
        'Outline disabled': const OiButton.outline(
          label: 'Click',
          enabled: false,
        ),
        'Ghost disabled': const OiButton.ghost(label: 'Click', enabled: false),
        'Destructive disabled': const OiButton.destructive(
          label: 'Click',
          enabled: false,
        ),
        'Soft disabled': const OiButton.soft(label: 'Click', enabled: false),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_button_disabled_dark');
  });
}
