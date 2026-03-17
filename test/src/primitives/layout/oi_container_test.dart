// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/layout/oi_container.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders child', (tester) async {
    await tester.pumpObers(const OiContainer(child: Text('hello')));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('renders without child', (tester) async {
    await tester.pumpObers(const OiContainer());
    expect(find.byType(OiContainer), findsOneWidget);
  });

  // ── maxWidth constraint ────────────────────────────────────────────────────

  testWidgets('applies maxWidth via ConstrainedBox', (tester) async {
    await tester.pumpObers(const OiContainer(maxWidth: 300, child: Text('x')));
    final boxes = tester
        .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
        .where((b) => b.constraints.maxWidth == 300)
        .toList();
    expect(boxes, hasLength(1));
  });

  testWidgets('maxWidth defaults to infinity when not set', (tester) async {
    await tester.pumpObers(const OiContainer(child: Text('x')));
    final boxes = tester
        .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
        .where((b) => b.constraints.maxWidth == double.infinity)
        .toList();
    expect(boxes, isNotEmpty);
  });

  // ── Padding ────────────────────────────────────────────────────────────────

  testWidgets('applies padding when provided', (tester) async {
    await tester.pumpObers(
      const OiContainer(padding: EdgeInsets.all(16), child: Text('padded')),
    );
    final padding = tester.widget<Padding>(find.byType(Padding));
    expect(padding.padding, const EdgeInsets.all(16));
  });

  testWidgets('no Padding widget when padding is null', (tester) async {
    await tester.pumpObers(const OiContainer(child: Text('no pad')));
    expect(find.byType(Padding), findsNothing);
  });

  // ── Centering ─────────────────────────────────────────────────────────────

  testWidgets('centered=true wraps in Center', (tester) async {
    await tester.pumpObers(const OiContainer(child: Text('centered')));
    expect(find.byType(Center), findsOneWidget);
  });

  testWidgets('centered=false does not wrap in Center', (tester) async {
    await tester.pumpObers(
      const OiContainer(centered: false, child: Text('not centered')),
    );
    expect(find.byType(Center), findsNothing);
  });
}
