// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_optimistic_action.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('apply is called immediately', (tester) async {
    var applied = false;
    await tester.pumpObers(
      Builder(
        builder: (context) => GestureDetector(
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () => applied = true,
            onRollback: () {},
            commit: () async {},
            message: 'Done',
          ),
          child: const Text('Go'),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    expect(applied, isTrue);
  });

  testWidgets('snackbar appears after apply', (tester) async {
    await tester.pumpObers(
      Builder(
        builder: (context) => GestureDetector(
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () {},
            onRollback: () {},
            commit: () async {},
            message: 'Item deleted',
          ),
          child: const Text('Go'),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pump();
    // Snackbar content is in overlay — verify it exists.
    expect(find.text('Item deleted'), findsOneWidget);
  });

  testWidgets('commit called after undo duration expires', (tester) async {
    var committed = false;
    await tester.pumpObers(
      Builder(
        builder: (context) => GestureDetector(
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () {},
            onRollback: () {},
            commit: () async => committed = true,
            message: 'Deleted',
            undoDuration: const Duration(milliseconds: 200),
          ),
          child: const Text('Go'),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(committed, isTrue);
  });

  testWidgets('commit failure triggers rollback', (tester) async {
    var rolledBack = false;
    await tester.pumpObers(
      Builder(
        builder: (context) => GestureDetector(
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () {},
            onRollback: () => rolledBack = true,
            commit: () async => throw Exception('fail'),
            message: 'Deleted',
            errorMessage: 'Failed',
            undoDuration: const Duration(milliseconds: 200),
          ),
          child: const Text('Go'),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(rolledBack, isTrue);
  });

  testWidgets('execute returns true on successful commit', (tester) async {
    bool? result;
    await tester.pumpObers(
      Builder(
        builder: (context) => GestureDetector(
          onTap: () async {
            result = await OiOptimisticAction.execute(
              context,
              apply: () {},
              onRollback: () {},
              commit: () async {},
              message: 'Deleted',
              undoDuration: const Duration(milliseconds: 200),
            );
          },
          child: const Text('Go'),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(result, isTrue);
  });

  testWidgets('cancelPending rolls back pending action', (tester) async {
    var rolledBack = false;
    await tester.pumpObers(
      Builder(
        builder: (context) => Column(
          children: [
            GestureDetector(
              onTap: () => OiOptimisticAction.execute(
                context,
                apply: () {},
                onRollback: () => rolledBack = true,
                commit: () async {},
                message: 'Deleted',
              ),
              child: const Text('Delete'),
            ),
            GestureDetector(
              onTap: () => OiOptimisticAction.cancelPending(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    expect(rolledBack, isTrue);
  });
}
