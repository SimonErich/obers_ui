// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_field_display.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/models/oi_field_type.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copyable.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

// 1×1 transparent PNG bytes.
final _kTransparentPng = <int>[
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, //
  0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4,
  0x89, 0x00, 0x00, 0x00, 0x0a, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9c, 0x62, 0x00, 0x00, 0x00, 0x02,
  0x00, 0x01, 0xe2, 0x21, 0xbc, 0x33, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42,
  0x60, 0x82,
];

class _FakeHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Return a Future-based stub for openUrl / getUrl.
    final memberName = invocation.memberName.toString();
    if (memberName.contains('getUrl') || memberName.contains('openUrl')) {
      return Future<HttpClientRequest>.value(_FakeHttpClientRequest());
    }
    return super.noSuchMethod(invocation);
  }

  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString();
    if (memberName.contains('close')) {
      return Future<HttpClientResponse>.value(_FakeHttpClientResponse());
    }
    return super.noSuchMethod(invocation);
  }

  @override
  Encoding encoding = utf8;

  @override
  Uri get uri => Uri.parse('https://example.com/img.png');
}

class _FakeHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentPng.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_kTransparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

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

      expect(find.text('1,234.50'), findsOneWidget);
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

      // Should not crash — renders some text via OiLabel (pattern may
      // produce unexpected output but the widget must not error).
      expect(find.byType(OiLabel), findsOneWidget);
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
      final previous = HttpOverrides.current;
      HttpOverrides.global = _FakeHttpOverrides();
      addTearDown(() => HttpOverrides.global = previous);

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

  // ── Number grouping ─────────────────────────────────────────────────────

  group('number grouping', () {
    testWidgets('number formats with grouping separators', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: 1234567, type: OiFieldType.number),
      );
      expect(find.text('1,234,567'), findsOneWidget);
    });

    testWidgets('currency adds symbol with proper formatting', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 42.5,
          type: OiFieldType.currency,
          currencySymbol: '\$',
        ),
      );
      expect(find.text('\$42.50'), findsOneWidget);
    });

    testWidgets('large currency formats with grouping', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 1234567.89,
          type: OiFieldType.currency,
          currencySymbol: '\$',
          decimalPlaces: 2,
        ),
      );
      expect(find.text('\$1,234,567.89'), findsOneWidget);
    });
  });

  // ── Boolean null state ──────────────────────────────────────────────────

  group('boolean null state', () {
    testWidgets('boolean null renders Unknown with dash icon', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: null, type: OiFieldType.boolean),
      );
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('boolean null does not show emptyText', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: null,
          type: OiFieldType.boolean,
          emptyText: 'N/A',
        ),
      );
      // Should show "Unknown", not "N/A".
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.text('N/A'), findsNothing);
    });
  });

  // ── File with Map value ─────────────────────────────────────────────────

  group('file with Map value', () {
    testWidgets('renders filename and size from Map', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: {'name': 'doc.pdf', 'size': 1024},
          type: OiFieldType.file,
        ),
      );
      expect(find.text('doc.pdf'), findsOneWidget);
      expect(find.text('1 KB'), findsOneWidget);
    });

    testWidgets('renders filename from Map without size', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: {'name': 'photo.jpg'},
          type: OiFieldType.file,
        ),
      );
      expect(find.text('photo.jpg'), findsOneWidget);
    });

    testWidgets('large file size formats as MB', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: {'name': 'video.mp4', 'size': 5242880},
          type: OiFieldType.file,
        ),
      );
      expect(find.text('video.mp4'), findsOneWidget);
      expect(find.text('5.0 MB'), findsOneWidget);
    });
  });

  // ── OiLabel usage (convention) ──────────────────────────────────────────

  group('OiLabel convention', () {
    testWidgets('text type renders via OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: 'Hello', type: OiFieldType.text),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('number type renders via OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: 42, type: OiFieldType.number),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('empty value renders via OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: null, type: OiFieldType.text),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('boolean renders OiLabel for text', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: true, type: OiFieldType.boolean),
      );
      // OiIcon + OiLabel.body('Yes')
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('email renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'test@example.com',
          type: OiFieldType.email,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('url renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'https://example.com',
          type: OiFieldType.url,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('phone renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: '+1-555-0123', type: OiFieldType.phone),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('file renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: '/path/to/file.txt',
          type: OiFieldType.file,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('color renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: '#FF0000', type: OiFieldType.color),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('date renders OiLabel', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(value: DateTime(2024), type: OiFieldType.date),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('currency renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(value: 10.0, type: OiFieldType.currency),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('custom formatValue renders OiLabel', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          value: 42,
          type: OiFieldType.number,
          formatValue: (v) => 'Custom: $v',
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });
  });

  // ── Accessibility ───────────────────────────────────────────────────────

  group('accessibility', () {
    testWidgets('pair label is announced for semantics', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay.pair(label: 'Full Name', value: 'Alice Smith'),
      );

      // The label text is present in the widget tree.
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Alice Smith'), findsOneWidget);
    });

    testWidgets('onTap provides semantic label', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          value: 'Click me',
          type: OiFieldType.text,
          label: 'Action Field',
          onTap: () {},
        ),
      );

      final tappable = tester.widget<OiTappable>(find.byType(OiTappable));
      expect(tappable.semanticLabel, 'Action Field');
    });
  });

  // ── Theme change ────────────────────────────────────────────────────────

  group('theme change', () {
    testWidgets('updates formatting when theme changes', (tester) async {
      // Pump with light theme.
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'test@example.com',
          type: OiFieldType.email,
        ),
      );

      // Verify renders correctly.
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(OiLabel), findsOneWidget);

      // Re-pump with dark theme.
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'test@example.com',
          type: OiFieldType.email,
        ),
        theme: OiThemeData.dark(),
      );

      // Still renders correctly with dark theme.
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(OiLabel), findsOneWidget);
    });
  });

  // ── maxLines truncation ─────────────────────────────────────────────────

  group('maxLines truncation', () {
    testWidgets('maxLines constrains text display', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          value: 'Line 1\nLine 2\nLine 3\nLine 4',
          type: OiFieldType.text,
          maxLines: 2,
        ),
      );

      final label = tester.widget<OiLabel>(find.byType(OiLabel));
      expect(label.maxLines, 2);
      expect(label.overflow, TextOverflow.ellipsis);
    });
  });
}
