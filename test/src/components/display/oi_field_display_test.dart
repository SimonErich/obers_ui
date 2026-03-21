// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_field_display.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/models/oi_field_type.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copyable.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── OiTooltip composition ──────────────────────────────────────────────────

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

  // ── numberFormat support ───────────────────────────────────────────────────

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

  // ── Field type rendering ───────────────────────────────────────────────────

  group('field type rendering', () {
    testWidgets('text type renders plain text', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: 'Hello World', type: OiFieldType.text),
      );
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('number type renders formatted number', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 42,
          type: OiFieldType.number,
          decimalPlaces: 1,
        ),
      );
      expect(find.text('42.0'), findsOneWidget);
    });

    testWidgets('currency type renders with default USD', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: 99.99, type: OiFieldType.currency),
      );
      // Default: "99.99 USD"
      expect(find.text('99.99 USD'), findsOneWidget);
    });

    testWidgets('date type renders formatted date', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(value: DateTime(2024, 3, 15), type: OiFieldType.date),
      );
      expect(find.text('2024-03-15'), findsOneWidget);
    });

    testWidgets('dateTime type renders date and time', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          value: DateTime(2024, 3, 15, 14, 30),
          type: OiFieldType.dateTime,
        ),
      );
      expect(find.text('2024-03-15 14:30'), findsOneWidget);
    });

    testWidgets('boolean true renders Yes with check icon', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: true, type: OiFieldType.boolean),
      );
      expect(find.text('Yes'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('boolean false renders No', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: false, type: OiFieldType.boolean),
      );
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('email type renders with mail icon and underline', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'user@example.com',
          type: OiFieldType.email,
        ),
      );
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('url type renders with link icon', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'https://example.com',
          type: OiFieldType.url,
        ),
      );
      expect(find.text('https://example.com'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('phone type renders with phone icon', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: '+1-555-0123', type: OiFieldType.phone),
      );
      expect(find.text('+1-555-0123'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('file type extracts filename from path', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: '/path/to/document.pdf',
          type: OiFieldType.file,
        ),
      );
      expect(find.text('document.pdf'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('image type renders OiImage', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'https://example.com/img.png',
          type: OiFieldType.image,
        ),
      );
      expect(find.byType(OiImage), findsOneWidget);
    });

    testWidgets('select type renders badge when choices provided', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'active',
          type: OiFieldType.select,
          choices: {'active': 'Active', 'inactive': 'Inactive'},
        ),
      );
      expect(find.byType(OiBadge), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('tags type renders multiple badges', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: ['flutter', 'dart', 'ui'],
          type: OiFieldType.tags,
        ),
      );
      expect(find.byType(OiBadge), findsNWidgets(3));
    });

    testWidgets('color type renders swatch and hex value', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: '#3B82F6', type: OiFieldType.color),
      );
      expect(find.text('#3B82F6'), findsOneWidget);
    });

    testWidgets('json type renders with code label', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: '{"key":"value"}', type: OiFieldType.json),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('custom type falls back to text display', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: 'custom data', type: OiFieldType.custom),
      );
      expect(find.text('custom data'), findsOneWidget);
    });
  });

  // ── Empty / null value ─────────────────────────────────────────────────────

  group('empty value', () {
    testWidgets('null value shows emptyText', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: null, type: OiFieldType.text),
      );
      expect(find.text('\u2014'), findsOneWidget);
    });

    testWidgets('empty string shows emptyText', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: '',
          type: OiFieldType.text,
          emptyText: 'N/A',
        ),
      );
      expect(find.text('N/A'), findsOneWidget);
    });
  });

  // ── Interaction wrappers ───────────────────────────────────────────────────

  group('interaction wrappers', () {
    testWidgets('copyable true wraps with OiCopyable', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'Copy me',
          type: OiFieldType.text,
          copyable: true,
        ),
      );
      expect(find.byType(OiCopyable), findsOneWidget);
    });

    testWidgets('onTap wraps with OiTappable', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(value: 'Tap me', type: OiFieldType.text, onTap: () {}),
      );
      expect(find.byType(OiTappable), findsOneWidget);
    });

    testWidgets('leading widget renders before value', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'With icon',
          type: OiFieldType.text,
          leading: SizedBox(key: Key('leading_icon'), width: 16, height: 16),
        ),
      );
      expect(find.byKey(const Key('leading_icon')), findsOneWidget);
    });
  });

  // ── Pair mode ──────────────────────────────────────────────────────────────

  group('pair mode', () {
    testWidgets('horizontal mode renders label and value in Row', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay.pair(
          label: 'Name',
          value: 'Alice',
          direction: Axis.horizontal,
        ),
      );

      // Should have a Row ancestor containing both label and value
      expect(find.byType(Row), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('vertical mode renders label above value', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay.pair(
          label: 'Email',
          value: 'test@example.com',
          direction: Axis.vertical,
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('labelWidth constrains label in horizontal mode', (
      tester,
    ) async {
      await tester.pumpObers(
        const SizedBox(
          width: 400,
          child: OiFieldDisplay.pair(
            label: 'Status',
            value: 'Active',
            labelWidth: 120,
          ),
        ),
      );

      // SizedBox with width=120 should constrain the label
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final labelBox = sizedBoxes.where((sb) => sb.width == 120);
      expect(labelBox, isNotEmpty);
    });
  });

  // ── Select choices ─────────────────────────────────────────────────────────

  group('select choices', () {
    testWidgets('choices map translates select values to labels', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'pending',
          type: OiFieldType.select,
          choices: {'pending': 'Pending Review', 'done': 'Completed'},
        ),
      );
      expect(find.text('Pending Review'), findsOneWidget);
    });

    testWidgets('choiceColors renders colored badges for select', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'error',
          type: OiFieldType.select,
          choices: {'error': 'Error'},
          choiceColors: {'error': OiBadgeColor.error},
        ),
      );
      expect(find.byType(OiBadge), findsOneWidget);
    });
  });

  // ── Custom formatting ──────────────────────────────────────────────────────

  group('formatValue callback', () {
    testWidgets('overrides default formatting', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          value: 42,
          type: OiFieldType.number,
          formatValue: (v) => 'Custom: $v',
        ),
      );
      expect(find.text('Custom: 42'), findsOneWidget);
    });

    testWidgets('exception falls back gracefully', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          value: 'test',
          type: OiFieldType.text,
          formatValue: (_) => throw Exception('boom'),
        ),
      );
      // Falls back to value.toString()
      expect(find.text('test'), findsOneWidget);
    });
  });

  // ── Date formatting ────────────────────────────────────────────────────────

  group('date formatting', () {
    testWidgets('dateFormat custom pattern applies to date', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          value: DateTime(2024, 12, 25),
          type: OiFieldType.date,
          dateFormat: 'dd/MM/yyyy',
        ),
      );
      expect(find.text('25/12/2024'), findsOneWidget);
    });

    testWidgets('dateFormat custom pattern applies to dateTime', (
      tester,
    ) async {
      await tester.pumpObers(
        OiFieldDisplay(
          value: DateTime(2024, 12, 25, 10, 30),
          type: OiFieldType.dateTime,
          dateFormat: 'dd/MM/yyyy HH:mm',
        ),
      );
      expect(find.text('25/12/2024 10:30'), findsOneWidget);
    });
  });

  // ── Currency symbol / code ─────────────────────────────────────────────────

  group('currency symbol and code', () {
    testWidgets('currencySymbol takes precedence over currencyCode', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 50.0,
          type: OiFieldType.currency,
          currencySymbol: '\u20AC',
          currencyCode: 'USD',
        ),
      );
      // Symbol is shown, code is not
      expect(find.text('\u20AC50.00'), findsOneWidget);
    });

    testWidgets('decimalPlaces controls number precision', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 123.456789,
          type: OiFieldType.number,
          decimalPlaces: 3,
        ),
      );
      expect(find.text('123.457'), findsOneWidget);
    });
  });
}
