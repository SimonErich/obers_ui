// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/feedback/oi_star_rating.dart';

import '../../../helpers/pump_app.dart';

/// Finds [CustomPaint] widgets that are direct descendants of [OiStarRating].
Finder _starPaints() => find.descendant(
  of: find.byType(OiStarRating),
  matching: find.byType(CustomPaint),
);

/// Finds [GestureDetector] widgets inside [OiStarRating].
Finder _starGestures() => find.descendant(
  of: find.byType(OiStarRating),
  matching: find.byType(GestureDetector),
);

void main() {
  testWidgets('renders correct number of stars', (tester) async {
    await tester.pumpObers(const OiStarRating(value: 3));
    expect(_starPaints(), findsNWidgets(5));
  });

  testWidgets('readOnly=true does not fire onChanged on tap', (tester) async {
    var changed = false;
    await tester.pumpObers(
      OiStarRating(value: 2, readOnly: true, onChanged: (_) => changed = true),
    );
    // No GestureDetectors in readOnly mode — tapping anywhere is a no-op.
    expect(_starGestures(), findsNothing);
    expect(changed, isFalse);
  });

  testWidgets('onChanged fires when tapping a star', (tester) async {
    double? received;
    await tester.pumpObers(OiStarRating(onChanged: (v) => received = v));
    await tester.tapAt(tester.getCenter(_starGestures().first));
    await tester.pump();
    expect(received, isNotNull);
  });

  testWidgets('allowHalf=true yields 0.5 increment on left-half tap', (
    tester,
  ) async {
    double? received;
    await tester.pumpObers(
      OiStarRating(allowHalf: true, size: 40, onChanged: (v) => received = v),
    );
    final starPos = tester.getTopLeft(_starGestures().first);
    // Tap near left edge of first star (x=5 is well inside the left half).
    await tester.tapAt(starPos + const Offset(5, 20));
    await tester.pump();
    expect(received, 0.5);
  });

  testWidgets('default maxStars is 5', (tester) async {
    await tester.pumpObers(const OiStarRating());
    expect(_starPaints(), findsNWidgets(5));
  });

  testWidgets('custom maxStars respected', (tester) async {
    await tester.pumpObers(const OiStarRating(maxStars: 3));
    expect(_starPaints(), findsNWidgets(3));
  });

  testWidgets('label is included in semantics', (tester) async {
    await tester.pumpObers(
      const OiStarRating(label: 'Overall rating', value: 3),
    );
    expect(find.bySemanticsLabel(RegExp('Overall rating')), findsOneWidget);
  });

  testWidgets('arrow right increments value', (tester) async {
    double? received;
    await tester.pumpObers(
      OiStarRating(value: 2, onChanged: (v) => received = v),
    );
    // Tab to focus the widget, then send arrow key.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(received, 3.0);
  });

  testWidgets('arrow left decrements value', (tester) async {
    double? received;
    await tester.pumpObers(
      OiStarRating(value: 3, onChanged: (v) => received = v),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(received, 2.0);
  });

  testWidgets('arrow right with allowHalf increments by 0.5', (tester) async {
    double? received;
    await tester.pumpObers(
      OiStarRating(value: 2, allowHalf: true, onChanged: (v) => received = v),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(received, 2.5);
  });

  testWidgets('readOnly=true arrow keys do not fire onChanged', (tester) async {
    double? received;
    await tester.pumpObers(
      OiStarRating(value: 3, readOnly: true, onChanged: (v) => received = v),
    );
    // No Focus widget in readOnly mode — key events should not fire onChanged.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(received, isNull);
  });

  testWidgets('slider semantics role is set', (tester) async {
    await tester.pumpObers(const OiStarRating(value: 2));
    final semanticsNode = tester.getSemantics(find.byType(OiStarRating));
    expect(semanticsNode.hasFlag(SemanticsFlag.isSlider), isTrue);
  });
}
