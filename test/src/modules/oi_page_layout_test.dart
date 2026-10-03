import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/modules/oi_page_layout.dart';

import '../../helpers/pump_app.dart';

void main() {
  test(
    'prepending the containing heading preserves every page region and policy',
    () {
      const child = Text('Form');
      const heading = Text('Record');
      const header = Text('Notice');
      const navigation = Text('Overview');
      const aside = Text('Customer');
      const asideFooter = Text('Support');
      const footer = Text('Save changes');
      const key = ValueKey('form page');
      const original = OiPageLayout(
        key: key,
        header: header,
        navigation: navigation,
        aside: aside,
        asideFooter: asideFooter,
        footer: footer,
        asideWidth: 310,
        asideFraction: .3,
        asideLabel: 'Order customer',
        padding: EdgeInsets.all(7),
        gap: 13,
        footerGap: 5,
        scrollable: true,
        scrollHeaderWhenCompact: true,
        child: child,
      );
      final composed = original.prependHeader(heading, headingGap: 19);
      expect(composed.key, key);
      expect(composed.child, same(child));
      expect(composed.navigation, same(navigation));
      expect(composed.aside, same(aside));
      expect(composed.asideFooter, same(asideFooter));
      expect(composed.footer, same(footer));
      expect(composed.asideWidth, 310);
      expect(composed.asideFraction, .3);
      expect(composed.asideLabel, 'Order customer');
      expect(composed.padding, const EdgeInsets.all(7));
      expect(composed.gap, 13);
      expect(composed.footerGap, 5);
      expect(composed.scrollable, isTrue);
      expect(composed.scrollHeaderWhenCompact, isTrue);
      expect(composed.collapseBreakpoint, OiBreakpoint.expanded);
      final children = (composed.header! as Column).children;
      expect(children.first, same(heading));
      expect((children[1] as SizedBox).height, 19);
      expect(children.last, same(header));
      expect(
        const OiPageLayout(
          child: child,
        ).prependHeader(heading, headingGap: 19).header,
        same(heading),
      );
    },
  );
  testWidgets(
    'compact stacked heading scrolls while error actions stay pinned',
    (tester) async {
      final controller = TextEditingController(text: 'Incomplete phone');
      final focus = FocusNode();
      final editorKey = GlobalKey();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      await tester.pumpObers(
        Column(
          children: [
            const SizedBox(height: 64, child: Text('Workspace toolbar')),
            LayoutBuilder(
              builder: (_, constraints) => SizedBox(
                height: constraints.maxWidth < 600 ? 200 : 84,
                child: const Text('Record heading and commands'),
              ),
            ),
            Expanded(
              child: OiPageLayout(
                scrollable: true,
                scrollHeaderWhenCompact: true,
                header: Column(
                  children: [
                    const SizedBox(height: 128, child: Text('Change notice')),
                    for (var i = 0; i < 5; i++)
                      SizedBox(height: 96, child: Text('Metric $i')),
                  ],
                ),
                navigation: const SizedBox(height: 44, child: Text('Overview')),
                footer: OiButton.primary(
                  label: 'Reveal phone error',
                  onTap: () async {
                    await Scrollable.ensureVisible(
                      editorKey.currentContext!,
                      alignment: .15,
                    );
                    focus.requestFocus();
                  },
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 900,
                      child: Text('Earlier form content'),
                    ),
                    SizedBox(
                      key: editorKey,
                      height: 100,
                      child: EditableText(
                        controller: controller,
                        focusNode: focus,
                        style: const TextStyle(fontSize: 14),
                        cursorColor: const Color(0xff000000),
                        backgroundCursorColor: const Color(0xffffffff),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        surfaceSize: const Size(1440, 1720),
      );
      await tester.pumpAndSettle();
      for (final size in [const Size(375, 812), const Size(812, 375)]) {
        await tester.binding.setSurfaceSize(size);
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        final action = find.widgetWithText(OiButton, 'Reveal phone error');
        expect(tester.getRect(action).bottom, lessThanOrEqualTo(size.height));
        await tester.tap(action);
        await tester.pumpAndSettle();
        final editor = tester.getRect(find.byKey(editorKey));
        expect(editor.top, greaterThanOrEqualTo(size.width < 600 ? 264 : 148));
        expect(editor.bottom, lessThan(tester.getRect(action).top));
        expect(focus.hasFocus, isTrue);
        expect(controller.text, 'Incomplete phone');
        expect(tester.takeException(), isNull);
      }
    },
  );
}
