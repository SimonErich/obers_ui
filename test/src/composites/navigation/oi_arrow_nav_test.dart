// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_arrow_nav.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Builds a vertical [OiArrowNav] with the given parameters and a simple
/// focusable child.
Widget _verticalNav({
  int itemCount = 5,
  int? highlightedIndex,
  ValueChanged<int>? onHighlightChange,
  ValueChanged<int>? onSelect,
  VoidCallback? onEscape,
  bool loop = true,
  bool enabled = true,
  bool autofocus = true,
  FocusNode? focusNode,
}) {
  return OiArrowNav(
    itemCount: itemCount,
    highlightedIndex: highlightedIndex,
    onHighlightChange: onHighlightChange,
    onSelect: onSelect,
    onEscape: onEscape,
    loop: loop,
    enabled: enabled,
    autofocus: autofocus,
    focusNode: focusNode,
    child: const SizedBox.square(dimension: 100),
  );
}

/// Builds a horizontal [OiArrowNav].
Widget _horizontalNav({
  int itemCount = 5,
  int? highlightedIndex,
  ValueChanged<int>? onHighlightChange,
  ValueChanged<int>? onSelect,
  VoidCallback? onEscape,
  bool loop = true,
  bool enabled = true,
  bool autofocus = true,
  FocusNode? focusNode,
}) {
  return OiArrowNav(
    itemCount: itemCount,
    highlightedIndex: highlightedIndex,
    onHighlightChange: onHighlightChange,
    onSelect: onSelect,
    onEscape: onEscape,
    direction: Axis.horizontal,
    loop: loop,
    enabled: enabled,
    autofocus: autofocus,
    focusNode: focusNode,
    child: const SizedBox.square(dimension: 100),
  );
}

/// Sends a key-down and key-up event pair for the given [key].
Future<void> _sendKeyDown(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  await tester.pump();
}

/// Builds a vertical [OiArrowNav] with type-ahead enabled.
Widget _typeAheadNav({
  int? highlightedIndex,
  ValueChanged<int>? onHighlightChange,
  bool autofocus = true,
}) {
  const labels = ['Apple', 'Banana', 'Blueberry', 'Cherry', 'Date'];
  return OiArrowNav(
    itemCount: labels.length,
    highlightedIndex: highlightedIndex,
    onHighlightChange: onHighlightChange,
    typeAhead: true,
    itemLabel: (i) => labels[i],
    autofocus: autofocus,
    child: const SizedBox.square(dimension: 100),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('OiArrowNav – vertical', () {
    testWidgets('arrow down increments highlightedIndex', (tester) async {
      int? reported;
      await tester.pumpObers(
        _verticalNav(
          highlightedIndex: 1,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowDown);
      expect(reported, 2);
    });

    testWidgets('arrow up decrements highlightedIndex', (tester) async {
      int? reported;
      await tester.pumpObers(
        _verticalNav(
          highlightedIndex: 3,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowUp);
      expect(reported, 2);
    });

    testWidgets('loop wraps from last to first', (tester) async {
      int? reported;
      await tester.pumpObers(
        _verticalNav(
          highlightedIndex: 4,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowDown);
      expect(reported, 0);
    });

    testWidgets('loop wraps from first to last', (tester) async {
      int? reported;
      await tester.pumpObers(
        _verticalNav(
          highlightedIndex: 0,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowUp);
      expect(reported, 4);
    });

    testWidgets('loop=false stops at last boundary', (tester) async {
      int? reported;
      await tester.pumpObers(
        _verticalNav(
          highlightedIndex: 4,
          loop: false,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowDown);
      expect(reported, isNull, reason: 'should not change at boundary');
    });

    testWidgets('loop=false stops at first boundary', (tester) async {
      int? reported;
      await tester.pumpObers(
        _verticalNav(
          highlightedIndex: 0,
          loop: false,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowUp);
      expect(reported, isNull, reason: 'should not change at boundary');
    });

    testWidgets('Enter fires onSelect with current highlightedIndex', (
      tester,
    ) async {
      int? selected;
      await tester.pumpObers(
        _verticalNav(highlightedIndex: 2, onSelect: (i) => selected = i),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.enter);
      expect(selected, 2);
    });

    testWidgets('Enter does nothing when highlightedIndex is null', (
      tester,
    ) async {
      int? selected;
      await tester.pumpObers(_verticalNav(onSelect: (i) => selected = i));

      await _sendKeyDown(tester, LogicalKeyboardKey.enter);
      expect(selected, isNull);
    });

    testWidgets('Escape fires onEscape', (tester) async {
      var escaped = false;
      await tester.pumpObers(
        _verticalNav(highlightedIndex: 0, onEscape: () => escaped = true),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.escape);
      expect(escaped, isTrue);
    });

    testWidgets('enabled=false disables all keyboard handling', (tester) async {
      int? reported;
      var escaped = false;
      await tester.pumpObers(
        _verticalNav(
          highlightedIndex: 1,
          enabled: false,
          onHighlightChange: (i) => reported = i,
          onEscape: () => escaped = true,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowDown);
      expect(reported, isNull);

      await _sendKeyDown(tester, LogicalKeyboardKey.escape);
      expect(escaped, isFalse);
    });

    testWidgets('itemCount=0 handles gracefully', (tester) async {
      int? reported;
      await tester.pumpObers(
        _verticalNav(itemCount: 0, onHighlightChange: (i) => reported = i),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowDown);
      expect(reported, isNull);

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowUp);
      expect(reported, isNull);
    });

    testWidgets('multiple rapid arrow presses work correctly', (tester) async {
      final changes = <int>[];

      // Use a stateful wrapper to simulate rebuilds with updated index.
      await tester.pumpObers(
        _RapidPressHarness(
          itemCount: 5,
          direction: Axis.vertical,
          onChange: changes.add,
        ),
      );

      // Send 4 rapid down presses.
      for (var i = 0; i < 4; i++) {
        await _sendKeyDown(tester, LogicalKeyboardKey.arrowDown);
      }

      expect(changes, [0, 1, 2, 3]);
    });

    testWidgets('arrow down with null highlightedIndex starts at 0', (
      tester,
    ) async {
      int? reported;
      await tester.pumpObers(
        _verticalNav(onHighlightChange: (i) => reported = i),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowDown);
      expect(reported, 0);
    });

    testWidgets('arrow up with null highlightedIndex starts at last', (
      tester,
    ) async {
      int? reported;
      await tester.pumpObers(
        _verticalNav(onHighlightChange: (i) => reported = i),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowUp);
      expect(reported, 4);
    });
  });

  group('OiArrowNav – horizontal', () {
    testWidgets('arrow right increments highlightedIndex', (tester) async {
      int? reported;
      await tester.pumpObers(
        _horizontalNav(
          highlightedIndex: 1,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowRight);
      expect(reported, 2);
    });

    testWidgets('arrow left decrements highlightedIndex', (tester) async {
      int? reported;
      await tester.pumpObers(
        _horizontalNav(
          highlightedIndex: 3,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowLeft);
      expect(reported, 2);
    });

    testWidgets('up/down arrows are ignored in horizontal mode', (
      tester,
    ) async {
      int? reported;
      await tester.pumpObers(
        _horizontalNav(
          highlightedIndex: 1,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowDown);
      expect(reported, isNull);

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowUp);
      expect(reported, isNull);
    });

    testWidgets('loop wraps in horizontal mode', (tester) async {
      int? reported;
      await tester.pumpObers(
        _horizontalNav(
          highlightedIndex: 4,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowRight);
      expect(reported, 0);
    });
  });

  group('OiArrowNav – typeAhead', () {
    testWidgets('typing a letter jumps to first matching item', (tester) async {
      int? reported;
      await tester.pumpObers(
        _typeAheadNav(onHighlightChange: (i) => reported = i),
      );

      // Type 'c' → should jump to Cherry (index 3).
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pump();
      expect(reported, 3);
    });

    testWidgets('typing multiple letters narrows the match', (tester) async {
      int? reported;
      await tester.pumpObers(
        _typeAheadNav(onHighlightChange: (i) => reported = i),
      );

      // Type 'b' → Banana (index 1).
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pump();
      expect(reported, 1);

      // Type 'l' (buffer = 'bl') → Blueberry (index 2).
      await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
      await tester.pump();
      expect(reported, 2);
    });

    testWidgets('buffer resets after timeout', (tester) async {
      int? reported;
      await tester.pumpObers(
        _typeAheadNav(onHighlightChange: (i) => reported = i),
      );

      // Type 'b' → Banana (index 1).
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pump();
      expect(reported, 1);

      // Wait for the buffer to reset (500ms).
      await tester.pump(const Duration(milliseconds: 600));

      // Type 'c' → Cherry (index 3), not 'bc'.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pump();
      expect(reported, 3);
    });

    testWidgets('typeAhead is case-insensitive', (tester) async {
      int? reported;
      await tester.pumpObers(
        _typeAheadNav(onHighlightChange: (i) => reported = i),
      );

      // Type 'A' → Apple (index 0).
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(reported, 0);
    });

    testWidgets('no match does not change highlight', (tester) async {
      int? reported;
      await tester.pumpObers(
        _typeAheadNav(
          highlightedIndex: 0,
          onHighlightChange: (i) => reported = i,
        ),
      );

      // Type 'z' → no match.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pump();
      expect(reported, isNull, reason: 'no item starts with z');
    });
  });

  group('OiArrowNav – focusNode and autofocus', () {
    testWidgets('custom focusNode receives key events', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      int? reported;
      await tester.pumpObers(
        _verticalNav(
          focusNode: focusNode,
          highlightedIndex: 0,
          onHighlightChange: (i) => reported = i,
        ),
      );

      await _sendKeyDown(tester, LogicalKeyboardKey.arrowDown);
      expect(reported, 1);
    });

    testWidgets('autofocus true causes immediate focus', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpObers(
        _verticalNav(focusNode: focusNode, highlightedIndex: 0),
      );

      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('autofocus false (default) does not auto-focus', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpObers(
        _verticalNav(
          focusNode: focusNode,
          autofocus: false,
          highlightedIndex: 0,
        ),
      );

      expect(focusNode.hasFocus, isFalse);
    });

    testWidgets('default autofocus is false', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      // Use OiArrowNav directly without the helper's autofocus: true default.
      await tester.pumpObers(
        OiArrowNav(
          itemCount: 5,
          focusNode: focusNode,
          child: const SizedBox.square(dimension: 100),
        ),
      );

      expect(focusNode.hasFocus, isFalse);
    });
  });
}

// ── Stateful harness for rapid-press testing ────────────────────────────────

/// A stateful wrapper that updates [OiArrowNav.highlightedIndex] on each
/// change, simulating real-world usage where the parent rebuilds.
class _RapidPressHarness extends StatefulWidget {
  const _RapidPressHarness({
    required this.itemCount,
    required this.direction,
    required this.onChange,
  });

  final int itemCount;
  final Axis direction;
  final ValueChanged<int> onChange;

  @override
  State<_RapidPressHarness> createState() => _RapidPressHarnessState();
}

class _RapidPressHarnessState extends State<_RapidPressHarness> {
  int? _index;

  @override
  Widget build(BuildContext context) {
    return OiArrowNav(
      itemCount: widget.itemCount,
      highlightedIndex: _index,
      direction: widget.direction,
      autofocus: true,
      onHighlightChange: (i) {
        setState(() => _index = i);
        widget.onChange(i);
      },
      child: const SizedBox.square(dimension: 100),
    );
  }
}
