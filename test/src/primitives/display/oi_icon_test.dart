// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const testIcon = IconData(0xe000, fontFamily: 'MaterialIcons');

  // ── Semantic icon ──────────────────────────────────────────────────────────

  testWidgets('renders Icon widget', (tester) async {
    await tester.pumpObers(const OiIcon(icon: testIcon, label: 'test icon'));
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('semantic icon has Semantics node with label', (tester) async {
    await tester.pumpObers(const OiIcon(icon: testIcon, label: 'star icon'));
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'star icon')
        .toList();
    expect(matching, hasLength(1));
    expect(matching.first.properties.image, isTrue);
  });

  testWidgets('semantic icon wraps icon in ExcludeSemantics', (tester) async {
    await tester.pumpObers(const OiIcon(icon: testIcon, label: 'star icon'));
    // OiIcon inserts exactly one ExcludeSemantics that is a descendant of
    // the Semantics node it creates (to exclude the Icon from the tree
    // while the outer Semantics carries the label).
    final semanticsFinder = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'star icon',
    );
    expect(
      find.descendant(
        of: semanticsFinder,
        matching: find.byType(ExcludeSemantics),
      ),
      findsAtLeastNWidgets(1),
    );
  });

  // ── Decorative icon ────────────────────────────────────────────────────────

  testWidgets('decorative icon renders Icon widget', (tester) async {
    await tester.pumpObers(const OiIcon.decorative(icon: testIcon));
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('decorative icon uses ExcludeSemantics', (tester) async {
    await tester.pumpObers(const OiIcon.decorative(icon: testIcon));
    // OiIcon.decorative must produce at least one ExcludeSemantics.
    expect(find.byType(ExcludeSemantics), findsAtLeastNWidgets(1));
  });

  testWidgets('decorative icon has no labelled Semantics node', (tester) async {
    await tester.pumpObers(const OiIcon.decorative(icon: testIcon));
    // Should have no Semantics node with a non-empty label from OiIcon
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

  // ── Size / color ──────────────────────────────────────────────────────────

  testWidgets('uses provided size', (tester) async {
    await tester.pumpObers(
      const OiIcon(icon: testIcon, label: 'big icon', size: 48),
    );
    final iconWidget = tester.widget<Icon>(find.byType(Icon));
    expect(iconWidget.size, 48);
  });

  testWidgets('defaults to body font size when size is null', (tester) async {
    final theme = OiThemeData.light();
    final bodySize = theme.textTheme.body.fontSize!;
    await tester.pumpObers(const OiIcon(icon: testIcon, label: 'default size'));
    final iconWidget = tester.widget<Icon>(find.byType(Icon));
    expect(iconWidget.size, bodySize);
  });

  testWidgets('uses provided color', (tester) async {
    await tester.pumpObers(
      const OiIcon(
        icon: testIcon,
        label: 'colored icon',
        color: Color(0xFFFF0000),
      ),
    );
    final iconWidget = tester.widget<Icon>(find.byType(Icon));
    expect(iconWidget.color, const Color(0xFFFF0000));
  });
}
