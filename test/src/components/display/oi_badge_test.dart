// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'counter and token sizes stay independent of status pill tokens',
    (tester) async {
      final base = OiThemeData.light();
      await tester.pumpObers(
        const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OiBadge.counter(label: '5'),
              OiBadge.counter(label: '999'),
              OiBadge.token(label: 'A'),
              OiBadge.soft(label: 'Confirmed'),
            ],
          ),
        ),
        theme: base.copyWith(
          components: base.components.copyWith(
            badge: const OiBadgeThemeData(
              height: 24,
              counter: OiBadgeMetrics(
                height: 18,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              token: OiBadgeMetrics(height: 20),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(OiBadge).at(0)).height, 18);
      expect(
        tester.getSize(find.byType(OiBadge).at(0)).width,
        greaterThanOrEqualTo(18),
      );
      expect(tester.getSize(find.byType(OiBadge).at(1)).height, 18);
      expect(tester.getSize(find.byType(OiBadge).at(1)).width, greaterThan(18));
      expect(tester.getSize(find.byType(OiBadge).at(2)).height, 20);
      expect(tester.getSize(find.byType(OiBadge).at(3)).height, 24);
      expect(find.bySemanticsLabel('5'), findsOneWidget);
    },
  );

  testWidgets(
    'soft badges honor semantic swatches and stay content-sized at fixed height',
    (tester) async {
      final base = OiThemeData.light();
      const background = Color(0xffeeeaff);
      const foreground = Color(0xff432177);
      await tester.pumpObers(
        const Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [OiBadge.soft(label: 'Confirmed')],
            ),
          ),
        ),
        theme: base.copyWith(
          colors: base.colors.copyWith(
            primary: base.colors.primary.copyWith(
              muted: background,
              dark: foreground,
            ),
          ),
          components: base.components.copyWith(
            badge: const OiBadgeThemeData(height: 24, useSwatchColors: true),
          ),
        ),
      );
      final badge = find.byType(OiBadge);
      expect(tester.getSize(badge).width, lessThan(200));
      expect(tester.getSize(badge).height, 24);
      final container = tester.widget<Container>(
        find.descendant(of: badge, matching: find.byType(Container)).first,
      );
      expect((container.decoration! as BoxDecoration).color, background);
      expect(
        tester.widget<Text>(find.text('Confirmed')).style?.color,
        foreground,
      );
    },
  );

  for (final style in OiBadgeStyle.values) {
    testWidgets('labelled marker retains one accessible label ($style)', (
      tester,
    ) async {
      final badge = switch (style) {
        OiBadgeStyle.filled => const OiBadge.filled(
          label: 'Confirmed',
          showDot: true,
        ),
        OiBadgeStyle.soft => const OiBadge.soft(
          label: 'Confirmed',
          showDot: true,
        ),
        OiBadgeStyle.outline => const OiBadge.outline(
          label: 'Confirmed',
          showDot: true,
        ),
      };
      await tester.pumpObers(Center(child: badge));
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.bySemanticsLabel('Confirmed'), findsOneWidget);
      final marker = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
      );
      expect(marker, findsOneWidget);
      expect(tester.getSize(marker), const Size(6, 6));
      final markerColor =
          (tester.widget<Container>(marker).decoration! as BoxDecoration).color;
      expect(
        markerColor,
        tester.widget<Text>(find.text('Confirmed')).style?.color,
      );
      expect(
        find.ancestor(of: marker, matching: find.byType(ExcludeSemantics)),
        findsOneWidget,
      );
    });
  }

  // ── Factory constructor style assignment ──────────────────────────────────

  group('factory constructors produce the correct OiBadgeStyle', () {
    testWidgets('OiBadge.filled sets style to filled', (tester) async {
      await tester.pumpObers(const OiBadge.filled(label: 'Tag'));
      final badge = tester.widget<OiBadge>(find.byType(OiBadge));
      expect(badge.style, OiBadgeStyle.filled);
    });

    testWidgets('OiBadge.soft sets style to soft', (tester) async {
      await tester.pumpObers(const OiBadge.soft(label: 'Tag'));
      final badge = tester.widget<OiBadge>(find.byType(OiBadge));
      expect(badge.style, OiBadgeStyle.soft);
    });

    testWidgets('OiBadge.outline sets style to outline', (tester) async {
      await tester.pumpObers(const OiBadge.outline(label: 'Tag'));
      final badge = tester.widget<OiBadge>(find.byType(OiBadge));
      expect(badge.style, OiBadgeStyle.outline);
    });
  });

  // ── Rendering ─────────────────────────────────────────────────────────────

  testWidgets('renders label text', (tester) async {
    await tester.pumpObers(const OiBadge.filled(label: 'New'));
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('dot mode renders no text', (tester) async {
    await tester.pumpObers(const OiBadge.filled(label: 'ignored', dot: true));
    expect(find.text('ignored'), findsNothing);
  });

  testWidgets('dot mode exposes label as semantic text indicator', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiBadge.filled(
        label: 'Error status',
        color: OiBadgeColor.error,
        dot: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Error status')),
      isNotNull,
    );
  });

  testWidgets('renders with success color', (tester) async {
    await tester.pumpObers(
      const OiBadge.filled(label: 'OK', color: OiBadgeColor.success),
    );
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('renders with error color', (tester) async {
    await tester.pumpObers(
      const OiBadge.filled(label: 'Error', color: OiBadgeColor.error),
    );
    expect(find.text('Error'), findsOneWidget);
  });

  testWidgets('renders small size', (tester) async {
    await tester.pumpObers(
      const OiBadge.filled(label: 'sm', size: OiBadgeSize.small),
    );
    expect(find.text('sm'), findsOneWidget);
  });

  testWidgets('renders large size', (tester) async {
    await tester.pumpObers(
      const OiBadge.filled(label: 'lg', size: OiBadgeSize.large),
    );
    expect(find.text('lg'), findsOneWidget);
  });

  testWidgets('renders soft style', (tester) async {
    await tester.pumpObers(const OiBadge.soft(label: 'soft'));
    expect(find.text('soft'), findsOneWidget);
  });

  testWidgets('renders outline style', (tester) async {
    await tester.pumpObers(const OiBadge.outline(label: 'out'));
    expect(find.text('out'), findsOneWidget);
  });

  testWidgets('renders with icon', (tester) async {
    const icon = IconData(0xe318, fontFamily: 'MaterialIcons');
    await tester.pumpObers(
      const OiBadge.filled(label: 'with icon', icon: icon),
    );
    expect(find.text('with icon'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
  });

  // REQ-0025: color is never the sole indicator — dot mode includes an icon
  // for semantic badge colors.

  testWidgets('REQ-0025: dot mode with error color renders an Icon', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiBadge.filled(label: 'err', color: OiBadgeColor.error, dot: true),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('REQ-0025: dot mode with success color renders an Icon', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiBadge.filled(label: 'ok', color: OiBadgeColor.success, dot: true),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('REQ-0025: dot mode with warning color renders an Icon', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiBadge.filled(
        label: 'warn',
        color: OiBadgeColor.warning,
        dot: true,
      ),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('REQ-0025: dot mode with info color renders an Icon', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiBadge.filled(label: 'info', color: OiBadgeColor.info, dot: true),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('REQ-0025: dot mode with primary color renders no Icon', (
    tester,
  ) async {
    await tester.pumpObers(const OiBadge.filled(label: 'tag', dot: true));
    expect(find.byType(Icon), findsNothing);
  });
}
