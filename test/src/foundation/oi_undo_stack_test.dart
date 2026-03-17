// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_undo_stack.dart';

void main() {
  group('OiUndoAction', () {
    test('stores label, execute, and undo callbacks', () {
      var executed = false;
      var undone = false;

      final action = OiUndoAction(
        label: 'Test Action',
        execute: () => executed = true,
        undo: () => undone = true,
      );

      expect(action.label, 'Test Action');
      action.execute();
      expect(executed, isTrue);
      action.undo();
      expect(undone, isTrue);
    });

    test('groupId defaults to null', () {
      final action = OiUndoAction(
        label: 'A',
        execute: () {},
        undo: () {},
      );
      expect(action.groupId, isNull);
    });

    test('merge defaults to null', () {
      final action = OiUndoAction(
        label: 'A',
        execute: () {},
        undo: () {},
      );
      expect(action.merge, isNull);
    });

    test('stores optional groupId', () {
      final action = OiUndoAction(
        label: 'B',
        execute: () {},
        undo: () {},
        groupId: 'typing',
      );
      expect(action.groupId, 'typing');
    });
  });

  group('OiUndoStack', () {
    late OiUndoStack stack;

    setUp(() {
      stack = OiUndoStack();
    });

    tearDown(() {
      stack.dispose();
    });

    group('initial state', () {
      test('canUndo is false', () {
        expect(stack.canUndo, isFalse);
      });

      test('canRedo is false', () {
        expect(stack.canRedo, isFalse);
      });

      test('history is empty', () {
        expect(stack.history, isEmpty);
      });

      test('future is empty', () {
        expect(stack.future, isEmpty);
      });

      test('nextUndoLabel is null', () {
        expect(stack.nextUndoLabel, isNull);
      });

      test('nextRedoLabel is null', () {
        expect(stack.nextRedoLabel, isNull);
      });
    });

    group('push', () {
      test('adds action to history', () {
        final action = OiUndoAction(
          label: 'Action 1',
          execute: () {},
          undo: () {},
        );
        stack.push(action);
        expect(stack.history.length, 1);
        expect(stack.history.first, action);
      });

      test('canUndo becomes true after push', () {
        stack.push(OiUndoAction(label: 'A', execute: () {}, undo: () {}));
        expect(stack.canUndo, isTrue);
      });

      test('clears redo stack on push', () {
        final a1 = OiUndoAction(label: 'A1', execute: () {}, undo: () {});
        final a2 = OiUndoAction(label: 'A2', execute: () {}, undo: () {});
        final a3 = OiUndoAction(label: 'A3', execute: () {}, undo: () {});

        stack
          ..push(a1)
          ..push(a2)
          ..undo();

        expect(stack.canRedo, isTrue);
        stack.push(a3);
        expect(stack.canRedo, isFalse);
        expect(stack.future, isEmpty);
      });

      test('notifies listeners on push', () {
        var notified = false;
        stack
          ..addListener(() => notified = true)
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}));
        expect(notified, isTrue);
      });

      test('nextUndoLabel returns the pushed action label', () {
        stack.push(OiUndoAction(label: 'Rename', execute: () {}, undo: () {}));
        expect(stack.nextUndoLabel, 'Rename');
      });

      test('enforces maxHistory limit', () {
        final smallStack = OiUndoStack(maxHistory: 3);
        addTearDown(smallStack.dispose);
        for (var i = 0; i < 5; i++) {
          smallStack.push(
            OiUndoAction(label: 'Action $i', execute: () {}, undo: () {}),
          );
        }
        expect(smallStack.history.length, 3);
        expect(smallStack.history.last.label, 'Action 4');
      });

      test('oldest action is dropped when limit exceeded', () {
        final smallStack = OiUndoStack(maxHistory: 2)
          ..push(OiUndoAction(label: 'First', execute: () {}, undo: () {}))
          ..push(OiUndoAction(label: 'Second', execute: () {}, undo: () {}))
          ..push(OiUndoAction(label: 'Third', execute: () {}, undo: () {}));
        addTearDown(smallStack.dispose);
        expect(smallStack.history.first.label, 'Second');
        expect(smallStack.history.last.label, 'Third');
      });
    });

    group('undo', () {
      test('moves last history entry to future', () {
        final action = OiUndoAction(
          label: 'A',
          execute: () {},
          undo: () {},
        );
        stack
          ..push(action)
          ..undo();
        expect(stack.history, isEmpty);
        expect(stack.future.length, 1);
        expect(stack.future.first, action);
      });

      test('calls the undo callback', () {
        var undone = false;
        stack
          ..push(
            OiUndoAction(label: 'A', execute: () {}, undo: () => undone = true),
          )
          ..undo();
        expect(undone, isTrue);
      });

      test('canRedo becomes true after undo', () {
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..undo();
        expect(stack.canRedo, isTrue);
      });

      test('canUndo becomes false when all actions undone', () {
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..undo();
        expect(stack.canUndo, isFalse);
      });

      test('does nothing when canUndo is false', () {
        stack.undo(); // no-op
        expect(stack.history, isEmpty);
        expect(stack.future, isEmpty);
      });

      test('notifies listeners on undo', () {
        var count = 0;
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..addListener(() => count++)
          ..undo();
        expect(count, greaterThan(0));
      });

      test('nextRedoLabel returns undone action label', () {
        stack
          ..push(OiUndoAction(label: 'Move', execute: () {}, undo: () {}))
          ..undo();
        expect(stack.nextRedoLabel, 'Move');
      });
    });

    group('redo', () {
      test('moves last future entry back to history', () {
        final action = OiUndoAction(
          label: 'A',
          execute: () {},
          undo: () {},
        );
        stack
          ..push(action)
          ..undo()
          ..redo();
        expect(stack.history.length, 1);
        expect(stack.history.first, action);
        expect(stack.future, isEmpty);
      });

      test('calls the execute callback', () {
        var executed = false;
        stack
          ..push(
            OiUndoAction(
              label: 'A',
              execute: () => executed = true,
              undo: () {},
            ),
          )
          ..undo();
        executed = false; // reset; execute is not called on push, only on redo
        stack.redo();
        expect(executed, isTrue);
      });

      test('canUndo becomes true after redo', () {
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..undo()
          ..redo();
        expect(stack.canUndo, isTrue);
      });

      test('canRedo becomes false when all redone', () {
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..undo()
          ..redo();
        expect(stack.canRedo, isFalse);
      });

      test('does nothing when canRedo is false', () {
        stack.redo(); // no-op
        expect(stack.history, isEmpty);
        expect(stack.future, isEmpty);
      });

      test('notifies listeners on redo', () {
        var count = 0;
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..undo()
          ..addListener(() => count++)
          ..redo();
        expect(count, greaterThan(0));
      });
    });

    group('clear', () {
      test('empties history and future', () {
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..push(OiUndoAction(label: 'B', execute: () {}, undo: () {}))
          ..undo()
          ..clear();
        expect(stack.history, isEmpty);
        expect(stack.future, isEmpty);
      });

      test('canUndo is false after clear', () {
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..clear();
        expect(stack.canUndo, isFalse);
      });

      test('canRedo is false after clear', () {
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..undo()
          ..clear();
        expect(stack.canRedo, isFalse);
      });

      test('notifies listeners on clear', () {
        var notified = false;
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..addListener(() => notified = true)
          ..clear();
        expect(notified, isTrue);
      });
    });

    group('merge', () {
      test('merges actions with same groupId when merge function provided', () {
        var mergeCallCount = 0;

        OiUndoAction makeTypingAction(String text) {
          return OiUndoAction(
            label: 'Type "$text"',
            execute: () {},
            undo: () {},
            groupId: 'typing',
            merge: (next) {
              mergeCallCount++;
              if (next.groupId == 'typing') {
                return OiUndoAction(
                  label: 'Type "${text + next.label.substring(6).replaceAll('"', '')}"',
                  execute: () {},
                  undo: () {},
                  groupId: 'typing',
                  merge: next.merge,
                );
              }
              return null;
            },
          );
        }

        stack
          ..push(makeTypingAction('a'))
          ..push(makeTypingAction('b'));

        expect(stack.history.length, 1);
        expect(mergeCallCount, 1);
      });

      test('does not merge when groupId is null', () {
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..push(OiUndoAction(label: 'B', execute: () {}, undo: () {}));
        expect(stack.history.length, 2);
      });

      test('does not merge when groupIds differ', () {
        stack
          ..push(
            OiUndoAction(
              label: 'A',
              execute: () {},
              undo: () {},
              groupId: 'group1',
              merge: (_) => null,
            ),
          )
          ..push(
            OiUndoAction(
              label: 'B',
              execute: () {},
              undo: () {},
              groupId: 'group2',
              merge: (_) => null,
            ),
          );
        expect(stack.history.length, 2);
      });

      test('does not merge when merge returns null', () {
        stack
          ..push(
            OiUndoAction(
              label: 'A',
              execute: () {},
              undo: () {},
              groupId: 'typing',
              merge: (_) => null, // always refuse merge
            ),
          )
          ..push(
            OiUndoAction(
              label: 'B',
              execute: () {},
              undo: () {},
              groupId: 'typing',
            ),
          );
        expect(stack.history.length, 2);
      });
    });

    group('history and future are unmodifiable', () {
      test('history list cannot be mutated', () {
        stack.push(OiUndoAction(label: 'A', execute: () {}, undo: () {}));
        final history = stack.history;
        expect(
          () => history.add(
            OiUndoAction(label: 'B', execute: () {}, undo: () {}),
          ),
          throwsUnsupportedError,
        );
      });

      test('future list cannot be mutated', () {
        stack
          ..push(OiUndoAction(label: 'A', execute: () {}, undo: () {}))
          ..undo();
        final future = stack.future;
        expect(
          () => future.add(
            OiUndoAction(label: 'B', execute: () {}, undo: () {}),
          ),
          throwsUnsupportedError,
        );
      });
    });
  });

  group('OiUndoStackProvider', () {
    testWidgets('provides OiUndoStack to descendants via OiUndoStack.of',
        (tester) async {
      final testStack = OiUndoStack();
      late OiUndoStack captured;

      await tester.pumpWidget(
        OiUndoStackProvider(
          stack: testStack,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                captured = OiUndoStack.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(captured, same(testStack));
      testStack.dispose();
    });

    testWidgets('OiUndoStack.maybeOf returns null when no provider in tree',
        (tester) async {
      late OiUndoStack? captured;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              captured = OiUndoStack.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });

    testWidgets('OiUndoStack.of throws when no provider in tree',
        (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(
                () => OiUndoStack.of(context),
                throwsAssertionError,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('rebuilds dependents when stack notifies', (tester) async {
      final testStack = OiUndoStack();
      var buildCount = 0;

      await tester.pumpWidget(
        OiUndoStackProvider(
          stack: testStack,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                OiUndoStack.of(context); // subscribe
                buildCount++;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);

      testStack.push(
        OiUndoAction(label: 'Action', execute: () {}, undo: () {}),
      );
      await tester.pump();

      expect(buildCount, 2);
      testStack.dispose();
    });

    testWidgets('stack getter returns the notifier', (tester) async {
      final testStack = OiUndoStack();

      await tester.pumpWidget(
        OiUndoStackProvider(
          stack: testStack,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final provider = context
                    .dependOnInheritedWidgetOfExactType<OiUndoStackProvider>();
                expect(provider?.stack, same(testStack));
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      testStack.dispose();
    });
  });
}
