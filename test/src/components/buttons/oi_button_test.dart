// Tests do not require documentation comments.
// REQ-0014: Required props enforce correctness — buttons require label.
// REQ-0019: OiButton accessibility enforcement tests.

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/animation/oi_pulse.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

import '../../../helpers/pump_app.dart';

const _kIcon = IconData(0xe318, fontFamily: 'MaterialIcons');

void main() {
  testWidgets(
    'regular icon insets follow icon side and leave small controls unchanged',
    (tester) async {
      final base = OiThemeData.light();
      const ordinary = EdgeInsets.symmetric(horizontal: 12);
      const iconInsets = EdgeInsetsDirectional.fromSTEB(12, 0, 14, 0);
      const theme = OiButtonThemeData(
        padding: ordinary,
        iconLabelPadding: iconInsets,
      );
      expect(theme.copyWith(), theme);
      expect(theme.copyWith().hashCode, theme.hashCode);
      expect(theme, isNot(const OiButtonThemeData(padding: ordinary)));
      await tester.pumpObers(
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final size in [OiButtonSize.small, OiButtonSize.medium])
                for (final position in OiIconPosition.values)
                  OiButton.secondary(
                    key: ValueKey((size, position)),
                    label: 'Action',
                    icon: _kIcon,
                    size: size,
                    iconPosition: position,
                    onTap: () {},
                  ),
              OiButton.secondary(
                key: const ValueKey('plain'),
                label: 'Plain',
                onTap: () {},
              ),
            ],
          ),
        ),
        theme: base.copyWith(
          components: base.components.copyWith(button: theme),
        ),
      );
      for (final size in [OiButtonSize.small, OiButtonSize.medium]) {
        for (final position in OiIconPosition.values) {
          final containers = tester.widgetList<Container>(
            find.descendant(
              of: find.byKey(ValueKey((size, position))),
              matching: find.byType(Container),
            ),
          );
          final expected = size == OiButtonSize.small
              ? ordinary
              : position == OiIconPosition.leading
              ? iconInsets
              : const EdgeInsetsDirectional.fromSTEB(14, 0, 12, 0);
          expect(
            containers.any((container) => container.padding == expected),
            isTrue,
          );
        }
      }
      final plain = tester.widgetList<Container>(
        find.descendant(
          of: find.byKey(const ValueKey('plain')),
          matching: find.byType(Container),
        ),
      );
      expect(plain.any((container) => container.padding == ordinary), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  test('small icon gap participates in theme copying and equality', () {
    const original = OiButtonThemeData(iconGap: 8, smallIconGap: 6);
    expect(original.copyWith(), original);
    expect(original.copyWith().hashCode, original.hashCode);
    expect(
      original.copyWith(smallIconGap: 4),
      const OiButtonThemeData(iconGap: 8, smallIconGap: 4),
    );
    expect(original, isNot(const OiButtonThemeData(iconGap: 8)));
  });
  testWidgets(
    'small icon gap overrides only small buttons and preserves fallback',
    (tester) async {
      final base = OiThemeData.light();
      Future<Map<OiButtonSize, double>> widths(OiButtonThemeData theme) async {
        await tester.pumpObers(
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final size in OiButtonSize.values)
                  OiButton.secondary(
                    key: ValueKey(size),
                    label: 'Action',
                    icon: _kIcon,
                    size: size,
                    onTap: () {},
                  ),
              ],
            ),
          ),
          theme: base.copyWith(
            components: base.components.copyWith(button: theme),
          ),
        );
        return {
          for (final size in OiButtonSize.values)
            size: tester.getSize(find.byKey(ValueKey(size))).width,
        };
      }

      final global = await widths(const OiButtonThemeData(iconGap: 8));
      final sized = await widths(
        const OiButtonThemeData(iconGap: 8, smallIconGap: 6),
      );
      expect(
        sized[OiButtonSize.small],
        closeTo(global[OiButtonSize.small]! - 2, .01),
      );
      expect(sized[OiButtonSize.medium], global[OiButtonSize.medium]);
      expect(sized[OiButtonSize.large], global[OiButtonSize.large]);
      final defaultGap = await widths(const OiButtonThemeData());
      final explicitDefault = await widths(
        OiButtonThemeData(iconGap: base.spacing.xs),
      );
      expect(defaultGap, explicitDefault);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('theme hover and pressed colors preserve ghost text geometry', (
    tester,
  ) async {
    final base = OiThemeData.light();
    const normal = Color(0xff333333);
    const hovered = Color(0xff444444);
    const pressed = Color(0xff555555);
    await tester.pumpObers(
      Center(
        child: OiButton.ghost(label: 'Stable action', onTap: () {}),
      ),
      theme: base.copyWith(
        components: base.components.copyWith(
          button: const OiButtonThemeData(
            ghostStyle: OiButtonVariantStyle(
              background: normal,
              backgroundHover: hovered,
              backgroundPressed: pressed,
              foreground: Color(0xffffffff),
            ),
          ),
        ),
      ),
    );
    final button = find.byType(OiButton);
    final bounds = tester.getRect(button);
    final textStyle = tester.widget<Text>(find.text('Stable action')).style!;
    Color? background() =>
        (tester
                    .widgetList<Container>(
                      find.descendant(
                        of: button,
                        matching: find.byType(Container),
                      ),
                    )
                    .firstWhere(
                      (container) => container.decoration is BoxDecoration,
                    )
                    .decoration!
                as BoxDecoration)
            .color;
    expect(background(), normal);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(bounds.center);
    await tester.pumpAndSettle();
    expect(background(), hovered);
    expect(tester.getRect(button), bounds);
    expect(
      tester.widget<Text>(find.text('Stable action')).style!.fontWeight,
      textStyle.fontWeight,
    );
    await mouse.down(bounds.center);
    await tester.pump(const Duration(milliseconds: 120));
    expect(background(), pressed);
    expect(tester.getRect(button), bounds);
    await mouse.up();
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(background(), normal);
    expect(tester.takeException(), isNull);
    await mouse.removePointer();
  });

  testWidgets(
    'theme padding reaches the rendered standard and compact buttons',
    (tester) async {
      final base = OiThemeData.light();
      const padding = EdgeInsets.fromLTRB(12, 0, 14, 0);
      await tester.pumpObers(
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OiButton.primary(label: 'Primary', onTap: () {}),
              OiButton.ghost(
                label: 'Compact',
                size: OiButtonSize.small,
                onTap: () {},
              ),
            ],
          ),
        ),
        theme: base.copyWith(
          components: base.components.copyWith(
            button: const OiButtonThemeData(padding: padding),
          ),
        ),
      );
      for (final label in ['Primary', 'Compact']) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byType(OiButton),
        );
        final containers = tester.widgetList<Container>(
          find.descendant(of: button, matching: find.byType(Container)),
        );
        expect(
          containers.any((container) => container.padding == padding),
          isTrue,
        );
      }
    },
  );

  testWidgets('matching tooltip does not repeat a button accessible name', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(
      OiButton.outline(
        label: 'Confirm',
        semanticLabel: 'Confirm with kitchen',
        tooltip: 'Confirm with kitchen',
        onTap: () {},
      ),
    );
    expect(find.bySemanticsLabel('Confirm with kitchen'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Confirm with kitchen\nConfirm with kitchen'),
      findsNothing,
    );
    expect(find.byType(OiTooltip), findsOneWidget);
    handle.dispose();
  });

  testWidgets('compact icon geometry survives touch and keyboard input', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpObers(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 40,
          child: Row(
            children: [
              OiButton.icon(
                label: 'Row actions',
                icon: _kIcon,
                size: OiButtonSize.small,
                onTap: () => taps++,
              ),
            ],
          ),
        ),
      ),
    );
    final button = find.byType(OiButton);
    final initial = tester.getSize(button);
    expect(initial.width, lessThanOrEqualTo(40));
    expect(initial.width, initial.height);
    await tester.tap(button);
    await tester.pump();
    expect(taps, 1);
    expect(tester.getSize(button), initial);
    expect(tester.takeException(), isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 2);
    expect(tester.getSize(button), initial);
    expect(tester.takeException(), isNull);
  });

  for (final icon in [false, true]) {
    testWidgets(
      '${icon ? 'icon' : 'ghost'} button supports keyboard activation and a single name',
      (tester) async {
        final handle = tester.ensureSemantics();
        var taps = 0;
        final button = icon
            ? OiButton.icon(
                label: 'Open options',
                icon: _kIcon,
                onTap: () => taps++,
              )
            : OiButton.ghost(label: 'Open options', onTap: () => taps++);
        await tester.pumpObers(button);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(taps, 1);
        expect(find.bySemanticsLabel('Open options'), findsOneWidget);
        handle.dispose();
      },
    );
  }

  testWidgets('a button announces its explicit label once while loading', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(
      const OiButton.primary(label: 'Save', semanticLabel: 'Save order'),
    );
    expect(find.bySemanticsLabel('Save order'), findsOneWidget);
    expect(find.bySemanticsLabel('Save order\nSave'), findsNothing);
    await tester.pumpObers(
      const OiButton.primary(
        label: 'Save',
        semanticLabel: 'Save order',
        loading: true,
      ),
    );
    expect(find.bySemanticsLabel('Save order'), findsOneWidget);
    handle.dispose();
  });

  // ── Variant rendering ──────────────────────────────────────────────────────

  testWidgets('primary variant renders label', (tester) async {
    await tester.pumpObers(const OiButton.primary(label: 'Save'));
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('secondary variant renders label', (tester) async {
    await tester.pumpObers(const OiButton.secondary(label: 'Cancel'));
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('outline variant renders label', (tester) async {
    await tester.pumpObers(const OiButton.outline(label: 'Outline'));
    expect(find.text('Outline'), findsOneWidget);
  });

  testWidgets('ghost variant renders label', (tester) async {
    await tester.pumpObers(const OiButton.ghost(label: 'Ghost'));
    expect(find.text('Ghost'), findsOneWidget);
  });

  testWidgets('destructive variant renders label', (tester) async {
    await tester.pumpObers(const OiButton.destructive(label: 'Delete'));
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('soft variant renders label', (tester) async {
    await tester.pumpObers(const OiButton.soft(label: 'Soft'));
    expect(find.text('Soft'), findsOneWidget);
  });

  // ── onTap ──────────────────────────────────────────────────────────────────

  testWidgets('onTap fires when tapped', (tester) async {
    var count = 0;
    await tester.pumpObers(OiButton.primary(label: 'Go', onTap: () => count++));
    await tester.tap(find.text('Go'));
    await tester.pump();
    expect(count, 1);
  });

  testWidgets('onTap not called when enabled=false', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiButton.primary(label: 'Go', enabled: false, onTap: () => count++),
    );
    await tester.tap(find.text('Go'), warnIfMissed: false);
    await tester.pump();
    expect(count, 0);
  });

  // ── Loading ────────────────────────────────────────────────────────────────

  testWidgets('loading=true shows OiPulse and hides label', (tester) async {
    await tester.pumpObers(
      const OiButton.primary(label: 'Save', loading: true),
    );
    expect(find.byType(OiPulse), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('loading=true prevents onTap from firing', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiButton.primary(label: 'Save', loading: true, onTap: () => count++),
    );
    await tester.tap(find.byType(OiPulse), warnIfMissed: false);
    await tester.pump();
    expect(count, 0);
  });

  testWidgets('loading indicator skips animation when reducedMotion', (
    tester,
  ) async {
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: OiButton.primary(label: 'Save', loading: true),
      ),
    );
    // OiPulse is present but its animation is suppressed.
    expect(find.byType(OiPulse), findsOneWidget);
    // The child should render directly without Opacity/Transform wrappers
    // from OiPulse (reducedMotion returns child as-is).
    final pulse = tester.widget<OiPulse>(find.byType(OiPulse));
    expect(pulse.active, isTrue);
  });

  // ── fullWidth ──────────────────────────────────────────────────────────────

  testWidgets('fullWidth=true adds SizedBox with infinite width', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiButton.primary(label: 'Wide', fullWidth: true),
    );
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
    expect(boxes.any((b) => b.width == double.infinity), isTrue);
  });

  // ── Sizes ──────────────────────────────────────────────────────────────────
  // Use compact density so OiTappable does NOT add the 48 dp touch-target
  // floor, letting us observe raw button heights.

  testWidgets('small height < medium height', (tester) async {
    // Align loosens the height constraint so each button gets its natural
    // height. compact density removes the 48 dp touch-target floor.
    await tester.pumpWidget(
      const OiApp(
        density: OiDensity.compact,
        home: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OiButton.primary(
                key: Key('sm'),
                label: 'S',
                size: OiButtonSize.small,
              ),
              OiButton.primary(key: Key('md'), label: 'M'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    final smH = tester.getSize(find.byKey(const Key('sm'))).height;
    final mdH = tester.getSize(find.byKey(const Key('md'))).height;
    expect(smH, lessThan(mdH));
  });

  testWidgets('large height > medium height', (tester) async {
    await tester.pumpWidget(
      const OiApp(
        density: OiDensity.compact,
        home: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OiButton.primary(key: Key('md'), label: 'M'),
              OiButton.primary(
                key: Key('lg'),
                label: 'L',
                size: OiButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    final mdH = tester.getSize(find.byKey(const Key('md'))).height;
    final lgH = tester.getSize(find.byKey(const Key('lg'))).height;
    expect(lgH, greaterThan(mdH));
  });

  // ── Icon-only button ───────────────────────────────────────────────────────

  testWidgets('OiButton.icon renders Icon widget', (tester) async {
    await tester.pumpObers(const OiButton.icon(icon: _kIcon, label: 'Add'));
    expect(find.byIcon(_kIcon), findsOneWidget);
  });

  testWidgets('OiButton.icon fires onTap', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiButton.icon(icon: _kIcon, label: 'Add', onTap: () => count++),
    );
    await tester.tap(find.byIcon(_kIcon));
    await tester.pump();
    expect(count, 1);
  });

  testWidgets('OiButton.icon passes semantic label to accessibility tree', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(const OiButton.icon(icon: _kIcon, label: 'Close'));
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('OiButton.icon is square', (tester) async {
    // Align loosens constraints so the icon button gets its natural size
    // (width == height == buttonHeight). compact density removes the 48 dp
    // touch-target floor, so the OiTappable also renders at natural size.
    await tester.pumpWidget(
      const OiApp(
        density: OiDensity.compact,
        home: Align(
          child: OiButton.icon(icon: _kIcon, label: 'Add'),
        ),
      ),
    );
    await tester.pump();
    final size = tester.getSize(find.byType(OiButton));
    expect((size.width - size.height).abs(), lessThan(2));
  });

  testWidgets(
    'icon variants retain themed surfaces through hover and disabled',
    (
      tester,
    ) async {
      final base = OiThemeData.light();
      const normal = Color(0xff223344);
      const hover = Color(0xff334455);
      const disabled = Color(0xff445566);
      const border = Color(0xff778899);
      final theme = base.copyWith(
        components: base.components.copyWith(
          button: const OiButtonThemeData(
            secondaryStyle: OiButtonVariantStyle(
              background: normal,
              backgroundHover: hover,
              backgroundDisabled: disabled,
              border: border,
            ),
          ),
        ),
      );
      Future<void> mount(OiButtonVariant variant, {bool enabled = true}) =>
          tester.pumpObers(
            Center(
              child: OiButton.icon(
                icon: _kIcon,
                label: 'More',
                variant: variant,
                enabled: enabled,
                onTap: () {},
              ),
            ),
            theme: theme,
          );
      BoxDecoration decoration() => tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(OiButton),
              matching: find.byType(Container),
            ),
          )
          .map((container) => container.decoration)
          .whereType<BoxDecoration>()
          .single;
      await mount(OiButtonVariant.secondary);
      final bounds = tester.getRect(find.byType(OiButton));
      expect(decoration().color, normal);
      expect(decoration().border, Border.all(color: border));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(bounds.center);
      await tester.pumpAndSettle();
      expect(decoration().color, hover);
      expect(tester.getRect(find.byType(OiButton)), bounds);
      await mount(OiButtonVariant.secondary, enabled: false);
      expect(decoration().color, disabled);
      await mouse.moveTo(Offset.zero);
      await mount(OiButtonVariant.outline);
      expect(decoration().border, Border.all(color: base.colors.border));
      await mount(OiButtonVariant.ghost);
      expect(decoration().border, isNull);
      expect(decoration().color, const Color(0x00000000));
      expect(tester.takeException(), isNull);
      await mouse.removePointer();
    },
  );

  // ── OiButton accessibility (REQ-0019) ────────────────────────────────────

  group('OiButton accessibility', () {
    testWidgets('should expose label as semantics for default constructor', (
      tester,
    ) async {
      await tester.pumpObers(const OiButton.primary(label: 'Submit'));
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final matching = semanticsWidgets
          .where((s) => s.properties.label == 'Submit')
          .toList();
      expect(matching, isNotEmpty);
    });

    testWidgets('should expose label as semantics for .icon() constructor', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpObers(
          const OiButton.icon(icon: _kIcon, label: 'Close dialog'),
        );
        expect(find.bySemanticsLabel('Close dialog'), findsOneWidget);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('should expose label as semantics for .ghost() constructor', (
      tester,
    ) async {
      await tester.pumpObers(const OiButton.ghost(label: 'Skip'));
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final matching = semanticsWidgets
          .where((s) => s.properties.label == 'Skip')
          .toList();
      expect(matching, isNotEmpty);
    });

    testWidgets(
      'should expose label as semantics for .destructive() constructor',
      (tester) async {
        await tester.pumpObers(const OiButton.destructive(label: 'Remove'));
        final semanticsWidgets = tester.widgetList<Semantics>(
          find.byType(Semantics),
        );
        final matching = semanticsWidgets
            .where((s) => s.properties.label == 'Remove')
            .toList();
        expect(matching, isNotEmpty);
      },
    );
  });

  // ── Semantics ──────────────────────────────────────────────────────────────

  testWidgets('standard button is marked as button in accessibility tree', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(const OiButton.primary(label: 'Save'));
    final node = tester.getSemantics(find.text('Save'));
    expect(node.flagsCollection.isButton, isTrue);
    handle.dispose();
  });

  testWidgets('semanticLabel overrides label in accessibility tree', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(
      const OiButton.primary(label: 'Save', semanticLabel: 'Save document'),
    );
    // Verify the Semantics widget has the overridden label.
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'Save document')
        .toList();
    expect(matching, hasLength(1));
    handle.dispose();
  });

  // ── Leading / trailing icon ────────────────────────────────────────────────

  testWidgets('leading icon renders before label', (tester) async {
    await tester.pumpObers(const OiButton.primary(label: 'Add', icon: _kIcon));
    final iconDx = tester.getCenter(find.byIcon(_kIcon)).dx;
    final textDx = tester.getCenter(find.text('Add')).dx;
    expect(iconDx, lessThan(textDx));
  });

  testWidgets('leading/trailing icon uses OiIcon.decorative', (tester) async {
    await tester.pumpObers(const OiButton.primary(label: 'Add', icon: _kIcon));
    expect(find.byType(OiIcon), findsOneWidget);
  });

  testWidgets('trailing icon renders after label', (tester) async {
    await tester.pumpObers(
      const OiButton.primary(
        label: 'Next',
        icon: _kIcon,
        iconPosition: OiIconPosition.trailing,
      ),
    );
    final iconDx = tester.getCenter(find.byIcon(_kIcon)).dx;
    final textDx = tester.getCenter(find.text('Next')).dx;
    expect(iconDx, greaterThan(textDx));
  });

  // ── Split button ───────────────────────────────────────────────────────────

  testWidgets('split button main tap fires onTap', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiButton.split(
        label: 'Export',
        onTap: () => count++,
        dropdown: const Text('CSV'),
      ),
    );
    await tester.tap(find.text('Export'));
    await tester.pump();
    expect(count, 1);
  });

  testWidgets('split button chevron tap shows dropdown', (tester) async {
    await tester.pumpObers(
      OiButton.split(
        label: 'Export',
        onTap: () {},
        dropdown: const Text('CSV option'),
      ),
    );
    expect(find.text('CSV option'), findsNothing);
    // The chevron is the Icon widget inside the second OiTappable.
    // Find it by its IconData codepoint (expand_more / keyboard_arrow_down).
    // Since its exact codepoint is an implementation detail, find all icons
    // and tap the one that is NOT the test icon (there is exactly one chevron).
    final icons = find.byType(Icon);
    expect(icons, findsOneWidget); // only the chevron — no label icon
    await tester.tap(icons);
    await tester.pumpAndSettle();
    expect(find.text('CSV option'), findsOneWidget);
  });

  // ── Countdown button ───────────────────────────────────────────────────────

  testWidgets('countdown button is disabled initially', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiButton.countdown(label: 'Agree', seconds: 3, onTap: () => count++),
    );
    expect(find.textContaining('Agree (3)'), findsOneWidget);
    await tester.tap(find.byType(OiButton), warnIfMissed: false);
    await tester.pump();
    expect(count, 0);
  });

  testWidgets('countdown button enables after countdown expires', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpObers(
      OiButton.countdown(label: 'Agree', seconds: 2, onTap: () => count++),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Agree'), findsOneWidget);
    await tester.tap(find.text('Agree'));
    await tester.pump();
    expect(count, 1);
  });

  // ── Confirm button ─────────────────────────────────────────────────────────

  testWidgets('confirm button shows label initially', (tester) async {
    await tester.pumpObers(
      OiButton.confirm(
        label: 'Delete',
        confirmLabel: 'Are you sure?',
        onConfirm: () {},
      ),
    );
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Are you sure?'), findsNothing);
  });

  testWidgets('confirm: first tap shows confirmLabel', (tester) async {
    await tester.pumpObers(
      OiButton.confirm(
        label: 'Delete',
        confirmLabel: 'Are you sure?',
        onConfirm: () {},
      ),
    );
    await tester.tap(find.text('Delete'));
    await tester.pump();
    expect(find.text('Are you sure?'), findsOneWidget);
  });

  testWidgets('confirm: second tap fires onConfirm and resets label', (
    tester,
  ) async {
    var confirmed = 0;
    await tester.pumpObers(
      OiButton.confirm(
        label: 'Delete',
        confirmLabel: 'Are you sure?',
        onConfirm: () => confirmed++,
      ),
    );
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.tap(find.text('Are you sure?'));
    await tester.pump();
    expect(confirmed, 1);
    expect(find.text('Delete'), findsOneWidget);
  });

  // ── REQ-0146: primary variant colors ──────────────────────────────────────

  testWidgets('REQ-0146: primary background uses primary.base color', (
    tester,
  ) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(const OiButton.primary(label: 'Save'), theme: theme);
    final containers = tester.widgetList<Container>(find.byType(Container));
    final colors = theme.colors;
    final found = containers.any((c) {
      final deco = c.decoration;
      return deco is BoxDecoration && deco.color == colors.primary.base;
    });
    expect(found, isTrue);
  });

  testWidgets(
    'REQ-0146: primary foreground text uses primary.foreground color',
    (tester) async {
      final theme = OiThemeData.light();
      await tester.pumpObers(
        const OiButton.primary(label: 'Save'),
        theme: theme,
      );
      final texts = tester.widgetList<Text>(find.byType(Text));
      final expectedColor = theme.colors.primary.foreground;
      final found = texts.any((t) => t.style?.color == expectedColor);
      expect(found, isTrue);
    },
  );

  // ── REQ-0147: secondary variant colors ────────────────────────────────────

  testWidgets('REQ-0147: secondary background uses surfaceSubtle color', (
    tester,
  ) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(
      const OiButton.secondary(label: 'Cancel'),
      theme: theme,
    );
    final containers = tester.widgetList<Container>(find.byType(Container));
    final expectedColor = theme.colors.surfaceSubtle;
    final found = containers.any((c) {
      final deco = c.decoration;
      return deco is BoxDecoration && deco.color == expectedColor;
    });
    expect(found, isTrue);
  });

  testWidgets('REQ-0147: secondary text uses standard text color', (
    tester,
  ) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(
      const OiButton.secondary(label: 'Cancel'),
      theme: theme,
    );
    final texts = tester.widgetList<Text>(find.byType(Text));
    final expectedColor = theme.colors.text;
    final found = texts.any((t) => t.style?.color == expectedColor);
    expect(found, isTrue);
  });

  // ── REQ-0149: destructive variant colors ──────────────────────────────────

  testWidgets('REQ-0149: destructive background uses error.base color', (
    tester,
  ) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(
      const OiButton.destructive(label: 'Delete'),
      theme: theme,
    );
    final containers = tester.widgetList<Container>(find.byType(Container));
    final found = containers.any((c) {
      final deco = c.decoration;
      return deco is BoxDecoration && deco.color == theme.colors.error.base;
    });
    expect(found, isTrue);
  });

  testWidgets('REQ-0149: destructive foreground uses error.foreground color', (
    tester,
  ) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(
      const OiButton.destructive(label: 'Delete'),
      theme: theme,
    );
    final texts = tester.widgetList<Text>(find.byType(Text));
    final found = texts.any(
      (t) => t.style?.color == theme.colors.error.foreground,
    );
    expect(found, isTrue);
  });

  // ── REQ-0150: soft variant colors ─────────────────────────────────────────

  testWidgets('REQ-0150: soft background uses primary.muted color', (
    tester,
  ) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(const OiButton.soft(label: 'Soft'), theme: theme);
    final containers = tester.widgetList<Container>(find.byType(Container));
    final found = containers.any((c) {
      final deco = c.decoration;
      return deco is BoxDecoration && deco.color == theme.colors.primary.muted;
    });
    expect(found, isTrue);
  });

  testWidgets('REQ-0150: soft foreground uses primary.base color', (
    tester,
  ) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(const OiButton.soft(label: 'Soft'), theme: theme);
    final texts = tester.widgetList<Text>(find.byType(Text));
    final found = texts.any((t) => t.style?.color == theme.colors.primary.base);
    expect(found, isTrue);
  });

  // ── REQ-0148: outline variant colors ──────────────────────────────────────

  testWidgets('REQ-0148: outline background is transparent', (tester) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(
      const OiButton.outline(label: 'Outline'),
      theme: theme,
    );
    final containers = tester.widgetList<Container>(find.byType(Container));
    final found = containers.any((c) {
      final deco = c.decoration;
      return deco is BoxDecoration && deco.color == const Color(0x00000000);
    });
    expect(found, isTrue);
  });

  testWidgets('REQ-0148: outline has visible border decoration', (
    tester,
  ) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(
      const OiButton.outline(label: 'Outline'),
      theme: theme,
    );
    final containers = tester.widgetList<Container>(find.byType(Container));
    final found = containers.any((c) {
      final deco = c.decoration;
      if (deco is! BoxDecoration) return false;
      final border = deco.border;
      if (border is! Border) return false;
      return border.top.width > 0 &&
          border.top.color != const Color(0x00000000);
    });
    expect(found, isTrue);
  });

  // ── Tooltip ───────────────────────────────────────────────────────────────

  testWidgets('primary shows OiTooltip widget when tooltip provided', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiButton.primary(label: 'Save', tooltip: 'Save your work'),
    );
    expect(find.byType(OiTooltip), findsOneWidget);
  });

  testWidgets('no OiTooltip widget when tooltip is null', (tester) async {
    await tester.pumpObers(const OiButton.primary(label: 'Save'));
    expect(find.byType(OiTooltip), findsNothing);
  });

  testWidgets('secondary shows OiTooltip when tooltip provided', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiButton.secondary(label: 'Cancel', tooltip: 'Cancel action'),
    );
    expect(find.byType(OiTooltip), findsOneWidget);
  });

  testWidgets('outline shows OiTooltip when tooltip provided', (tester) async {
    await tester.pumpObers(
      const OiButton.outline(label: 'Outline', tooltip: 'Outline button'),
    );
    expect(find.byType(OiTooltip), findsOneWidget);
  });

  testWidgets('tooltip visible on disabled button', (tester) async {
    await tester.pumpObers(
      const OiButton.primary(
        label: 'Save',
        enabled: false,
        tooltip: 'Disabled save',
      ),
    );
    expect(find.byType(OiTooltip), findsOneWidget);
  });

  // ── Density-aware sizing ───────────────────────────────────────────────────

  testWidgets('dense density produces smaller height than comfortable', (
    tester,
  ) async {
    // Measure the Container that is an ancestor of the label text — that is
    // the button body Container, whose height is set to buttonHeight directly.
    double bodyHeight(WidgetTester t) {
      final containerFinder = find.ancestor(
        of: find.text('X'),
        matching: find.byType(Container),
      );
      // .last is the innermost ancestor — the button body Container.
      return t.getSize(containerFinder.last).height;
    }

    await tester.pumpWidget(
      const OiApp(
        density: OiDensity.comfortable,
        home: Align(
          alignment: Alignment.topLeft,
          child: OiButton.primary(label: 'X'),
        ),
      ),
    );
    await tester.pump();
    final comfortableH = bodyHeight(tester);

    await tester.pumpWidget(
      const OiApp(
        density: OiDensity.dense,
        home: Align(
          alignment: Alignment.topLeft,
          child: OiButton.primary(label: 'X'),
        ),
      ),
    );
    await tester.pump();
    final denseH = bodyHeight(tester);

    expect(denseH, lessThan(comfortableH));
  });
}
