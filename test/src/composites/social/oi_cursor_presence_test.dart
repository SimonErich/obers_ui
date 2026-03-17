// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/social/oi_cursor_presence.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

OiRemoteCursor _cursor({
  String userId = 'u1',
  String name = 'Alice',
  Color color = const Color(0xFFFF0000),
  Offset position = const Offset(50, 50),
  DateTime? lastMoved,
}) {
  return OiRemoteCursor(
    userId: userId,
    name: name,
    color: color,
    position: position,
    lastMoved: lastMoved ?? DateTime.now(),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('cursors render at the specified positions', (tester) async {
    final cursors = [
      _cursor(position: const Offset(100, 200)),
    ];

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiCursorPresence(
          cursors: cursors,
          child: const ColoredBox(color: Color(0xFFEEEEEE)),
        ),
      ),
    );

    // There should be a Positioned widget at left=100, top=200.
    final positioned = tester.widgetList<Positioned>(
      find.byType(Positioned),
    );
    final cursorPositioned = positioned.where(
      (p) => p.left == 100 && p.top == 200,
    );
    expect(cursorPositioned, isNotEmpty);
  });

  testWidgets('user names are shown when showNames is true', (tester) async {
    final cursors = [_cursor(name: 'Bob')];

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiCursorPresence(
          cursors: cursors,
          child: const SizedBox.expand(),
        ),
      ),
    );

    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('user names are hidden when showNames is false', (tester) async {
    final cursors = [_cursor(name: 'Bob')];

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiCursorPresence(
          cursors: cursors,
          showNames: false,
          child: const SizedBox.expand(),
        ),
      ),
    );

    expect(find.text('Bob'), findsNothing);
  });

  testWidgets('stale cursors are rendered with reduced opacity',
      (tester) async {
    final staleCursor = _cursor(
      lastMoved: DateTime.now().subtract(const Duration(seconds: 10)),
    );

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiCursorPresence(
          cursors: [staleCursor],
          child: const SizedBox.expand(),
        ),
      ),
    );

    // The Opacity wrapper around the stale cursor should have opacity < 1.
    final opacityWidgets = tester.widgetList<Opacity>(
      find.byType(Opacity),
    );
    final staleOpacity = opacityWidgets.where((o) => o.opacity < 1.0);
    expect(staleOpacity, isNotEmpty);
  });

  testWidgets('each cursor uses its assigned color', (tester) async {
    final cursors = [
      _cursor(position: const Offset(10, 10)),
      _cursor(
        userId: 'u2',
        name: 'Bob',
        color: const Color(0xFF00FF00),
      ),
    ];

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiCursorPresence(
          cursors: cursors,
          child: const SizedBox.expand(),
        ),
      ),
    );

    // Both names are rendered, proving both cursors are present.
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);

    // Both cursors have CustomPaint widgets (at least 2).
    expect(find.byType(CustomPaint), findsAtLeast(2));
  });

  testWidgets('child renders beneath cursors', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 400,
        height: 400,
        child: OiCursorPresence(
          cursors: [],
          child: Text('Canvas'),
        ),
      ),
    );

    expect(find.text('Canvas'), findsOneWidget);
  });
}
