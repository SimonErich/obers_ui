// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_array_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Widget buildArrayInput({
    List<String> items = const [],
    ValueChanged<List<String>>? onChanged,
    bool reorderable = false,
    bool addable = true,
    bool removable = true,
    int? minItems,
    int? maxItems,
    String? label,
    String? error,
    String addLabel = 'Add',
  }) {
    return OiArrayInput<String>(
      items: items,
      itemBuilder: (context, index, item, onItemChanged) {
        return GestureDetector(
          key: ValueKey('item-$index'),
          onTap: () => onItemChanged('edited-$item'),
          child: Text('Item: $item'),
        );
      },
      createEmpty: () => 'new',
      onChanged: onChanged,
      reorderable: reorderable,
      addable: addable,
      removable: removable,
      minItems: minItems,
      maxItems: maxItems,
      label: label,
      error: error,
      addLabel: addLabel,
    );
  }

  testWidgets('renders without error with empty list', (tester) async {
    await tester.pumpObers(buildArrayInput());
    expect(find.byType(OiArrayInput<String>), findsOneWidget);
  });

  testWidgets('renders correct number of items', (tester) async {
    await tester.pumpObers(buildArrayInput(items: ['a', 'b', 'c']));
    expect(find.text('Item: a'), findsOneWidget);
    expect(find.text('Item: b'), findsOneWidget);
    expect(find.text('Item: c'), findsOneWidget);
  });

  testWidgets('add button calls createEmpty and fires onChanged', (
    tester,
  ) async {
    List<String>? result;
    await tester.pumpObers(
      buildArrayInput(items: ['a'], onChanged: (v) => result = v),
    );

    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result, ['a', 'new']);
  });

  testWidgets('remove button fires onChanged with item removed', (
    tester,
  ) async {
    List<String>? result;
    await tester.pumpObers(
      buildArrayInput(items: ['a', 'b'], onChanged: (v) => result = v),
    );

    // Tap the first Remove button
    await tester.tap(find.text('Remove').first);
    await tester.pump();

    expect(result, isNotNull);
    expect(result, ['b']);
  });

  testWidgets('add button hidden when addable=false', (tester) async {
    await tester.pumpObers(
      buildArrayInput(items: ['a'], addable: false, onChanged: (_) {}),
    );

    expect(find.text('Add'), findsNothing);
  });

  testWidgets('remove buttons hidden when removable=false', (tester) async {
    await tester.pumpObers(
      buildArrayInput(items: ['a', 'b'], removable: false, onChanged: (_) {}),
    );

    expect(find.text('Remove'), findsNothing);
  });

  testWidgets('add button not shown when items.length >= maxItems', (
    tester,
  ) async {
    await tester.pumpObers(
      buildArrayInput(items: ['a', 'b'], maxItems: 2, onChanged: (_) {}),
    );

    expect(find.text('Add'), findsNothing);
  });

  testWidgets('remove buttons not active when items.length <= minItems', (
    tester,
  ) async {
    List<String>? result;
    await tester.pumpObers(
      buildArrayInput(items: ['a'], minItems: 1, onChanged: (v) => result = v),
    );

    // Try to tap Remove — should not fire since canRemove is false
    final removeFinder = find.text('Remove');
    if (removeFinder.evaluate().isNotEmpty) {
      await tester.tap(removeFinder.first);
      await tester.pump();
    }

    expect(result, isNull);
  });

  testWidgets('displays label and error when provided', (tester) async {
    await tester.pumpObers(
      buildArrayInput(
        items: ['a'],
        label: 'Tags',
        error: 'At least one tag required',
        onChanged: (_) {},
      ),
    );

    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('At least one tag required'), findsOneWidget);
  });

  testWidgets('custom addLabel is displayed', (tester) async {
    await tester.pumpObers(
      buildArrayInput(addLabel: 'Add Row', onChanged: (_) {}),
    );

    expect(find.text('Add Row'), findsOneWidget);
  });

  testWidgets('itemBuilder receives correct index and item', (tester) async {
    await tester.pumpObers(buildArrayInput(items: ['first', 'second']));

    expect(find.text('Item: first'), findsOneWidget);
    expect(find.text('Item: second'), findsOneWidget);
  });

  testWidgets('onItemChanged updates specific item in list', (tester) async {
    List<String>? result;
    await tester.pumpObers(
      buildArrayInput(items: ['a', 'b', 'c'], onChanged: (v) => result = v),
    );

    // Tap item 'b' which triggers onItemChanged('edited-b')
    await tester.tap(find.text('Item: b'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result, ['a', 'edited-b', 'c']);
  });

  testWidgets('no controls shown when onChanged is null', (tester) async {
    await tester.pumpObers(buildArrayInput(items: ['a'], onChanged: null));

    expect(find.text('Add'), findsNothing);
    expect(find.text('Remove'), findsNothing);
  });

  testWidgets('reorderable=true renders with OiReorderable', (tester) async {
    await tester.pumpObers(
      buildArrayInput(items: ['a', 'b'], reorderable: true, onChanged: (_) {}),
      surfaceSize: const Size(400, 600),
    );

    expect(find.text('Item: a'), findsOneWidget);
    expect(find.text('Item: b'), findsOneWidget);
    // Drag handle icons should be present
    expect(find.text('Drag to reorder'), findsNWidgets(2));
  });

  testWidgets('drag handles not shown when reorderable=false', (tester) async {
    await tester.pumpObers(
      buildArrayInput(items: ['a', 'b'], reorderable: false, onChanged: (_) {}),
    );

    expect(find.text('Drag to reorder'), findsNothing);
  });
}
