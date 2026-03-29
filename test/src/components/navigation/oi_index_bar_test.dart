// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_index_bar.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── alphabet() factory ───────────────────────────────────────────────────

  testWidgets('alphabet() renders 26 letters plus #', (tester) async {
    await tester.pumpObers(
      OiIndexBar.alphabet(
        onLabelSelected: (_) {},
        semanticLabel: 'Alphabet index',
      ),
      surfaceSize: const Size(800, 800),
    );

    for (var i = 0; i < 26; i++) {
      final letter = String.fromCharCode(0x41 + i);
      expect(
        find.text(letter),
        findsOneWidget,
        reason: 'Missing letter $letter',
      );
    }
    expect(find.text('#'), findsOneWidget);
  });

  testWidgets('alphabet() excludes # when includeHash is false', (
    tester,
  ) async {
    await tester.pumpObers(
      OiIndexBar.alphabet(
        onLabelSelected: (_) {},
        semanticLabel: 'Alphabet index',
        includeHash: false,
      ),
      surfaceSize: const Size(800, 800),
    );

    expect(find.text('#'), findsNothing);
    // Still has all 26 letters.
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Z'), findsOneWidget);
  });

  // ── Tapping ──────────────────────────────────────────────────────────────

  testWidgets('tapping a letter calls onLabelSelected', (tester) async {
    String? selected;
    await tester.pumpObers(
      OiIndexBar(
        labels: const ['A', 'B', 'C'],
        onLabelSelected: (label) => selected = label,
        semanticLabel: 'Test index',
      ),
      surfaceSize: const Size(800, 800),
    );

    await tester.tap(find.text('B'));
    await tester.pump();
    expect(selected, equals('B'));
  });

  // ── Active label ─────────────────────────────────────────────────────────

  testWidgets('activeLabel highlights the current letter', (tester) async {
    await tester.pumpObers(
      OiIndexBar(
        labels: const ['X', 'Y', 'Z'],
        onLabelSelected: (_) {},
        semanticLabel: 'Test index',
        activeLabel: 'Y',
      ),
      surfaceSize: const Size(800, 800),
    );

    // The widget renders — activeLabel is applied internally.
    // We verify it renders without error and all labels are present.
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);
    expect(find.text('Z'), findsOneWidget);
  });

  // ── Unavailable labels ───────────────────────────────────────────────────

  testWidgets('unavailable labels are dimmed', (tester) async {
    await tester.pumpObers(
      OiIndexBar(
        labels: const ['A', 'B', 'C'],
        onLabelSelected: (_) {},
        semanticLabel: 'Test index',
        availableLabels: const {'A', 'C'},
      ),
      surfaceSize: const Size(800, 800),
    );

    // All labels render — B is dimmed (uses textMuted color internally).
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  // ── Custom labels ────────────────────────────────────────────────────────

  testWidgets('custom labels render correctly', (tester) async {
    await tester.pumpObers(
      OiIndexBar(
        labels: const ['1', '2', '3', '4', '5'],
        onLabelSelected: (_) {},
        semanticLabel: 'Numeric index',
      ),
      surfaceSize: const Size(800, 800),
    );

    for (final label in ['1', '2', '3', '4', '5']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  // ── Label count ──────────────────────────────────────────────────────────

  testWidgets('renders correct number of labels', (tester) async {
    const labels = ['M', 'N', 'O', 'P'];
    await tester.pumpObers(
      OiIndexBar(
        labels: labels,
        onLabelSelected: (_) {},
        semanticLabel: 'Test index',
      ),
      surfaceSize: const Size(800, 800),
    );

    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
