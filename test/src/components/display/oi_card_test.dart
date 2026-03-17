// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('elevated variant renders child', (tester) async {
    await tester.pumpObers(
      const OiCard(
        child: Text('content'),
      ),
    );
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('outlined variant renders child', (tester) async {
    await tester.pumpObers(
      const OiCard(
        variant: OiCardVariant.outlined,
        child: Text('content'),
      ),
    );
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('flat variant renders child', (tester) async {
    await tester.pumpObers(
      const OiCard(
        variant: OiCardVariant.flat,
        child: Text('content'),
      ),
    );
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('interactive variant renders child', (tester) async {
    await tester.pumpObers(
      OiCard(
        variant: OiCardVariant.interactive,
        onTap: () {},
        child: const Text('content'),
      ),
    );
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('interactive variant uses OiTappable', (tester) async {
    await tester.pumpObers(
      OiCard(
        variant: OiCardVariant.interactive,
        onTap: () {},
        child: const Text('content'),
      ),
    );
    expect(find.byType(OiTappable), findsOneWidget);
  });

  testWidgets('onTap fires for interactive variant', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiCard(
        variant: OiCardVariant.interactive,
        onTap: () => tapped = true,
        child: const Text('tap me'),
      ),
    );
    await tester.tap(find.text('tap me'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('non-interactive variant does not use OiTappable',
      (tester) async {
    await tester.pumpObers(
      const OiCard(
        child: Text('content'),
      ),
    );
    expect(find.byType(OiTappable), findsNothing);
  });
}
