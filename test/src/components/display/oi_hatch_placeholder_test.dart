import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('short placeholder respects its requested minimum height', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 312,
          child: OiHatchPlaceholder(
            label: 'Total pending',
            height: 56,
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(OiHatchPlaceholder)).height, 56);
    expect(
      tester.getRect(find.text('Total pending')).height,
      lessThanOrEqualTo(18),
    );
  });

  testWidgets(
    'populated preview preserves its content and accessible explanation',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpObers(
        const Center(
          child: SizedBox(
            width: 312,
            child: OiHatchPlaceholder(
              label: 'Not saved yet',
              height: 90,
              child: Text('Ready to create the order'),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(OiHatchPlaceholder)).height, 90);
      expect(find.text('Ready to create the order'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Not saved yet\nReady to create the order'),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );
}
