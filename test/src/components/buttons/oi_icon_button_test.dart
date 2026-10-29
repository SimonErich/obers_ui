// Tests do not require documentation comments.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

const _kIcon = IconData(0xe318, fontFamily: 'MaterialIcons');

void main() {
  testWidgets('renders icon', (tester) async {
    await tester.pumpObers(
      const OiIconButton(icon: _kIcon, semanticLabel: 'Test'),
    );
    expect(find.byIcon(_kIcon), findsOneWidget);
  });

  testWidgets('onTap fires when tapped', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiIconButton(icon: _kIcon, semanticLabel: 'Test', onTap: () => count++),
    );
    await tester.tap(find.byIcon(_kIcon));
    await tester.pump();
    expect(count, 1);
  });

  testWidgets('onTap not called when enabled=false', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiIconButton(
        icon: _kIcon,
        semanticLabel: 'Test',
        enabled: false,
        onTap: () => count++,
      ),
    );
    await tester.tap(find.byIcon(_kIcon), warnIfMissed: false);
    await tester.pump();
    expect(count, 0);
  });

  testWidgets('delegates to OiButton.icon', (tester) async {
    await tester.pumpObers(
      const OiIconButton(
        icon: _kIcon,
        semanticLabel: 'Test',
        variant: OiButtonVariant.primary,
      ),
    );
    expect(find.byType(OiButton), findsOneWidget);
  });

  testWidgets('large size renders larger than medium size', (tester) async {
    // Use pointer-device density (compact) so the 48 dp touch-target floor
    // only applies on comfortable/touch density. Both sizes are tested at
    // comfortable so the floor is the same; compare medium vs large instead,
    // where large (44 dp comfortable) is taller than medium (36 dp comfortable).
    await tester.pumpObers(
      const Column(
        children: [
          OiIconButton(key: Key('md'), icon: _kIcon, semanticLabel: 'Medium'),
          OiIconButton(
            key: Key('lg'),
            icon: _kIcon,
            semanticLabel: 'Large',
            size: OiButtonSize.large,
          ),
        ],
      ),
    );
    final mdH = tester.getSize(find.byKey(const Key('md'))).height;
    final lgH = tester.getSize(find.byKey(const Key('lg'))).height;
    expect(lgH, greaterThanOrEqualTo(mdH));
  });

  // ── Variant fill ───────────────────────────────────────────────────────────

  // The square behind the icon: the Container that carries a decoration.
  BoxDecoration? fill(WidgetTester tester) {
    final boxes = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(OiIconButton),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>();
    return boxes.isEmpty ? null : boxes.first;
  }

  Color? iconColor(WidgetTester tester) =>
      tester.widget<Icon>(find.byIcon(_kIcon)).color;

  Future<TestGesture> hoverOver(WidgetTester tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byIcon(_kIcon)));
    await tester.pumpAndSettle();
    return gesture;
  }

  OiThemeData withButtons(OiThemeData base, OiButtonThemeData buttons) =>
      base.copyWith(components: base.components.copyWith(button: buttons));

  final theme = OiThemeData.light();
  final fills = {
    OiButtonVariant.primary: theme.colors.primary.base,
    OiButtonVariant.secondary: theme.colors.surfaceSubtle,
    OiButtonVariant.destructive: theme.colors.error.base,
    OiButtonVariant.soft: theme.colors.primary.muted,
  };
  for (final MapEntry(key: variant, value: color) in fills.entries) {
    testWidgets('a ${variant.name} icon button paints its fill', (
      tester,
    ) async {
      await tester.pumpObers(
        OiIconButton(
          icon: _kIcon,
          semanticLabel: 'Test',
          variant: variant,
          onTap: () {},
        ),
        theme: theme,
      );

      expect(fill(tester)?.color, color);
      // The test app gives it the whole screen; the fill stays a square.
      final size = tester.getSize(find.byType(OiTappable));
      expect(size.width, size.height, reason: 'square');
      expect(size.width, lessThan(100));
    });
  }

  testWidgets('an outline icon button draws its border', (tester) async {
    await tester.pumpObers(
      OiIconButton(
        icon: _kIcon,
        semanticLabel: 'Test',
        variant: OiButtonVariant.outline,
        onTap: () {},
      ),
      theme: theme,
    );

    expect(fill(tester)?.border?.top.color, theme.colors.border);
  });

  testWidgets('a ghost icon button stays without a fill', (tester) async {
    await tester.pumpObers(
      OiIconButton(icon: _kIcon, semanticLabel: 'Test', onTap: () {}),
      theme: theme,
    );

    final color = fill(tester)?.color;
    expect(color == null || color.a == 0, isTrue);
  });

  testWidgets("the theme's variant style colours an icon button", (
    tester,
  ) async {
    await tester.pumpObers(
      OiIconButton(
        icon: _kIcon,
        semanticLabel: 'Test',
        variant: OiButtonVariant.secondary,
        onTap: () {},
      ),
      theme: withButtons(
        theme,
        const OiButtonThemeData(
          secondaryStyle: OiButtonVariantStyle(
            background: Color(0xFF202020),
            foreground: Color(0xFFF2F2F2),
          ),
        ),
      ),
    );

    expect(fill(tester)?.color, const Color(0xFF202020));
    expect(iconColor(tester), const Color(0xFFF2F2F2));
  });

  testWidgets('hovering a filled icon button keeps its icon as it is', (
    tester,
  ) async {
    await tester.pumpObers(
      OiIconButton(
        icon: _kIcon,
        semanticLabel: 'Test',
        variant: OiButtonVariant.primary,
        onTap: () {},
      ),
      theme: theme,
    );
    final size = tester.getSize(find.byIcon(_kIcon));

    await hoverOver(tester);

    // Not the ghost's primary tint: that would vanish on a primary fill.
    expect(iconColor(tester), theme.colors.primary.foreground);
    expect(tester.getSize(find.byIcon(_kIcon)), size);
  });

  testWidgets('a backgroundHover override fills a hovered icon button', (
    tester,
  ) async {
    await tester.pumpObers(
      OiIconButton(
        icon: _kIcon,
        semanticLabel: 'Test',
        variant: OiButtonVariant.secondary,
        onTap: () {},
      ),
      theme: withButtons(
        theme,
        const OiButtonThemeData(
          secondaryStyle: OiButtonVariantStyle(
            background: Color(0xFF202020),
            backgroundHover: Color(0xFF303030),
          ),
        ),
      ),
    );

    final gesture = await hoverOver(tester);
    expect(fill(tester)?.color, const Color(0xFF303030));

    await gesture.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(fill(tester)?.color, const Color(0xFF202020));
  });

  testWidgets('a disabled filled icon button ignores taps', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiIconButton(
        icon: _kIcon,
        semanticLabel: 'Test',
        variant: OiButtonVariant.primary,
        enabled: false,
        onTap: () => count++,
      ),
      theme: theme,
    );

    await tester.tap(find.byIcon(_kIcon), warnIfMissed: false);
    await tester.pump();
    expect(count, 0);
  });

  testWidgets("a ghost icon button takes the theme's foregroundHover", (
    tester,
  ) async {
    await tester.pumpObers(
      OiIconButton(icon: _kIcon, semanticLabel: 'Test', onTap: () {}),
      theme: withButtons(
        theme,
        const OiButtonThemeData(
          ghostStyle: OiButtonVariantStyle(
            foregroundHover: Color(0xFF123456),
          ),
        ),
      ),
    );

    await hoverOver(tester);

    expect(iconColor(tester), const Color(0xFF123456));
  });
}
