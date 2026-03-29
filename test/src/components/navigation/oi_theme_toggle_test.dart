// Tests for OiThemeToggle — REQ-0014.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/components/navigation/oi_theme_toggle.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ────────────────────────────────────────────────────────────

  testWidgets('renders sun icon for light mode', (tester) async {
    await tester.pumpObers(
      OiThemeToggle(currentMode: OiThemeMode.light, onModeChange: (_) {}),
    );
    expect(find.byIcon(OiIcons.sun), findsOneWidget);
  });

  testWidgets('renders moon icon for dark mode', (tester) async {
    await tester.pumpObers(
      OiThemeToggle(currentMode: OiThemeMode.dark, onModeChange: (_) {}),
    );
    expect(find.byIcon(OiIcons.moon), findsOneWidget);
  });

  testWidgets('renders monitor icon for system mode', (tester) async {
    await tester.pumpObers(
      OiThemeToggle(currentMode: OiThemeMode.system, onModeChange: (_) {}),
    );
    expect(find.byIcon(OiIcons.monitor), findsOneWidget);
  });

  // ── Popover mode (showSystemOption=true) ─────────────────────────────────

  testWidgets('showSystemOption=true: tapping opens popover with 3 options', (
    tester,
  ) async {
    await tester.pumpObers(
      OiThemeToggle(currentMode: OiThemeMode.light, onModeChange: (_) {}),
    );

    await tester.tap(find.byIcon(OiIcons.sun));
    await tester.pumpAndSettle();

    expect(find.text('Light mode'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('System mode'), findsOneWidget);
  });

  testWidgets('showSystemOption=true: popover shows correct mode icons', (
    tester,
  ) async {
    await tester.pumpObers(
      OiThemeToggle(currentMode: OiThemeMode.light, onModeChange: (_) {}),
    );

    await tester.tap(find.byIcon(OiIcons.sun));
    await tester.pumpAndSettle();

    // All three mode icons are rendered in the popover.
    expect(find.byIcon(OiIcons.sun), findsWidgets);
    expect(find.byIcon(OiIcons.moon), findsOneWidget);
    expect(find.byIcon(OiIcons.monitor), findsOneWidget);
  });

  // ── Cycle mode (showSystemOption=false) ──────────────────────────────────

  testWidgets('showSystemOption=false: tapping cycles light to dark', (
    tester,
  ) async {
    OiThemeMode? selected;

    await tester.pumpObers(
      OiThemeToggle(
        currentMode: OiThemeMode.light,
        onModeChange: (mode) => selected = mode,
        showSystemOption: false,
      ),
    );

    await tester.tap(find.byIcon(OiIcons.sun));
    await tester.pumpAndSettle();

    expect(selected, OiThemeMode.dark);
  });

  testWidgets('showSystemOption=false: tapping cycles dark to light', (
    tester,
  ) async {
    OiThemeMode? selected;

    await tester.pumpObers(
      OiThemeToggle(
        currentMode: OiThemeMode.dark,
        onModeChange: (mode) => selected = mode,
        showSystemOption: false,
      ),
    );

    await tester.tap(find.byIcon(OiIcons.moon));
    await tester.pumpAndSettle();

    expect(selected, OiThemeMode.light);
  });

  // ── Tooltip ──────────────────────────────────────────────────────────────

  testWidgets('tooltip message matches current mode', (tester) async {
    await tester.pumpObers(
      OiThemeToggle(
        currentMode: OiThemeMode.dark,
        onModeChange: (_) {},
        showSystemOption: false,
      ),
    );

    // Verify the OiTooltip has the correct message for the current mode.
    final tooltip = tester.widget<OiTooltip>(find.byType(OiTooltip));
    expect(tooltip.message, 'Dark mode');
  });

  // ── Accessibility ────────────────────────────────────────────────────────

  testWidgets('semantic label is present', (tester) async {
    await tester.pumpObers(
      OiThemeToggle(
        currentMode: OiThemeMode.light,
        onModeChange: (_) {},
        label: 'Switch theme',
      ),
    );

    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'Switch theme')
        .toList();
    expect(matching, isNotEmpty);
  });

  // ── Default label ───────────────────────────────────────────────────────

  testWidgets('default label is Toggle theme', (tester) async {
    await tester.pumpObers(
      OiThemeToggle(currentMode: OiThemeMode.light, onModeChange: (_) {}),
    );

    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'Toggle theme')
        .toList();
    expect(matching, isNotEmpty);
  });
}
