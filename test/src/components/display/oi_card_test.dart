// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

// Key used internally by OiCard for the footer separator.
const _kDividerKey = Key('_oi_card_divider');

void main() {
  // ---------------------------------------------------------------------------
  // REQ-0243 — Structure: child, header slots, footer with divider
  // ---------------------------------------------------------------------------

  group('REQ-0243 — structure', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpObers(const OiCard(child: Text('body content')));
      expect(find.text('body content'), findsOneWidget);
    });

    testWidgets('renders title in header when provided', (tester) async {
      await tester.pumpObers(
        const OiCard(title: Text('Card Title'), child: Text('body')),
      );
      expect(find.text('Card Title'), findsOneWidget);
    });

    testWidgets('renders subtitle in header when provided', (tester) async {
      await tester.pumpObers(
        const OiCard(
          title: Text('Title'),
          subtitle: Text('Subtitle'),
          child: Text('body'),
        ),
      );
      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('renders leading widget beside title', (tester) async {
      await tester.pumpObers(
        const OiCard(
          title: Text('Title'),
          leading: SizedBox(key: Key('leading'), width: 24, height: 24),
          child: Text('body'),
        ),
      );
      expect(find.byKey(const Key('leading')), findsOneWidget);
    });

    testWidgets('renders trailing widget beside title', (tester) async {
      await tester.pumpObers(
        const OiCard(
          title: Text('Title'),
          trailing: SizedBox(key: Key('trailing'), width: 24, height: 24),
          child: Text('body'),
        ),
      );
      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });

    testWidgets('renders footer below body with separator between', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiCard(footer: Text('footer content'), child: Text('body')),
      );
      expect(find.text('footer content'), findsOneWidget);
      expect(find.byKey(_kDividerKey), findsOneWidget);
    });

    testWidgets('no header row when title/subtitle/leading/trailing absent', (
      tester,
    ) async {
      await tester.pumpObers(const OiCard(child: Text('body')));
      expect(find.text('body'), findsOneWidget);
      // No Expanded or Row in the header.
      expect(find.byType(Expanded), findsNothing);
    });

    testWidgets('no separator when footer is absent', (tester) async {
      await tester.pumpObers(const OiCard(child: Text('body')));
      expect(find.byKey(_kDividerKey), findsNothing);
    });

    testWidgets(
      'footer renders with separator even when body is empty widget',
      (tester) async {
        await tester.pumpObers(
          const OiCard(footer: Text('footer only'), child: SizedBox.shrink()),
        );
        expect(find.text('footer only'), findsOneWidget);
        expect(find.byKey(_kDividerKey), findsOneWidget);
      },
    );

    testWidgets('padding parameter is forwarded to OiSurface', (tester) async {
      const customPadding = EdgeInsets.all(32);
      await tester.pumpObers(
        const OiCard(padding: customPadding, child: Text('body')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.padding, equals(customPadding));
    });

    testWidgets('gradient parameter is forwarded to OiSurface', (tester) async {
      final gradient = OiGradientStyle.linear(const [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ]);
      await tester.pumpObers(
        OiCard(gradient: gradient, child: const Text('body')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.gradient, equals(gradient));
    });

    testWidgets('halo parameter is forwarded to OiSurface', (tester) async {
      const halo = OiHaloStyle(color: Color(0x330000FF), blur: 12, spread: 4);
      await tester.pumpObers(const OiCard(halo: halo, child: Text('body')));
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.halo, equals(halo));
    });
  });

  // ---------------------------------------------------------------------------
  // REQ-0244 — onTap, label assert, collapsible, defaultCollapsed
  // ---------------------------------------------------------------------------

  group('REQ-0244 — tap and collapsible', () {
    testWidgets('onTap fires via OiTappable tap', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiCard(
          onTap: () => tapped = true,
          label: 'Tap me',
          child: const Text('content'),
        ),
      );
      await tester.tap(find.byType(OiTappable));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('label is set as semanticLabel on OiTappable', (tester) async {
      await tester.pumpObers(
        OiCard(onTap: () {}, label: 'My Card', child: const Text('content')),
      );
      final tappable = tester.widget<OiTappable>(find.byType(OiTappable));
      expect(tappable.semanticLabel, equals('My Card'));
    });

    testWidgets('assert triggers when onTap provided without label', (
      tester,
    ) async {
      expect(
        () => OiCard(onTap: () {}, child: const Text('content')),
        throwsAssertionError,
      );
    });

    testWidgets('collapsible=true shows chevron icon in header', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiCard(
          collapsible: true,
          title: Text('Title'),
          child: Text('body'),
        ),
      );
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('defaultCollapsed=true starts with body hidden', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiCard(
          collapsible: true,
          defaultCollapsed: true,
          title: Text('Title'),
          child: Text('body content'),
        ),
      );
      await tester.pump();
      final sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(0.0));
    });

    testWidgets('tapping chevron expands hidden body', (tester) async {
      await tester.pumpObers(
        const OiCard(
          collapsible: true,
          defaultCollapsed: true,
          title: Text('Title'),
          child: Text('body content'),
        ),
      );
      await tester.pump();

      var sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(0.0));

      await tester.tap(find.byType(Icon));
      await tester.pumpAndSettle();

      sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(1.0));
    });

    testWidgets('tapping chevron twice collapses expanded body', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiCard(
          collapsible: true,
          title: Text('Title'),
          child: Text('body content'),
        ),
      );
      await tester.pump();

      // Tap once to collapse.
      await tester.tap(find.byType(Icon));
      await tester.pumpAndSettle();

      var sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(0.0));

      // Tap again to expand.
      await tester.tap(find.byType(Icon));
      await tester.pumpAndSettle();

      sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(1.0));
    });

    testWidgets('collapsible=false shows no chevron', (tester) async {
      await tester.pumpObers(
        const OiCard(title: Text('Title'), child: Text('body')),
      );
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('collapsible=true without title still renders chevron', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiCard(collapsible: true, child: Text('body')),
      );
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets(
      'reducedMotion: collapsing completes instantly without animation',
      (tester) async {
        await tester.pumpObers(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: OiCard(
              collapsible: true,
              title: Text('Title'),
              child: Text('body content'),
            ),
          ),
        );
        await tester.pump();

        // Initially expanded — sizeFactor is 1.0.
        var sizeTransition = tester.widget<SizeTransition>(
          find.byType(SizeTransition),
        );
        expect(sizeTransition.sizeFactor.value, equals(1.0));

        // Tap chevron to collapse.
        await tester.tap(find.byType(Icon));
        await tester.pump();

        // With reducedMotion the controller snaps to 0.0 instantly.
        sizeTransition = tester.widget<SizeTransition>(
          find.byType(SizeTransition),
        );
        expect(sizeTransition.sizeFactor.value, equals(0.0));

        // Tap again to expand — should snap to 1.0.
        await tester.tap(find.byType(Icon));
        await tester.pump();

        sizeTransition = tester.widget<SizeTransition>(
          find.byType(SizeTransition),
        );
        expect(sizeTransition.sizeFactor.value, equals(1.0));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // REQ-0245 — factory constructors: flat, outlined, interactive, compact
  // ---------------------------------------------------------------------------

  group('REQ-0245 — factory constructors', () {
    testWidgets('OiCard.flat renders no BoxShadow', (tester) async {
      await tester.pumpObers(OiCard.flat(child: const Text('flat')));
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.shadow, isNull);
    });

    testWidgets('OiCard.outlined renders border with no shadow', (
      tester,
    ) async {
      await tester.pumpObers(OiCard.outlined(child: const Text('outlined')));
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.border, isNotNull);
      expect(surface.shadow, isNull);
    });

    testWidgets('OiCard.interactive wraps OiTappable even without onTap', (
      tester,
    ) async {
      await tester.pumpObers(
        OiCard.interactive(label: 'Card', child: const Text('interactive')),
      );
      expect(find.byType(OiTappable), findsOneWidget);
    });

    testWidgets('OiCard.interactive OiTappable is enabled with null onTap', (
      tester,
    ) async {
      await tester.pumpObers(
        OiCard.interactive(label: 'Card', child: const Text('interactive')),
      );
      final tappable = tester.widget<OiTappable>(find.byType(OiTappable));
      expect(tappable.enabled, isTrue);
      expect(tappable.onTap, isNull);
    });

    testWidgets('OiCard.compact uses EdgeInsets.all(8) padding', (
      tester,
    ) async {
      await tester.pumpObers(OiCard.compact(child: const Text('compact')));
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.padding, equals(const EdgeInsets.all(8)));
    });

    testWidgets('default elevated card uses EdgeInsets.all(16) padding', (
      tester,
    ) async {
      await tester.pumpObers(const OiCard(child: Text('elevated')));
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets(
      'explicit border overrides theme default for outlined variant',
      (tester) async {
        final customBorder = OiBorderStyle.solid(
          const Color(0xFFFF0000),
          2,
          borderRadius: BorderRadius.circular(4),
        );
        await tester.pumpObers(
          OiCard.outlined(border: customBorder, child: const Text('outlined')),
        );
        final surface = tester.widget<OiSurface>(find.byType(OiSurface));
        expect(surface.border, equals(customBorder));
      },
    );

    testWidgets('explicit gradient overrides null default', (tester) async {
      final gradient = OiGradientStyle.linear(const [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ]);
      await tester.pumpObers(
        OiCard.flat(gradient: gradient, child: const Text('flat')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.gradient, equals(gradient));
    });

    testWidgets('OiCard elevated variant has shadow', (tester) async {
      await tester.pumpObers(const OiCard(child: Text('elevated')));
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.shadow, isNotNull);
      expect(surface.shadow!.isNotEmpty, isTrue);
    });

    testWidgets('non-interactive card without onTap does not use OiTappable', (
      tester,
    ) async {
      await tester.pumpObers(const OiCard(child: Text('content')));
      expect(find.byType(OiTappable), findsNothing);
    });

    testWidgets('card with onTap uses OiTappable', (tester) async {
      await tester.pumpObers(
        OiCard(onTap: () {}, label: 'tap', child: const Text('content')),
      );
      expect(find.byType(OiTappable), findsOneWidget);
    });

    testWidgets(
      'OiCard.outlined uses theme defaultBorder when no explicit border set',
      (tester) async {
        await tester.pumpObers(OiCard.outlined(child: const Text('outlined')));
        final surface = tester.widget<OiSurface>(find.byType(OiSurface));
        expect(surface.border, isNotNull);
      },
    );

    testWidgets('halo is forwarded to OiSurface via OiCard.flat', (
      tester,
    ) async {
      const halo = OiHaloStyle(color: Color(0x330000FF), blur: 12, spread: 4);
      await tester.pumpObers(
        OiCard.flat(halo: halo, child: const Text('flat')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.halo, equals(halo));
    });

    testWidgets('halo is forwarded to OiSurface via OiCard.outlined', (
      tester,
    ) async {
      const halo = OiHaloStyle(color: Color(0x330000FF), blur: 12, spread: 4);
      await tester.pumpObers(
        OiCard.outlined(halo: halo, child: const Text('outlined')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.halo, equals(halo));
    });

    testWidgets('halo is forwarded to OiSurface via OiCard.interactive', (
      tester,
    ) async {
      const halo = OiHaloStyle(color: Color(0x330000FF), blur: 12, spread: 4);
      await tester.pumpObers(
        OiCard.interactive(
          label: 'Card',
          halo: halo,
          child: const Text('interactive'),
        ),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.halo, equals(halo));
    });

    testWidgets('halo is forwarded to OiSurface via OiCard.compact', (
      tester,
    ) async {
      const halo = OiHaloStyle(color: Color(0x330000FF), blur: 12, spread: 4);
      await tester.pumpObers(
        OiCard.compact(halo: halo, child: const Text('compact')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.halo, equals(halo));
    });
  });
}
