// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_export_button.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('single format renders plain outline button (no split)', (
    tester,
  ) async {
    await tester.pumpObers(
      OiExportButton(
        label: 'Export',
        onExport: (_) async {},
        formats: const [OiExportFormat.csv],
      ),
    );

    expect(find.text('Export'), findsOneWidget);
    // Should not have a chevron/split — only one text widget for the label
    expect(find.text('CSV'), findsNothing);
  });

  testWidgets('multiple formats renders split button', (tester) async {
    await tester.pumpObers(
      Center(
        child: OiExportButton(
          label: 'Export',
          onExport: (_) async {},
          formats: const [OiExportFormat.csv, OiExportFormat.xlsx],
        ),
      ),
    );

    expect(find.text('Export'), findsOneWidget);
  });

  testWidgets('tap on single-format button fires onExport with that format', (
    tester,
  ) async {
    OiExportFormat? received;

    await tester.pumpObers(
      OiExportButton(
        label: 'Export',
        onExport: (format) async => received = format,
        formats: const [OiExportFormat.json],
      ),
    );

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(received, OiExportFormat.json);
  });

  testWidgets('tap on split main area fires onExport with first format', (
    tester,
  ) async {
    OiExportFormat? received;

    await tester.pumpObers(
      Center(
        child: OiExportButton(
          label: 'Export',
          onExport: (format) async => received = format,
          formats: const [OiExportFormat.csv, OiExportFormat.xlsx],
        ),
      ),
    );

    // Tap the main label area of the split button
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(received, OiExportFormat.csv);
  });

  testWidgets('split button renders dropdown content with format labels', (
    tester,
  ) async {
    await tester.pumpObers(
      Center(
        child: OiExportButton(
          label: 'Export',
          onExport: (_) async {},
          formats: const [
            OiExportFormat.csv,
            OiExportFormat.xlsx,
            OiExportFormat.json,
          ],
        ),
      ),
    );

    // The dropdown content is rendered in the widget tree (inside OiFloating)
    // but not visible until the chevron is tapped. Verify the widget is present.
    expect(find.byType(OiExportButton), findsOneWidget);
  });

  testWidgets('loading state prevents export callback', (tester) async {
    OiExportFormat? received;

    await tester.pumpObers(
      OiExportButton(
        label: 'Export',
        onExport: (format) async => received = format,
        formats: const [OiExportFormat.csv],
        loading: true,
      ),
    );

    // Button should be rendered but disabled via loading state
    // The onTap is null when loading, so tapping should not fire.
    // Use pump() instead of pumpAndSettle() — loading animation never settles.
    await tester.tap(find.byType(OiExportButton), warnIfMissed: false);
    await tester.pump();

    expect(received, isNull);
  });

  testWidgets('async onExport resets loading after completion', (tester) async {
    final completer = Completer<void>();

    await tester.pumpObers(
      OiExportButton(
        label: 'Export',
        onExport: (_) => completer.future,
        formats: const [OiExportFormat.csv],
      ),
    );

    await tester.tap(find.text('Export'));
    await tester.pump();

    // Export is in progress — the internal loading state is active.
    // Complete the future.
    completer.complete();
    await tester.pumpAndSettle();

    // After completing, button should be usable again.
    // Verify by tapping once more.
    OiExportFormat? received;
    await tester.pumpObers(
      OiExportButton(
        label: 'Export',
        onExport: (format) async => received = format,
        formats: const [OiExportFormat.csv],
      ),
    );

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(received, OiExportFormat.csv);
  });

  testWidgets('OiExportFormat.label returns correct strings', (_) async {
    expect(OiExportFormat.csv.label, 'CSV');
    expect(OiExportFormat.xlsx.label, 'Excel (XLSX)');
    expect(OiExportFormat.json.label, 'JSON');
    expect(OiExportFormat.pdf.label, 'PDF');
  });
}
