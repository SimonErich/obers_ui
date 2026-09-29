// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

const _fruits = ['Apple', 'Apricot', 'Avocado', 'Banana'];

Widget _autocomplete() => OiAutocomplete<String>(
  label: 'Fruit',
  placeholder: 'Search fruit',
  emptyLabel: 'Nothing found',
  search: (query) async => [
    for (final fruit in _fruits)
      if (fruit.toLowerCase().contains(query.toLowerCase())) fruit,
  ],
  labelOf: (fruit) => fruit,
  onSelect: (_) {},
);

Future<void> main() async {
  await goldenTest(
    'OiAutocomplete idle — light',
    fileName: 'oi_autocomplete_idle_light',
    builder: () => obersGoldenGroup(children: {'Idle': _autocomplete()}),
  );

  await goldenTest(
    'OiAutocomplete idle — dark',
    fileName: 'oi_autocomplete_idle_dark',
    builder: () => obersGoldenGroup(
      theme: OiThemeData.dark(),
      children: {'Idle': _autocomplete()},
    ),
  );

  await goldenTest(
    'OiAutocomplete open with highlight — light',
    fileName: 'oi_autocomplete_open_light',
    pumpBeforeTest: (tester) async {
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    },
    builder: () => obersGoldenGroup(
      cellSize: const Size(300, 260),
      children: {
        'Open': Align(alignment: Alignment.topCenter, child: _autocomplete()),
      },
    ),
  );
}
