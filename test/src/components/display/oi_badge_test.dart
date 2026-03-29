// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';

import '../../../helpers/pump_app.dart';

void main() {
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
