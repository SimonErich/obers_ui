import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/behaviors/oi_hover_sync_behavior.dart';

void main() {
  group('OiHoverSyncBehavior', () {
    test('updatePosition fires callback and updates state', () {
      final positions = <double?>[];
      final behavior = OiHoverSyncBehavior(
        onHoverPositionChanged: positions.add,
      )..updatePosition(42);
      expect(behavior.currentPosition, 42.0);
      expect(positions, [42.0]);
    });

    test('duplicate position is ignored', () {
      final positions = <double?>[];
      OiHoverSyncBehavior(onHoverPositionChanged: positions.add)
        ..updatePosition(42)
        ..updatePosition(42);
      expect(positions, [42.0]); // Only one call
    });

    test('clearHover sets position to null', () {
      final positions = <double?>[];
      final behavior =
          OiHoverSyncBehavior(onHoverPositionChanged: positions.add)
            ..updatePosition(42)
            ..clearHover();
      expect(behavior.currentPosition, isNull);
      expect(positions.last, isNull);
    });

    test('starts with null position', () {
      final behavior = OiHoverSyncBehavior();
      expect(behavior.currentPosition, isNull);
    });
  });
}
