// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/data/oi_property_grid.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiPropertyGrid', () {
    testWidgets('renders property labels', (tester) async {
      await tester.pumpObers(
        const OiPropertyGrid(
          properties: [
            OiPropertyRow(
              label: 'Name',
              editor: SizedBox(height: 32),
            ),
            OiPropertyRow(
              label: 'Enabled',
              editor: SizedBox(height: 32),
            ),
          ],
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Enabled'), findsOneWidget);
    });

    testWidgets('renders editor widgets', (tester) async {
      await tester.pumpObers(
        OiPropertyGrid(
          properties: [
            OiPropertyRow(
              label: 'Color',
              editor: Container(key: const ValueKey('editor'), height: 32),
            ),
          ],
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byKey(const ValueKey('editor')), findsOneWidget);
    });

    testWidgets('accepts dividerPosition', (tester) async {
      await tester.pumpObers(
        const OiPropertyGrid(
          properties: [
            OiPropertyRow(label: 'Test', editor: SizedBox(height: 32)),
          ],
          dividerPosition: 0.6,
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiPropertyGrid), findsOneWidget);
    });
  });
}
