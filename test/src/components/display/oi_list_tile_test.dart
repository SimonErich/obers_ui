// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_list_tile.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders title', (tester) async {
    await tester.pumpObers(const OiListTile(title: 'Item One'));
    expect(find.text('Item One'), findsOneWidget);
  });

  testWidgets('renders subtitle when provided', (tester) async {
    await tester.pumpObers(const OiListTile(title: 'Title', subtitle: 'Sub'));
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Sub'), findsOneWidget);
  });

  testWidgets('renders leading widget', (tester) async {
    await tester.pumpObers(
      const OiListTile(
        title: 'Item',
        leading: Icon(IconData(0xe318, fontFamily: 'MaterialIcons')),
      ),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('renders trailing widget', (tester) async {
    await tester.pumpObers(
      const OiListTile(
        title: 'Item',
        trailing: Icon(IconData(0xe5c5, fontFamily: 'MaterialIcons')),
      ),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('onTap fires when tapped', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiListTile(title: 'Tap me', onTap: () => tapped = true),
    );
    await tester.tap(find.text('Tap me'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('selected tile has highlight background', (tester) async {
    await tester.pumpObers(const OiListTile(title: 'Selected', selected: true));
    expect(find.byType(ColoredBox), findsOneWidget);
  });

  testWidgets('dense reduces vertical space', (tester) async {
    await tester.pumpObers(const OiListTile(title: 'Dense', dense: true));
    expect(find.text('Dense'), findsOneWidget);
  });
}
