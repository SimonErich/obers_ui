// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

enum _F { fruit }

class _Ctrl extends OiAfController<_F, Map<String, dynamic>> {
  @override
  void defineFields() {
    addComboBoxField<String>(_F.fruit);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

void main() {
  group('OiAfComboBox', () {
    late _Ctrl ctrl;

    setUp(() => ctrl = _Ctrl());
    tearDown(() => ctrl.dispose());

    Widget wrap(Widget child) => OiApp(
      home: OiAfForm<_F, Map<String, dynamic>>(controller: ctrl, child: child),
    );

    testWidgets('uses the English dropdown texts by default', (tester) async {
      await tester.pumpWidget(
        wrap(
          OiAfComboBox<_F, String>(
            field: _F.fruit,
            label: 'Fruit',
            labelOf: (item) => item,
            items: const ['Apple'],
          ),
        ),
      );

      final comboBox = tester.widget<OiComboBox<String>>(
        find.byType(OiComboBox<String>),
      );
      expect(comboBox.labels.searchPlaceholder, 'Search…');
    });

    testWidgets('forwards labels to the combo box', (tester) async {
      const labels = OiComboBoxLabels(
        searchPlaceholder: 'Suchen',
        loading: 'Wird geladen',
        loadMore: 'Mehr laden',
      );
      await tester.pumpWidget(
        wrap(
          OiAfComboBox<_F, String>(
            field: _F.fruit,
            label: 'Obst',
            labelOf: (item) => item,
            items: const ['Apfel'],
            labels: labels,
          ),
        ),
      );

      final comboBox = tester.widget<OiComboBox<String>>(
        find.byType(OiComboBox<String>),
      );
      expect(comboBox.labels, same(labels));

      // And the dropdown shows them.
      await tester.tap(find.byType(OiComboBox<String>));
      await tester.pumpAndSettle();
      expect(find.text('Suchen'), findsOneWidget);
    });
  });
}
