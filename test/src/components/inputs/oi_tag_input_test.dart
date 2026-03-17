// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_tag_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(
      const OiTagInput(tags: []),
    );
    expect(find.byType(OiTagInput), findsOneWidget);
  });

  testWidgets('existing tags are shown as chips', (tester) async {
    await tester.pumpObers(
      const OiTagInput(tags: ['dart', 'flutter']),
    );
    expect(find.text('dart'), findsOneWidget);
    expect(find.text('flutter'), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(
      const OiTagInput(tags: [], label: 'Skills'),
    );
    expect(find.text('Skills'), findsOneWidget);
  });

  testWidgets('removing a tag calls onChanged', (tester) async {
    List<String>? result;
    await tester.pumpObers(
      OiTagInput(
        tags: const ['dart', 'flutter'],
        onChanged: (v) => result = v,
      ),
    );
    // Tap the first '×' remove icon.
    await tester.tap(find.byIcon(
      const IconData(0xe5cd, fontFamily: 'MaterialIcons'),
    ).first);
    await tester.pump();
    expect(result, isNotNull);
    expect(result!.length, 1);
  });

  testWidgets('adding a tag via Enter calls onChanged', (tester) async {
    List<String>? result;
    await tester.pumpObers(
      OiTagInput(
        tags: const [],
        onChanged: (v) => result = v,
      ),
    );
    await tester.enterText(find.byType(EditableText), 'newtag');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(result, contains('newtag'));
  });

  testWidgets('maxTags enforces limit', (tester) async {
    List<String>? result;
    await tester.pumpObers(
      OiTagInput(
        tags: const ['a', 'b'],
        maxTags: 2,
        onChanged: (v) => result = v,
      ),
    );
    // Should not accept more tags when at limit.
    await tester.enterText(find.byType(EditableText), 'c');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    // result stays null (no change fired) because maxTags reached.
    expect(result, isNull);
  });
}
