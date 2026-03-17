// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inline_edit/oi_editable.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders display mode initially', (tester) async {
    await tester.pumpObers(
      OiEditable<String>(
        value: 'hello',
        displayBuilder: (ctx, v, start) => Text(v),
        editBuilder: (ctx, v, commit, cancel) => const Text('editing'),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('editing'), findsNothing);
  });

  testWidgets('tap switches to edit mode', (tester) async {
    await tester.pumpObers(
      OiEditable<String>(
        value: 'hello',
        displayBuilder: (ctx, v, start) => Text(v),
        editBuilder: (ctx, v, commit, cancel) => const Text('editing'),
      ),
    );
    await tester.tap(find.text('hello'));
    await tester.pump();
    expect(find.text('editing'), findsOneWidget);
    expect(find.text('hello'), findsNothing);
  });

  testWidgets('commit calls onChanged and reverts to display', (tester) async {
    String? committed;
    late void Function(String) doCommit;

    await tester.pumpObers(
      OiEditable<String>(
        value: 'hello',
        onChanged: (v) => committed = v,
        displayBuilder: (ctx, v, start) => Text(v),
        editBuilder: (ctx, v, commit, cancel) {
          doCommit = commit;
          return const Text('editing');
        },
      ),
    );

    await tester.tap(find.text('hello'));
    await tester.pump();
    expect(find.text('editing'), findsOneWidget);

    doCommit('world');
    await tester.pump();

    expect(committed, 'world');
    expect(find.text('editing'), findsNothing);
  });

  testWidgets('cancel reverts to display without calling onChanged',
      (tester) async {
    String? committed;
    late VoidCallback doCancel;

    await tester.pumpObers(
      OiEditable<String>(
        value: 'hello',
        onChanged: (v) => committed = v,
        displayBuilder: (ctx, v, start) => Text(v),
        editBuilder: (ctx, v, commit, cancel) {
          doCancel = cancel;
          return const Text('editing');
        },
      ),
    );

    await tester.tap(find.text('hello'));
    await tester.pump();

    doCancel();
    await tester.pump();

    expect(committed, isNull);
    expect(find.text('editing'), findsNothing);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('disabled=false prevents edit mode on tap', (tester) async {
    await tester.pumpObers(
      OiEditable<String>(
        value: 'hello',
        enabled: false,
        displayBuilder: (ctx, v, start) => Text(v),
        editBuilder: (ctx, v, commit, cancel) => const Text('editing'),
      ),
    );
    await tester.tap(find.text('hello'));
    await tester.pump();
    expect(find.text('editing'), findsNothing);
  });

  testWidgets('editOnTap=false does not enter edit mode on tap', (tester) async {
    await tester.pumpObers(
      OiEditable<String>(
        value: 'hello',
        editOnTap: false,
        displayBuilder: (ctx, v, start) => Text(v),
        editBuilder: (ctx, v, commit, cancel) => const Text('editing'),
      ),
    );
    await tester.tap(find.text('hello'));
    await tester.pump();
    expect(find.text('editing'), findsNothing);
  });
}
