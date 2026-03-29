// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_text_selection_controls.dart';

void main() {
  group('OiTextSelectionControls', () {
    late OiTextSelectionControls controls;

    setUp(() {
      controls = OiTextSelectionControls();
    });

    test('getHandleSize returns non-zero size', () {
      final size = controls.getHandleSize(16);
      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
    });

    test('getHandleAnchor returns valid offsets for all types', () {
      for (final type in TextSelectionHandleType.values) {
        final anchor = controls.getHandleAnchor(type, 16);
        expect(anchor.dx, greaterThanOrEqualTo(0));
        expect(anchor.dy, greaterThanOrEqualTo(0));
      }
    });

    test('handle radius respects minimum of 6', () {
      final smallSize = controls.getHandleSize(4);
      // Minimum radius of 6 → diameter 12
      expect(smallSize.width, greaterThanOrEqualTo(12));
    });
  });
}
