// Tests do not require documentation comments.

import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

const _segments = [
  OiSegment<String>(value: 'day', label: 'Day'),
  OiSegment<String>(value: 'week', label: 'Week'),
  OiSegment<String>(value: 'month', label: 'Month'),
];

void main() {
  testWidgets(
    'selected elevation follows the selected segment without changing its bounds',
    (
      tester,
    ) async {
      const shadow = [BoxShadow(blurRadius: 2)];
      final base = OiThemeData.light();
      await tester.pumpObers(
        Center(
          child: OiThemeScope(
            data: base.copyWith(
              components: base.components.copyWith(
                segmentedControl: const OiSegmentedControlThemeData(
                  height: 52,
                  inset: 4,
                  selectedShadow: shadow,
                ),
              ),
            ),
            child: OiSegmentedControl<String>(
              segments: _segments,
              selected: 'week',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      final elevated = find.byWidgetPredicate(
        (w) =>
            w is AnimatedContainer &&
            (w.decoration as BoxDecoration?)?.boxShadow != null,
      );
      expect(elevated, findsOneWidget);
      expect(tester.getSize(elevated).height, 44);
      expect(
        find.descendant(of: elevated, matching: find.text('Week')),
        findsOneWidget,
      );
    },
  );
  testWidgets('custom subtitle typography fits a compact themed control', (
    tester,
  ) async {
    await tester.pumpObers(
      OiThemeScope(
        data: OiThemeData.light().copyWith(
          components: const OiComponentThemes(
            segmentedControl: OiSegmentedControlThemeData(
              height: 56,
              inset: 4,
              labelStyle: TextStyle(fontSize: 15, height: 1),
              subtitleStyle: TextStyle(fontSize: 12, height: 1),
              subtitleGap: 2,
            ),
          ),
        ),
        child: Center(
          child: OiSegmentedControl<int>(
            segments: const [
              OiSegment(value: 1, label: 'Short', subtitle: '0:20'),
              OiSegment(value: 2, label: 'Long', subtitle: '1:00'),
            ],
            selected: 1,
            onChanged: (_) {},
            semanticLabel: 'Length',
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(OiSegmentedControl<int>)).height, 56);
    expect(tester.widget<Text>(find.text('Short')).style?.fontSize, 15);
    expect(tester.widget<Text>(find.text('0:20')).style?.fontSize, 12);
  });

  testWidgets(
    'duration subtitles render and participate in the accessible name',
    (tester) async {
      final semantics = tester.ensureSemantics();
      String? selected;
      await tester.pumpObers(
        OiSegmentedControl<String>(
          segments: const [
            OiSegment(value: 'short', label: 'Short', subtitle: '~ 0:20'),
            OiSegment(value: 'long', label: 'Long', subtitle: '~ 1:00'),
          ],
          selected: 'short',
          onChanged: (value) => selected = value,
          semanticLabel: 'Length',
        ),
      );
      expect(find.text('~ 0:20'), findsOneWidget);
      expect(find.text('~ 1:00'), findsOneWidget);
      expect(find.bySemanticsLabel('Long, ~ 1:00'), findsOneWidget);
      await tester.tap(find.text('Long'));
      expect(selected, 'long');
      semantics.dispose();
    },
  );
  testWidgets(
    'label typography and gaps preserve geometry when selection changes',
    (tester) async {
      final base = OiThemeData.light();
      final theme = base.copyWith(
        components: base.components.copyWith(
          segmentedControl: const OiSegmentedControlThemeData(
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            spacing: 2,
          ),
        ),
      );
      Future<void> mount(String selected) => tester.pumpObers(
        Center(
          child: OiSegmentedControl<String>(
            segments: _segments,
            selected: selected,
            onChanged: (_) {},
          ),
        ),
        theme: theme,
      );
      await mount('day');
      Finder container(String label) => find
          .ancestor(
            of: find.text(label),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      final day = tester.getRect(container('Day'));
      final week = tester.getRect(container('Week'));
      expect(week.left - day.right, 2);
      await mount('week');
      expect(tester.getRect(container('Day')), day);
      expect(tester.getRect(container('Week')), week);
      expect(
        tester.widget<Text>(find.text('Week')).style!.fontWeight,
        FontWeight.w500,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'icon-only segments retain names, selection and square geometry',
    (
      tester,
    ) async {
      var selected = false;
      await tester.pumpObers(
        Center(
          child: OiSegmentedControl<bool>(
            showLabels: false,
            size: OiSegmentedControlSize.small,
            segments: const [
              OiSegment(
                value: false,
                label: 'Chart view',
                icon: OiIcons.chartColumn,
              ),
              OiSegment(value: true, label: 'Table view', icon: OiIcons.table),
            ],
            selected: selected,
            onChanged: (value) => selected = value,
          ),
        ),
      );
      expect(find.text('Chart view'), findsNothing);
      expect(find.bySemanticsLabel('Chart view'), findsOneWidget);
      final chartButton = tester.getSemantics(
        find.bySemanticsLabel('Chart view'),
      );
      final tableButton = tester.getSemantics(
        find.bySemanticsLabel('Table view'),
      );
      expect(chartButton.flagsCollection.isButton, isTrue);
      expect(chartButton.flagsCollection.isSelected, Tristate.isTrue);
      expect(tableButton.flagsCollection.isButton, isTrue);
      expect(tableButton.flagsCollection.isSelected, Tristate.isFalse);
      final group = tester.getSize(find.byType(OiSegmentedControl<bool>));
      expect(group.width, group.height * 2);
      await tester.tap(find.bySemanticsLabel('Table view'));
      await tester.pump();
      expect(selected, isTrue);
    },
  );

  testWidgets('each labeled segment exposes one named button with live state', (
    tester,
  ) async {
    var selected = 'day';
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) => OiSegmentedControl<String>(
          semanticLabel: 'Time range',
          segments: const [
            OiSegment(value: 'day', label: 'Day', semanticLabel: 'Daily range'),
            OiSegment(value: 'week', label: 'Week'),
            OiSegment(value: 'month', label: 'Month', enabled: false),
          ],
          selected: selected,
          onChanged: (value) => setState(() => selected = value),
        ),
      ),
    );

    List<SemanticsNode> accessibleButtons() => tester.semantics
        .simulatedAccessibilityTraversal()
        .where((node) => node.flagsCollection.isButton)
        .toList();

    final buttons = accessibleButtons();
    expect(buttons.map((node) => node.label), ['Daily range', 'Week', 'Month']);
    expect(buttons.first.flagsCollection.isSelected, Tristate.isTrue);
    expect(buttons.last.flagsCollection.isEnabled, Tristate.isFalse);
    expect(
      buttons.last.getSemanticsData().hasAction(SemanticsAction.tap),
      isFalse,
    );

    await tester.tap(find.text('Week'));
    await tester.pump();
    final updated = accessibleButtons();
    expect(updated, hasLength(3));
    expect(updated[0].flagsCollection.isSelected, Tristate.isFalse);
    expect(updated[1].flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('renders all segment labels', (tester) async {
    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: _segments,
        selected: 'day',
        onChanged: (_) {},
      ),
    );

    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
  });

  testWidgets('selected segment uses bold font weight', (tester) async {
    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: _segments,
        selected: 'week',
        onChanged: (_) {},
      ),
    );

    final selectedText = tester.widget<Text>(find.text('Week'));
    final unselectedText = tester.widget<Text>(find.text('Day'));

    expect(selectedText.style?.fontWeight, FontWeight.w600);
    expect(unselectedText.style?.fontWeight, FontWeight.w400);
  });

  testWidgets('tapping segment fires onChanged', (tester) async {
    String? result;
    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: _segments,
        selected: 'day',
        onChanged: (v) => result = v,
      ),
    );

    await tester.tap(find.text('Month'));
    await tester.pump();

    expect(result, 'month');
  });

  testWidgets('disabled segment cannot be tapped', (tester) async {
    String? result;
    final segmentsWithDisabled = [
      const OiSegment<String>(value: 'day', label: 'Day'),
      const OiSegment<String>(value: 'week', label: 'Week', enabled: false),
      const OiSegment<String>(value: 'month', label: 'Month'),
    ];

    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: segmentsWithDisabled,
        selected: 'day',
        onChanged: (v) => result = v,
      ),
    );

    await tester.tap(find.text('Week'), warnIfMissed: false);
    await tester.pump();

    expect(result, isNull);
  });

  testWidgets('expand mode fills available width', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        child: OiSegmentedControl<String>(
          segments: _segments,
          selected: 'day',
          onChanged: (_) {},
          expand: true,
        ),
      ),
    );

    // When expand is true the Row uses MainAxisSize.max.
    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.mainAxisSize, MainAxisSize.max);
  });

  testWidgets('arrow keys change selected segment after click focus', (
    tester,
  ) async {
    var selected = 'day';
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) {
          return OiSegmentedControl<String>(
            segments: _segments,
            selected: selected,
            onChanged: (v) => setState(() => selected = v),
          );
        },
      ),
    );

    await tester.tap(find.text('Day'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(selected, 'week');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(selected, 'month');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(selected, 'week');
  });

  testWidgets('empty segments renders nothing instead of throwing', (
    tester,
  ) async {
    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: const [],
        selected: 'day',
        onChanged: (_) {},
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(OiSegment<String>), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('single segment renders as a standalone pill', (tester) async {
    String? result;
    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: const [OiSegment<String>(value: 'day', label: 'Day')],
        selected: 'day',
        onChanged: (v) => result = v,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Day'), findsOneWidget);

    // Tapping the already-selected single segment does not fire onChanged.
    await tester.tap(find.text('Day'));
    await tester.pump();
    expect(result, isNull);
  });
}
