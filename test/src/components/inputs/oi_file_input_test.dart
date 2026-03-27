// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_file_input.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiFileInput());
    expect(find.byType(OiFileInput), findsOneWidget);
  });

  testWidgets('choose file button is present', (tester) async {
    await tester.pumpObers(const OiFileInput());
    expect(find.text('Choose file…'), findsOneWidget);
  });

  testWidgets('multiple=true shows choose files button', (tester) async {
    await tester.pumpObers(const OiFileInput(multipleFiles: true));
    expect(find.text('Choose files…'), findsOneWidget);
  });

  testWidgets('selected files are shown as chips', (tester) async {
    await tester.pumpObers(
      const OiFileInput(value: ['/tmp/doc.pdf', '/tmp/img.png']),
    );
    expect(find.text('doc.pdf'), findsOneWidget);
    expect(find.text('img.png'), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(const OiFileInput(label: 'Attachments'));
    expect(find.text('Attachments'), findsOneWidget);
  });

  testWidgets('enabled=false disables the pick button', (tester) async {
    await tester.pumpObers(const OiFileInput(enabled: false));
    // The pick button is inside an OiTappable with enabled=false.
    final tappables = tester.widgetList<OiTappable>(find.byType(OiTappable));
    final allDisabled = tappables.every((t) => !t.enabled);
    expect(allDisabled, isTrue);
  });

  testWidgets('dropZone=true shows drop target', (tester) async {
    await tester.pumpObers(const OiFileInput(dropZone: true));
    expect(find.text('Drop files here'), findsOneWidget);
  });

  testWidgets('removing a file chip calls onChanged', (tester) async {
    List<String>? result;
    await tester.pumpObers(
      OiFileInput(value: const ['/tmp/a.txt'], onChanged: (v) => result = v),
    );
    await tester.tap(
      find.byIcon(
        const IconData(0xe1b2, fontFamily: 'lucide', fontPackage: 'obers_ui'),
      ),
    );
    await tester.pump();
    expect(result, isEmpty);
  });
}
