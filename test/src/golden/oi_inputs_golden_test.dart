// Golden tests have no public API.

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

void main() {
  // ── OiCheckbox ────────────────────────────────────────────────────────────

  testGoldens('OiCheckbox states — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      children: {
        'Unchecked': const OiCheckbox(value: false, label: 'Off'),
        'Checked': const OiCheckbox(value: true, label: 'On'),
        'Indeterminate': const OiCheckbox(value: null, label: 'Mixed'),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_checkbox_states_light');
  });

  testGoldens('OiCheckbox states — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      theme: OiThemeData.dark(),
      children: {
        'Unchecked': const OiCheckbox(value: false, label: 'Off'),
        'Checked': const OiCheckbox(value: true, label: 'On'),
        'Indeterminate': const OiCheckbox(value: null, label: 'Mixed'),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_checkbox_states_dark');
  });

  // ── OiSwitch ──────────────────────────────────────────────────────────────

  testGoldens('OiSwitch states — light', (tester) async {
    final builder = obersGoldenBuilder(
      children: {
        'Off': const OiSwitch(value: false, label: 'Off'),
        'On': const OiSwitch(value: true, label: 'On'),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_switch_states_light');
  });

  testGoldens('OiSwitch states — dark', (tester) async {
    final builder = obersGoldenBuilder(
      theme: OiThemeData.dark(),
      children: {
        'Off': const OiSwitch(value: false, label: 'Off'),
        'On': const OiSwitch(value: true, label: 'On'),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_switch_states_dark');
  });
}
