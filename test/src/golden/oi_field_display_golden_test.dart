// Golden tests have no public API.
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

// Shorthand to reduce noise when `label` is required but not under test.
const _l = 'test-label';

// 1x1 transparent PNG bytes for network image mock.
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
  // Install fake HTTP client for image type golden tests.
  late HttpOverrides? previousOverrides;

  setUp(() {
    previousOverrides = HttpOverrides.current;
    HttpOverrides.global = _FakeHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = previousOverrides;
  });

  // ── OiFieldDisplay text types — light ──────────────────────────────────────

  testGoldens('OiFieldDisplay text types — light', (tester) async {
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
    await screenMatchesGolden(tester, 'oi_field_display_text_types_light');
  });

  testGoldens('OiFieldDisplay text types — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      theme: OiThemeData.dark(),
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
    await screenMatchesGolden(tester, 'oi_field_display_text_types_dark');
  });

  // ── OiFieldDisplay interactive types — light ───────────────────────────────

  testGoldens('OiFieldDisplay interactive types — light', (tester) async {
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
      'oi_field_display_interactive_types_light',
    );
  });

  testGoldens('OiFieldDisplay interactive types — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      theme: OiThemeData.dark(),
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
      'oi_field_display_interactive_types_dark',
    );
  });

  // ── OiFieldDisplay rich types — light ──────────────────────────────────────

  testGoldens('OiFieldDisplay rich types — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      children: {
        'File (path)': const OiFieldDisplay(
          label: _l,
          value: '/path/to/document.pdf',
          type: OiFieldType.file,
        ),
        'File (map)': const OiFieldDisplay(
          label: _l,
          value: {'name': 'report.pdf', 'size': 1048576},
          type: OiFieldType.file,
        ),
        'Image': const OiFieldDisplay(
          label: _l,
          value: 'https://example.com/img.png',
          type: OiFieldType.image,
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
    await screenMatchesGolden(tester, 'oi_field_display_rich_types_light');
  });

  testGoldens('OiFieldDisplay rich types — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      theme: OiThemeData.dark(),
      children: {
        'File (path)': const OiFieldDisplay(
          label: _l,
          value: '/path/to/document.pdf',
          type: OiFieldType.file,
        ),
        'File (map)': const OiFieldDisplay(
          label: _l,
          value: {'name': 'report.pdf', 'size': 1048576},
          type: OiFieldType.file,
        ),
        'Image': const OiFieldDisplay(
          label: _l,
          value: 'https://example.com/img.png',
          type: OiFieldType.image,
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
    await screenMatchesGolden(tester, 'oi_field_display_rich_types_dark');
  });

  // ── OiFieldDisplay states — light ──────────────────────────────────────────

  testGoldens('OiFieldDisplay states — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      children: {
        'Empty (null)': const OiFieldDisplay(label: _l, value: null),
        'Custom emptyText': const OiFieldDisplay(
          label: _l,
          value: null,
          emptyText: 'N/A',
        ),
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
    await screenMatchesGolden(tester, 'oi_field_display_states_light');
  });

  testGoldens('OiFieldDisplay states — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      theme: OiThemeData.dark(),
      children: {
        'Empty (null)': const OiFieldDisplay(label: _l, value: null),
        'Custom emptyText': const OiFieldDisplay(
          label: _l,
          value: null,
          emptyText: 'N/A',
        ),
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
    await screenMatchesGolden(tester, 'oi_field_display_states_dark');
  });
}
