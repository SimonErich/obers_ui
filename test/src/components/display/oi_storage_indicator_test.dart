// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_storage_indicator.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // REQ-0025: color is never the sole indicator — status text accompanies
  // the color-coded bar when usage is high.

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

  testWidgets('compact mode no status label when usage <= 70%', (
    tester,
  ) async {
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
}
