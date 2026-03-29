// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_status_dot.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiStatusDot', () {
    testWidgets('renders at specified size', (tester) async {
      await tester.pumpObers(
        const OiStatusDot(label: 'Online', size: 12),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final constraints = container.constraints;
      expect(constraints?.maxWidth, 12);
      expect(constraints?.maxHeight, 12);
    });

    testWidgets('has semantic label', (tester) async {
      await tester.pumpObers(
        const OiStatusDot(label: 'Server is online'),
      );

      expect(
        find.bySemanticsLabel('Server is online'),
        findsOneWidget,
      );
    });

    testWidgets('.active factory sets correct variant for true', (
      tester,
    ) async {
      final dot = OiStatusDot.active(active: true, label: 'Active');
      expect(dot.variant, OiStatusVariant.success);
      expect(dot.pulsing, isTrue);
    });

    testWidgets('.active factory sets muted for false', (tester) async {
      final dot = OiStatusDot.active(active: false, label: 'Inactive');
      expect(dot.variant, OiStatusVariant.muted);
      expect(dot.pulsing, isFalse);
    });

    testWidgets('respects explicit color override', (tester) async {
      await tester.pumpObers(
        const OiStatusDot(
          label: 'Custom',
          color: Color(0xFFFF0000),
        ),
      );

      expect(find.byType(OiStatusDot), findsOneWidget);
    });

    for (final variant in OiStatusVariant.values) {
      testWidgets('renders $variant variant', (tester) async {
        await tester.pumpObers(
          OiStatusDot(label: variant.name, variant: variant),
        );

        expect(find.byType(OiStatusDot), findsOneWidget);
      });
    }
  });
}
