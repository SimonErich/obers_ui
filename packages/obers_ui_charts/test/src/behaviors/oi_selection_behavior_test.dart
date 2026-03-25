import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/behaviors/oi_selection_behavior.dart';

void main() {
  group('OiSelectionBehavior', () {
    test('single-select mode clears previous on new selection', () {
      final changes = <Set<(String, int)>>[];
      final behavior = OiSelectionBehavior(onChanged: changes.add);

      behavior.select('a', 0);
      behavior.select('a', 1);
      expect(behavior.selection, {('a', 1)});
      expect(changes.length, 2);
    });

    test('multi-select mode accumulates selections', () {
      final behavior = OiSelectionBehavior(multiSelect: true);

      behavior.select('a', 0);
      behavior.select('b', 1);
      expect(behavior.selection, {('a', 0), ('b', 1)});
    });

    test('deselect removes specific point', () {
      final behavior = OiSelectionBehavior(multiSelect: true);
      behavior.select('a', 0);
      behavior.select('a', 1);

      behavior.deselect('a', 0);
      expect(behavior.selection, {('a', 1)});
    });

    test('clearSelection removes all', () {
      final behavior = OiSelectionBehavior(multiSelect: true);
      behavior.select('a', 0);
      behavior.select('b', 1);

      behavior.clearSelection();
      expect(behavior.selection, isEmpty);
    });

    test('isSelected returns correct state', () {
      final behavior = OiSelectionBehavior();
      behavior.select('a', 0);

      expect(behavior.isSelected('a', 0), isTrue);
      expect(behavior.isSelected('a', 1), isFalse);
    });
  });
}
