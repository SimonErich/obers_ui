// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_scroll_behavior.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiScrollBehavior', () {
    testWidgets('strips overscroll indicator', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: SizedBox(height: 2000, child: Placeholder()),
        ),
        surfaceSize: const Size(400, 600),
      );

      // The OiScrollBehavior should inject via OiApp's builder.
      // Verify no GlowingOverscrollIndicator is present.
      expect(find.byType(GlowingOverscrollIndicator), findsNothing);
    });

    test('can be const-constructed', () {
      const behavior = OiScrollBehavior();
      expect(behavior, isNotNull);
    });
  });
}
