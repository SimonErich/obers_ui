// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_code_block.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copy_button.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders code text', (tester) async {
    await tester.pumpObers(const OiCodeBlock(code: 'void main() {}'));
    expect(find.textContaining('main'), findsOneWidget);
  });

  testWidgets('copy button present by default', (tester) async {
    await tester.pumpObers(const OiCodeBlock(code: 'hello'));
    expect(find.byType(OiCopyButton), findsOneWidget);
  });

  testWidgets('copy button hidden when showCopyButton=false', (tester) async {
    await tester.pumpObers(
      const OiCodeBlock(code: 'hello', showCopyButton: false),
    );
    expect(find.byType(OiCopyButton), findsNothing);
  });

  testWidgets('line numbers shown when enabled', (tester) async {
    await tester.pumpObers(
      const OiCodeBlock(
        code: 'line one\nline two\nline three',
        lineNumbers: true,
        showCopyButton: false,
      ),
    );
    expect(find.textContaining('1'), findsAtLeastNWidgets(1));
    expect(find.textContaining('3'), findsAtLeastNWidgets(1));
  });

  testWidgets('line numbers not shown by default', (tester) async {
    await tester.pumpObers(
      const OiCodeBlock(code: 'void foo() {}', showCopyButton: false),
    );
    // Line number "1" should not appear as a standalone label.
    expect(find.text('1  '), findsNothing);
  });

  testWidgets('multi-line code renders all lines', (tester) async {
    await tester.pumpObers(
      const OiCodeBlock(code: 'alpha\nbeta\ngamma', showCopyButton: false),
    );
    expect(find.textContaining('alpha'), findsOneWidget);
    expect(find.textContaining('gamma'), findsOneWidget);
  });
}
