// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_storage_indicator.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // REQ-0025: color is never the sole indicator — status text accompanies
  // the color-coded bar when usage is high.

  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(
      const OiStorageIndicator(usedBytes: 5000000000, totalBytes: 10000000000),
    );
    expect(find.byType(OiStorageIndicator), findsOneWidget);
  });

  testWidgets('full layout shows "Storage" label', (tester) async {
    await tester.pumpObers(
      const OiStorageIndicator(usedBytes: 5000000000, totalBytes: 10000000000),
    );
    expect(find.text('Storage'), findsOneWidget);
  });

  testWidgets('compact layout does not show "Storage" label', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 300,
        child: OiStorageIndicator(
          usedBytes: 5000000000,
          totalBytes: 10000000000,
          compact: true,
        ),
      ),
    );
    expect(find.text('Storage'), findsNothing);
  });

  testWidgets('shows Critical label when usage > 90%', (tester) async {
    await tester.pumpObers(
      const OiStorageIndicator(usedBytes: 9500, totalBytes: 10000),
    );
    expect(find.text('Critical'), findsOneWidget);
  });

  testWidgets('shows Warning label when usage > 70%', (tester) async {
    await tester.pumpObers(
      const OiStorageIndicator(usedBytes: 7500, totalBytes: 10000),
    );
    expect(find.text('Warning'), findsOneWidget);
  });

  testWidgets('no status label when usage <= 70%', (tester) async {
    await tester.pumpObers(
      const OiStorageIndicator(usedBytes: 5000, totalBytes: 10000),
    );
    expect(find.text('Critical'), findsNothing);
    expect(find.text('Warning'), findsNothing);
  });

  testWidgets('compact mode shows Critical label when usage > 90%', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiStorageIndicator(
        usedBytes: 9500,
        totalBytes: 10000,
        compact: true,
      ),
    );
    expect(find.text('Critical'), findsOneWidget);
  });

  testWidgets('compact mode shows Warning label when usage > 70%', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiStorageIndicator(
        usedBytes: 7500,
        totalBytes: 10000,
        compact: true,
      ),
    );
    expect(find.text('Warning'), findsOneWidget);
  });

  testWidgets('compact mode no status label when usage <= 70%', (tester) async {
    await tester.pumpObers(
      const OiStorageIndicator(
        usedBytes: 5000,
        totalBytes: 10000,
        compact: true,
      ),
    );
    expect(find.text('Critical'), findsNothing);
    expect(find.text('Warning'), findsNothing);
  });

  testWidgets('renders FractionallySizedBox for progress bar', (tester) async {
    await tester.pumpObers(
      const OiStorageIndicator(usedBytes: 5000, totalBytes: 10000),
    );
    final fractionBox = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(fractionBox.widthFactor, closeTo(0.5, 0.01));
  });

  testWidgets('zero totalBytes shows 0% progress', (tester) async {
    await tester.pumpObers(
      const OiStorageIndicator(usedBytes: 0, totalBytes: 0),
    );
    final fractionBox = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(fractionBox.widthFactor, 0.0);
  });

  testWidgets('usedBytes exceeding totalBytes clamps to 100%', (tester) async {
    await tester.pumpObers(
      const OiStorageIndicator(usedBytes: 15000, totalBytes: 10000),
    );
    final fractionBox = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(fractionBox.widthFactor, 1.0);
  });

  testWidgets('custom semanticsLabel overrides default', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const OiStorageIndicator(
          usedBytes: 5000,
          totalBytes: 10000,
          semanticsLabel: 'Disk usage',
        ),
      );
      expect(find.bySemanticsLabel('Disk usage'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('segmented bar renders when breakdown is provided', (
    tester,
  ) async {
    await tester.pumpObers(
      const SizedBox(
        width: 300,
        child: OiStorageIndicator(
          usedBytes: 5000,
          totalBytes: 10000,
          breakdown: [
            OiStorageCategory(
              label: 'Documents',
              bytes: 2000,
              color: Color(0xFF2196F3),
            ),
            OiStorageCategory(
              label: 'Images',
              bytes: 3000,
              color: Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
    // Should not render FractionallySizedBox (that is for non-segmented bar)
    expect(find.byType(FractionallySizedBox), findsNothing);
    expect(find.byType(OiStorageIndicator), findsOneWidget);
  });
}
