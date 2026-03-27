import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/behaviors/oi_series_toggle_behavior.dart';

void main() {
  group('OiSeriesToggleBehavior', () {
    test('defaults to visible for unknown series', () {
      final behavior = OiSeriesToggleBehavior();
      expect(behavior.isVisible('any'), isTrue);
    });

    test('toggle flips visibility', () {
      final changes = <Map<String, bool>>[];
      final behavior = OiSeriesToggleBehavior(onVisibilityChanged: changes.add)
        ..toggle('a');
      expect(behavior.isVisible('a'), isFalse);
      expect(changes.length, 1);

      behavior.toggle('a');
      expect(behavior.isVisible('a'), isTrue);
    });

    test('setVisible explicitly sets state', () {
      final behavior = OiSeriesToggleBehavior()
        ..setVisible('a', visible: false);
      expect(behavior.isVisible('a'), isFalse);

      behavior.setVisible('a', visible: true);
      expect(behavior.isVisible('a'), isTrue);
    });

    test('showAll makes all series visible', () {
      final behavior = OiSeriesToggleBehavior()
        ..toggle('a')
        ..toggle('b');
      expect(behavior.isVisible('a'), isFalse);
      expect(behavior.isVisible('b'), isFalse);

      behavior.showAll();
      expect(behavior.isVisible('a'), isTrue);
      expect(behavior.isVisible('b'), isTrue);
    });

    test('visibility map is unmodifiable', () {
      final behavior = OiSeriesToggleBehavior()..toggle('a');

      expect(() => behavior.visibility['a'] = true, throwsUnsupportedError);
    });
  });
}
