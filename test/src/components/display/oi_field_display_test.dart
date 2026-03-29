// Tests do not require documentation comments.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_code_block.dart';
import 'package:obers_ui/src/components/display/oi_field_display.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/models/oi_field_type.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copyable.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/golden_helper.dart';
import '../../../helpers/pump_app.dart';

// Shorthand to reduce noise when `label` is required but not under test.
const _l = 'test-label';

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
          label: _l,
          value: 'A very long text value that should be truncated',
          maxLines: 1,
        ),
      );

      expect(find.byType(OiTooltip), findsOneWidget);
    });

    testWidgets('does not wrap when maxLines is null', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(label: _l, value: 'Short text'),
      );

      expect(find.byType(OiTooltip), findsNothing);
    });

    testWidgets('shows hex tooltip on color type', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: '#FF0000',
          type: OiFieldType.color,
        ),
      );

      expect(find.byType(OiTooltip), findsOneWidget);
    });

    testWidgets('no tooltip when value is empty', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(label: _l, value: null, type: OiFieldType.color),
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
          label: _l,
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
          label: _l,
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
          label: _l,
          value: 1234.5,
          type: OiFieldType.currency,
          numberFormat: '#,##0.00',
          currencySymbol: r'$',
        ),
      );

      expect(find.text(r'$1,234.50'), findsOneWidget);
    });

    testWidgets('invalid numberFormat falls back gracefully', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
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
        const OiFieldDisplay(label: _l, value: 'Hello World'),
      );
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('number type renders formatted number', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: 42,
          type: OiFieldType.number,
          decimalPlaces: 1,
        ),
      );
      expect(find.text('42.0'), findsOneWidget);
    });

    testWidgets('currency type renders with default USD', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: 99.99,
          type: OiFieldType.currency,
        ),
      );
      // Default: "99.99 USD"
      expect(find.text('99.99 USD'), findsOneWidget);
    });

    testWidgets('date type renders formatted date', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          label: _l,
          value: DateTime(2024, 3, 15),
          type: OiFieldType.date,
        ),
      );
      // DateFormat.yMMMd() → "Mar 15, 2024"
      expect(find.text('Mar 15, 2024'), findsOneWidget);
    });

    testWidgets('dateTime type renders date and time', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          label: _l,
          value: DateTime(2024, 3, 15, 14, 30),
          type: OiFieldType.dateTime,
        ),
      );
      // DateFormat.yMMMd().add_jm() — uses U+202F (narrow no-break space)
      // before AM/PM, so match by OiLabel content.
      expect(
        find.byWidgetPredicate(
          (w) => w is OiLabel && w.text.contains('Mar 15, 2024'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('boolean true renders Yes with check icon', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(label: _l, value: true, type: OiFieldType.boolean),
      );
      expect(find.text('Yes'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('boolean false renders No', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: false,
          type: OiFieldType.boolean,
        ),
      );
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('email type renders with mail icon and underline', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
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
          label: _l,
          value: 'https://example.com',
          type: OiFieldType.url,
        ),
      );
      expect(find.text('https://example.com'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('phone type renders with phone icon', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: '+1-555-0123',
          type: OiFieldType.phone,
        ),
      );
      expect(find.text('+1-555-0123'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('file type extracts filename from path', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
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
          label: _l,
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
          label: _l,
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
          label: _l,
          value: ['flutter', 'dart', 'ui'],
          type: OiFieldType.tags,
        ),
      );
      expect(find.byType(OiBadge), findsNWidgets(3));
    });

    testWidgets('color type renders swatch and hex value', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: '#3B82F6',
          type: OiFieldType.color,
        ),
      );
      expect(find.text('#3B82F6'), findsOneWidget);
    });

    testWidgets('json type renders with OiCodeBlock', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: '{"key":"value"}',
          type: OiFieldType.json,
        ),
      );
      expect(find.byType(OiCodeBlock), findsOneWidget);
    });

    testWidgets('custom type falls back to text display', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: 'custom data',
          type: OiFieldType.custom,
        ),
      );
      expect(find.text('custom data'), findsOneWidget);
    });
  });

  // ── Empty / null value ─────────────────────────────────────────────────────

  group('empty value', () {
    testWidgets('null value shows emptyText', (tester) async {
      await tester.pumpObers(const OiFieldDisplay(label: _l, value: null));
      expect(find.text('\u2014'), findsOneWidget);
    });

    testWidgets('empty string shows emptyText', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(label: _l, value: '', emptyText: 'N/A'),
      );
      expect(find.text('N/A'), findsOneWidget);
    });
  });

  // ── Interaction wrappers ───────────────────────────────────────────────────

  group('interaction wrappers', () {
    testWidgets('copyable true wraps with OiCopyable', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(label: _l, value: 'Copy me', copyable: true),
      );
      expect(find.byType(OiCopyable), findsOneWidget);
    });

    testWidgets('onTap wraps with OiTappable', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(label: _l, value: 'Tap me', onTap: () {}),
      );
      expect(find.byType(OiTappable), findsOneWidget);
    });

    testWidgets('leading widget renders before value', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: 'With icon',
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
        const OiFieldDisplay.pair(label: 'Name', value: 'Alice'),
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
          label: _l,
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
          label: _l,
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
          label: _l,
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
          label: _l,
          value: 'test',
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
          label: _l,
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
          label: _l,
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
          label: _l,
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
          label: _l,
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
        const OiFieldDisplay(
          label: _l,
          value: 1234567,
          type: OiFieldType.number,
        ),
      );
      expect(find.text('1,234,567'), findsOneWidget);
    });

    testWidgets('currency adds symbol with proper formatting', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: 42.5,
          type: OiFieldType.currency,
          currencySymbol: r'$',
        ),
      );
      expect(find.text(r'$42.50'), findsOneWidget);
    });

    testWidgets('large currency formats with grouping', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: 1234567.89,
          type: OiFieldType.currency,
          currencySymbol: r'$',
          decimalPlaces: 2,
        ),
      );
      expect(find.text(r'$1,234,567.89'), findsOneWidget);
    });
  });

  // ── Boolean null state ──────────────────────────────────────────────────

  group('boolean null state', () {
    testWidgets('boolean null renders Unknown with dash icon', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(label: _l, value: null, type: OiFieldType.boolean),
      );
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('boolean null does not show emptyText', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
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
          label: _l,
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
          label: _l,
          value: {'name': 'photo.jpg'},
          type: OiFieldType.file,
        ),
      );
      expect(find.text('photo.jpg'), findsOneWidget);
    });

    testWidgets('large file size formats as MB', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
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
      await tester.pumpObers(const OiFieldDisplay(label: _l, value: 'Hello'));
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('number type renders via OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(label: _l, value: 42, type: OiFieldType.number),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('empty value renders via OiLabel', (tester) async {
      await tester.pumpObers(const OiFieldDisplay(label: _l, value: null));
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('boolean renders OiLabel for text', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(label: _l, value: true, type: OiFieldType.boolean),
      );
      // OiIcon + OiLabel.body('Yes')
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('email renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: 'test@example.com',
          type: OiFieldType.email,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('url renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: 'https://example.com',
          type: OiFieldType.url,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('phone renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: '+1-555-0123',
          type: OiFieldType.phone,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('file renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: '/path/to/file.txt',
          type: OiFieldType.file,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('color renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: '#FF0000',
          type: OiFieldType.color,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('date renders OiLabel', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          label: _l,
          value: DateTime(2024),
          type: OiFieldType.date,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('currency renders OiLabel', (tester) async {
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
          value: 10.0,
          type: OiFieldType.currency,
        ),
      );
      expect(find.byType(OiLabel), findsOneWidget);
    });

    testWidgets('custom formatValue renders OiLabel', (tester) async {
      await tester.pumpObers(
        OiFieldDisplay(
          label: _l,
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
        OiFieldDisplay(value: 'Click me', label: 'Action Field', onTap: () {}),
      );

      final tappable = tester.widget<OiTappable>(find.byType(OiTappable));
      expect(tappable.semanticLabel, 'Action Field');
    });

    testWidgets('Semantics widget wraps output with correct label', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiFieldDisplay(label: _l, value: 'test value'),
      );

      // Find the Semantics widget whose label matches the provided label.
      final semanticsFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == _l,
      );
      expect(semanticsFinder, findsOneWidget);
    });
  });

  // ── Theme change ────────────────────────────────────────────────────────

  group('theme change', () {
    testWidgets('updates formatting when theme changes', (tester) async {
      // Pump with light theme.
      await tester.pumpObers(
        const OiFieldDisplay(
          label: _l,
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
          label: _l,
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
          label: _l,
          value: 'Line 1\nLine 2\nLine 3\nLine 4',
          maxLines: 2,
        ),
      );

      final label = tester.widget<OiLabel>(find.byType(OiLabel));
      expect(label.maxLines, 2);
      expect(label.overflow, TextOverflow.ellipsis);
    });
  });

  // ── Golden tests ───────────────────────────────────────────────────────────

  group('golden tests', () {
    // Install fake HTTP client for image type golden tests.
    late HttpOverrides? previousOverrides;

    setUp(() {
      previousOverrides = HttpOverrides.current;
      HttpOverrides.global = _FakeHttpOverrides();
    });

    tearDown(() {
      HttpOverrides.global = previousOverrides;
    });

    testGoldens('OiFieldDisplay golden — text types', (tester) async {
      final builder = obersGoldenBuilder(
        columns: 3,
        children: {
          'Text': const OiFieldDisplay(label: _l, value: 'Hello World'),
          'Number': const OiFieldDisplay(
            label: _l,
            value: 1234567,
            type: OiFieldType.number,
          ),
          'Currency': const OiFieldDisplay(
            label: _l,
            value: 99.99,
            type: OiFieldType.currency,
            currencySymbol: r'$',
          ),
          'Date': OiFieldDisplay(
            label: _l,
            value: DateTime(2024, 3, 15),
            type: OiFieldType.date,
          ),
          'DateTime': OiFieldDisplay(
            label: _l,
            value: DateTime(2024, 3, 15, 14, 30),
            type: OiFieldType.dateTime,
          ),
          'JSON': const OiFieldDisplay(
            label: _l,
            value: '{"key":"value"}',
            type: OiFieldType.json,
          ),
        },
      );
      await tester.pumpWidgetBuilder(builder);
      await screenMatchesGolden(tester, 'oi_field_display_unit_text_types');
    });

    testGoldens('OiFieldDisplay golden — interactive types', (tester) async {
      final builder = obersGoldenBuilder(
        columns: 3,
        children: {
          'Boolean true': const OiFieldDisplay(
            label: _l,
            value: true,
            type: OiFieldType.boolean,
          ),
          'Boolean false': const OiFieldDisplay(
            label: _l,
            value: false,
            type: OiFieldType.boolean,
          ),
          'Boolean null': const OiFieldDisplay(
            label: _l,
            value: null,
            type: OiFieldType.boolean,
          ),
          'Email': const OiFieldDisplay(
            label: _l,
            value: 'user@example.com',
            type: OiFieldType.email,
          ),
          'URL': const OiFieldDisplay(
            label: _l,
            value: 'https://example.com',
            type: OiFieldType.url,
          ),
          'Phone': const OiFieldDisplay(
            label: _l,
            value: '+1-555-0123',
            type: OiFieldType.phone,
          ),
        },
      );
      await tester.pumpWidgetBuilder(builder);
      await screenMatchesGolden(
        tester,
        'oi_field_display_unit_interactive_types',
      );
    });

    testGoldens('OiFieldDisplay golden — rich types', (tester) async {
      final builder = obersGoldenBuilder(
        columns: 3,
        children: {
          'File': const OiFieldDisplay(
            label: _l,
            value: '/path/to/document.pdf',
            type: OiFieldType.file,
          ),
          'File (map)': const OiFieldDisplay(
            label: _l,
            value: {'name': 'report.pdf', 'size': 1048576},
            type: OiFieldType.file,
          ),
          'Select': const OiFieldDisplay(
            label: _l,
            value: 'active',
            type: OiFieldType.select,
            choices: {'active': 'Active'},
            choiceColors: {'active': OiBadgeColor.success},
          ),
          'Tags': const OiFieldDisplay(
            label: _l,
            value: ['flutter', 'dart', 'ui'],
            type: OiFieldType.tags,
          ),
          'Color': const OiFieldDisplay(
            label: _l,
            value: '#3B82F6',
            type: OiFieldType.color,
          ),
        },
      );
      await tester.pumpWidgetBuilder(builder);
      await screenMatchesGolden(tester, 'oi_field_display_unit_rich_types');
    });

    testGoldens('OiFieldDisplay golden — states and pair', (tester) async {
      final builder = obersGoldenBuilder(
        columns: 3,
        children: {
          'Empty (null)': const OiFieldDisplay(label: _l, value: null),
          'Custom format': OiFieldDisplay(
            label: _l,
            value: 42,
            type: OiFieldType.number,
            formatValue: (v) => 'Custom: $v',
          ),
          'Pair horizontal': const OiFieldDisplay.pair(
            label: 'Name',
            value: 'Alice',
          ),
          'Pair vertical': const OiFieldDisplay.pair(
            label: 'Email',
            value: 'alice@example.com',
            direction: Axis.vertical,
          ),
          'Custom type': const OiFieldDisplay(
            label: _l,
            value: 'custom data',
            type: OiFieldType.custom,
          ),
        },
      );
      await tester.pumpWidgetBuilder(builder);
      await screenMatchesGolden(tester, 'oi_field_display_unit_states_pair');
    });
  });
}
