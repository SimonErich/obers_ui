// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders title', (tester) async {
    await tester.pumpObers(
      const OiEmptyState(title: 'Nothing here'),
    );
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('renders icon when provided', (tester) async {
    const icon = IconData(0xe88e, fontFamily: 'MaterialIcons');
    await tester.pumpObers(
      const OiEmptyState(title: 'Empty', icon: icon),
    );
    expect(find.byIcon(icon), findsOneWidget);
  });

  testWidgets('illustration takes priority over icon', (tester) async {
    const icon = IconData(0xe88e, fontFamily: 'MaterialIcons');
    await tester.pumpObers(
      const OiEmptyState(
        title: 'Empty',
        icon: icon,
        illustration: SizedBox(key: Key('illus'), width: 64, height: 64),
      ),
    );
    expect(find.byKey(const Key('illus')), findsOneWidget);
    expect(find.byIcon(icon), findsNothing);
  });

  testWidgets('renders description when provided', (tester) async {
    await tester.pumpObers(
      const OiEmptyState(
        title: 'Empty',
        description: 'Try adding some items.',
      ),
    );
    expect(find.text('Try adding some items.'), findsOneWidget);
  });

  testWidgets('renders action slot when provided', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiEmptyState(
        title: 'Empty',
        action: GestureDetector(
          onTap: () => tapped = true,
          child: const Text('Add item'),
        ),
      ),
    );
    await tester.tap(find.text('Add item'));
    expect(tapped, isTrue);
  });
}
