// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_field_display.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/models/oi_field_type.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiTooltip composition', () {
    testWidgets('wraps content when maxLines is set', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'A very long text value that should be truncated',
          type: OiFieldType.text,
          maxLines: 1,
        ),
      );

      expect(find.byType(OiTooltip), findsOneWidget);
    });

    testWidgets('does not wrap when maxLines is null', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: 'Short text', type: OiFieldType.text),
      );

      expect(find.byType(OiTooltip), findsNothing);
    });

    testWidgets('shows hex tooltip on color type', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: '#FF0000', type: OiFieldType.color),
      );

      expect(find.byType(OiTooltip), findsOneWidget);
    });

    testWidgets('no tooltip when value is empty', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: null, type: OiFieldType.color),
      );

      expect(find.byType(OiTooltip), findsNothing);
    });
  });

  group('numberFormat support', () {
    testWidgets('formats number display with numberFormat pattern', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 1234567.89,
          type: OiFieldType.number,
          numberFormat: '#,##0.00',
        ),
      );

      expect(find.text('1,234,567.89'), findsOneWidget);
    });

    testWidgets('falls back to decimalPlaces when numberFormat is null', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 1234.5,
          type: OiFieldType.number,
          decimalPlaces: 2,
        ),
      );

      expect(find.text('1234.50'), findsOneWidget);
    });

    testWidgets('formats currency display with numberFormat pattern', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 1234.5,
          type: OiFieldType.currency,
          numberFormat: '#,##0.00',
          currencySymbol: '\$',
        ),
      );

      expect(find.text('\$1,234.50'), findsOneWidget);
    });

    testWidgets('invalid numberFormat falls back gracefully', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 42,
          type: OiFieldType.number,
          numberFormat: '%%%invalid%%%',
        ),
      );

      // Should not crash — falls back to toStringAsFixed.
      expect(find.text('42'), findsOneWidget);
    });
  });
}
