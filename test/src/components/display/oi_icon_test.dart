// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs
// REQ-0018: OiIcon accessibility enforcement tests.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const testIcon = IconData(0xe000, fontFamily: 'MaterialIcons');

  // ── REQ-0018: required label ───────────────────────────────────────────────

  testWidgets('OiIcon requires label and exposes it in semantics tree', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(const OiIcon(icon: testIcon, label: 'Search'));
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('OiIcon label is in a Semantics node with image flag', (
    tester,
  ) async {
    await tester.pumpObers(const OiIcon(icon: testIcon, label: 'Close'));
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'Close')
        .toList();
    expect(matching, hasLength(1));
    expect(matching.first.properties.image, isTrue);
  });

  // ── REQ-0018: OiIcon.decorative() excludes from semantics tree ─────────────

  testWidgets('OiIcon.decorative() renders icon', (tester) async {
    await tester.pumpObers(const OiIcon.decorative(icon: testIcon));
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('OiIcon.decorative() excludes icon from semantics tree', (
    tester,
  ) async {
    await tester.pumpObers(const OiIcon.decorative(icon: testIcon));
    expect(find.byType(ExcludeSemantics), findsAtLeastNWidgets(1));
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final withLabel = semanticsWidgets
        .where(
          (s) => s.properties.label != null && s.properties.label!.isNotEmpty,
        )
        .toList();
    expect(withLabel, isEmpty);
  });
}
