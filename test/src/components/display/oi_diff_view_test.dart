// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_diff_view.dart';

import '../../../helpers/pump_app.dart';

const _lines = [
  OiDiffLine(content: 'unchanged', unchanged: true, lineNumber: 1),
  OiDiffLine(content: 'removed line', removed: true, lineNumber: 2),
  OiDiffLine(content: 'added line', added: true, lineNumber: 3),
];

void main() {
  testWidgets('unified mode renders all lines', (tester) async {
    await tester.pumpObers(const OiDiffView(lines: _lines));
    expect(find.textContaining('unchanged'), findsOneWidget);
    expect(find.textContaining('removed line'), findsOneWidget);
    expect(find.textContaining('added line'), findsOneWidget);
  });

  testWidgets('added lines get plus prefix in unified mode', (tester) async {
    await tester.pumpObers(const OiDiffView(lines: _lines));
    expect(find.textContaining('+ added line'), findsOneWidget);
  });

  testWidgets('removed lines get minus prefix in unified mode', (tester) async {
    await tester.pumpObers(const OiDiffView(lines: _lines));
    expect(find.textContaining('- removed line'), findsOneWidget);
  });

  testWidgets('side-by-side mode renders', (tester) async {
    await tester.pumpObers(
      const OiDiffView(lines: _lines, mode: OiDiffMode.sideBySide),
    );
    expect(find.textContaining('removed line'), findsOneWidget);
    expect(find.textContaining('added line'), findsOneWidget);
  });

  // REQ-0025: color is never the sole indicator — side-by-side also uses
  // +/- text prefixes.
  testWidgets('side-by-side added lines get plus prefix', (tester) async {
    await tester.pumpObers(
      const OiDiffView(lines: _lines, mode: OiDiffMode.sideBySide),
    );
    expect(find.textContaining('+ added line'), findsOneWidget);
  });

  testWidgets('side-by-side removed lines get minus prefix', (tester) async {
    await tester.pumpObers(
      const OiDiffView(lines: _lines, mode: OiDiffMode.sideBySide),
    );
    expect(find.textContaining('- removed line'), findsOneWidget);
  });

  testWidgets('line numbers shown when enabled', (tester) async {
    await tester.pumpObers(const OiDiffView(lines: _lines));
    expect(find.textContaining('1'), findsAtLeastNWidgets(1));
  });

  testWidgets('added lines use ColoredBox background', (tester) async {
    await tester.pumpObers(const OiDiffView(lines: _lines));
    // Both added and removed lines wrap with ColoredBox.
    expect(find.byType(ColoredBox), findsAtLeastNWidgets(2));
  });
}
