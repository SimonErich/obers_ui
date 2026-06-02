// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

Future<void> main() async {
  // ── OiCheckbox ────────────────────────────────────────────────────────────

  await goldenTest(
    'OiCheckbox states — light',
    fileName: 'oi_checkbox_states_light',
    builder: () => obersGoldenGroup(
      columns: 3,
      children: {
        'Unchecked': const OiCheckbox(value: false, label: 'Off'),
        'Checked': const OiCheckbox(value: true, label: 'On'),
        'Indeterminate': const OiCheckbox(value: null, label: 'Mixed'),
      },
    ),
  );

  await goldenTest(
    'OiCheckbox states — dark',
    fileName: 'oi_checkbox_states_dark',
    builder: () => obersGoldenGroup(
      columns: 3,
      theme: OiThemeData.dark(),
      children: {
        'Unchecked': const OiCheckbox(value: false, label: 'Off'),
        'Checked': const OiCheckbox(value: true, label: 'On'),
        'Indeterminate': const OiCheckbox(value: null, label: 'Mixed'),
      },
    ),
  );

  // ── OiSwitch ──────────────────────────────────────────────────────────────

  await goldenTest(
    'OiSwitch states — light',
    fileName: 'oi_switch_states_light',
    builder: () => obersGoldenGroup(
      children: {
        'Off': const OiSwitch(value: false, label: 'Off'),
        'On': const OiSwitch(value: true, label: 'On'),
      },
    ),
  );

  await goldenTest(
    'OiSwitch states — dark',
    fileName: 'oi_switch_states_dark',
    builder: () => obersGoldenGroup(
      theme: OiThemeData.dark(),
      children: {
        'Off': const OiSwitch(value: false, label: 'Off'),
        'On': const OiSwitch(value: true, label: 'On'),
      },
    ),
  );
}
