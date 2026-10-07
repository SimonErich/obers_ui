import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Widget searchField({
    required Future<List<String>> Function(String) search,
    ValueChanged<String>? onSelect,
  }) => Center(
    child: SizedBox(
      width: 300,
      child: OiAutocomplete<String>(
        label: 'Product search',
        placeholder: 'Find a product',
        emptyLabel: 'Nothing found',
        search: search,
        labelOf: (item) => item,
        onSelect: onSelect ?? (_) {},
      ),
    ),
  );

  testWidgets('ignores a stale search result after a newer query', (
    tester,
  ) async {
    final first = Completer<List<String>>();
    final second = Completer<List<String>>();
    await tester.pumpObers(
      searchField(
        search: (query) => query == 'a' ? first.future : second.future,
      ),
    );
    await tester.enterText(find.byType(EditableText), 'a');
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'ab');
    second.complete(['Current result']);
    await tester.pumpAndSettle();
    first.complete(['Stale result']);
    await tester.pumpAndSettle();
    expect(find.text('Current result'), findsOneWidget);
    expect(find.text('Stale result'), findsNothing);
  });

  testWidgets('keyboard selection reports the item and resets the query', (
    tester,
  ) async {
    String? selected;
    await tester.pumpObers(
      searchField(
        search: (_) async => ['First item', 'Second item'],
        onSelect: (item) => selected = item,
      ),
    );
    await tester.enterText(find.byType(EditableText), 'item');
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(selected, 'Second item');
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '',
    );
    expect(find.text('Second item'), findsNothing);
  });

  testWidgets('empty results are announced without selecting a fake item', (
    tester,
  ) async {
    var selected = false;
    var searches = 0;
    await tester.pumpObers(
      searchField(
        search: (_) async {
          searches++;
          return [];
        },
        onSelect: (_) => selected = true,
      ),
    );
    await tester.enterText(find.byType(EditableText), '   ');
    await tester.pumpAndSettle();
    expect(searches, 0);
    await tester.enterText(find.byType(EditableText), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('Nothing found'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(selected, isFalse);
  });
}
