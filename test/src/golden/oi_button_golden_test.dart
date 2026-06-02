// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

Future<void> main() async {
  // ── Light theme ───────────────────────────────────────────────────────────

  await goldenTest(
    'OiButton variants — light',
    fileName: 'oi_button_variants_light',
    builder: () => obersGoldenGroup(
      columns: 3,
      children: {
        'Primary': const OiButton.primary(label: 'Click'),
        'Secondary': const OiButton.secondary(label: 'Click'),
        'Outline': const OiButton.outline(label: 'Click'),
        'Ghost': const OiButton.ghost(label: 'Click'),
        'Destructive': const OiButton.destructive(label: 'Click'),
        'Soft': const OiButton.soft(label: 'Click'),
      },
    ),
  );

  await goldenTest(
    'OiButton variants — dark',
    fileName: 'oi_button_variants_dark',
    builder: () => obersGoldenGroup(
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
    ),
  );

  // ── Sizes ─────────────────────────────────────────────────────────────────

  await goldenTest(
    'OiButton sizes — light',
    fileName: 'oi_button_sizes_light',
    builder: () => obersGoldenGroup(
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
    ),
  );

  await goldenTest(
    'OiButton sizes — dark',
    fileName: 'oi_button_sizes_dark',
    builder: () => obersGoldenGroup(
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
    ),
  );

  // ── Disabled state ────────────────────────────────────────────────────────

  await goldenTest(
    'OiButton disabled — light',
    fileName: 'oi_button_disabled_light',
    builder: () => obersGoldenGroup(
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
    ),
  );

  await goldenTest(
    'OiButton disabled — dark',
    fileName: 'oi_button_disabled_dark',
    builder: () => obersGoldenGroup(
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
    ),
  );
}
