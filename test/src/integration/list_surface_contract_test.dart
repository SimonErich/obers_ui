import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('solid facet outlines preserve requested height in both states', (
    tester,
  ) async {
    for (final selected in [false, true]) {
      await tester.pumpObers(
        Center(
          child: OiFilterChip(
            key: const Key('facet'),
            label: '11:30–12:00',
            dashed: false,
            showCheckmark: false,
            showAddIcon: false,
            selected: selected,
            onTap: () {},
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('facet'))).height, 32);
    }
  });

  testWidgets(
    'overflow honors menu geometry and preserves distinct action roles',
    (tester) async {
      var invoked = false;
      final theme = OiThemeData.light().copyWith(
        components: const OiComponentThemes(
          actionBar: OiActionBarThemeData(
            menuMinWidth: 232,
            menuPadding: EdgeInsets.all(4),
            menuItemPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            menuIconGap: 10,
            menuRadius: BorderRadius.all(Radius.circular(10)),
            menuItemRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
      await tester.pumpObers(
        Center(
          child: OiActionBar(
            label: 'Record actions',
            actions: const [],
            separator: true,
            overflowActions: [
              OiActionBarItem(
                icon: OiIcons.eye,
                label: 'View order',
                semanticLabel: 'View order',
                onTap: () => invoked = true,
              ),
              OiActionBarItem(
                icon: OiIcons.circleX,
                label: 'Cancel order',
                semanticLabel: 'Cancel order',
                variant: OiButtonVariant.destructive,
                group: 'danger',
                onTap: () {},
              ),
            ],
          ),
        ),
        theme: theme,
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(1, 1));
      await tester.pump();
      await mouse.moveTo(
        tester.getCenter(find.bySemanticsLabel('More actions')),
      );
      await mouse.down(tester.getCenter(find.bySemanticsLabel('More actions')));
      await mouse.up();
      await tester.pumpAndSettle();
      final popover = tester.widget<OiPopover>(find.byType(OiPopover));
      expect(popover.borderRadius, BorderRadius.circular(10));
      final view = find.byWidgetPredicate(
        (w) => w is OiTappable && w.semanticLabel == 'View order',
      );
      expect(tester.getSize(view).width, greaterThanOrEqualTo(224));
      expect(
        tester.getSize(view).height,
        tester.getSize(find.text('View order')).height + 16,
      );
      expect(
        tester.widget<OiTappable>(view).clipBorderRadius,
        BorderRadius.circular(8),
      );
      final icon = tester.widget<OiIcon>(
        find.descendant(of: view, matching: find.byType(OiIcon)),
      );
      expect(icon.color, theme.colors.textMuted);
      await mouse.moveTo(tester.getCenter(view));
      await mouse.down(tester.getCenter(view));
      await mouse.up();
      await tester.pumpAndSettle();
      expect(invoked, isTrue);
      expect(find.text('Cancel order'), findsNothing);
    },
  );

  testWidgets('selected rows combine rounded surfaces and the row divider', (
    tester,
  ) async {
    final controller = OiTableController()..toggleRow('one');
    addTearDown(controller.dispose);
    final theme = OiThemeData.light().copyWith(
      components: const OiComponentThemes(
        table: OiTableThemeData(
          rowBorderRadius: BorderRadius.all(Radius.circular(4)),
          borderColor: Color(0xFFcccccc),
        ),
      ),
    );
    await tester.pumpObers(
      SizedBox(
        width: 600,
        height: 240,
        child: OiTable<String>(
          label: 'Records',
          controller: controller,
          selectable: true,
          rows: const ['one'],
          rowKey: (row) => row,
          columns: [
            OiTableColumn(
              id: 'title',
              header: 'Title',
              valueGetter: (row) => row,
            ),
          ],
        ),
      ),
      theme: theme,
    );
    await tester.pumpAndSettle();
    final surfaces = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
    expect(
      surfaces.any(
        (surface) =>
            surface.decoration is BoxDecoration &&
            (surface.decoration as BoxDecoration).borderRadius ==
                BorderRadius.circular(4) &&
            (surface.decoration as BoxDecoration).border != null,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
