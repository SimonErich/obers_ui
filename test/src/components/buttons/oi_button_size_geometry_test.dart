import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import 'oi_button_evidence_fixture.dart';

void main() {
  _zeroGeometryCases();
  testWidgets(
    'small label icon uses its selected size without changing height',
    (
      tester,
    ) async {
      var taps = 0;
      final base = OiThemeData.light();
      final theme = base.copyWith(
        components: base.components.copyWith(
          button: OiButtonThemeData(
            iconSize: 11,
            sizeStyles: OiButtonSizeStyles(
              small: OiButtonSizeStyle(iconSize: 20),
            ),
          ),
        ),
      );
      await captureButtonEvidence(
        tester,
        OiButton.primary(
          key: buttonEvidenceKey,
          label: 'Go',
          icon: OiIcons.plus,
          size: OiButtonSize.small,
          onTap: () => taps++,
        ),
        theme: theme,
      );
      // The accepted fixture authors compact/pointer scopes, not OiApp defaults.
      final context = tester.element(find.byKey(buttonEvidenceKey));
      final density = OiDensityScope.of(context);
      final modality = OiPlatform.of(context).inputModality;
      expect(density, OiDensity.compact);
      expect(modality, OiInputModality.pointer);
      final icon = find.descendant(
        of: find.byKey(buttonEvidenceKey),
        matching: find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == OiIcons.plus,
        ),
      );
      expect(icon, findsOneWidget);
      final measured = tester.getSize(icon);
      final height = tester.getSize(find.byKey(buttonEvidenceKey)).height;
      await tester.tap(find.byKey(buttonEvidenceKey));
      await tester.pump();
      debugPrint(
        jsonEncode({
          'sizeGeometry': 'small-normal-label-icon',
          'legacyGlobalIconSize': 11,
          'selectedIconSize': 20,
          'actualIcon': [measured.width, measured.height],
          'actualButtonHeight': height,
          'density': density.name,
          'modality': modality.name,
          'callbacks': taps,
        }),
      );
      expect(tester.takeException(), isNull);
      expect(taps, 1);
      expect(height, 24);
      expect(measured, const Size(20, 20));
    },
  );

  testWidgets('icon-only selected glyph stays inside its legacy square', (
    tester,
  ) async {
    var taps = 0;
    await captureButtonEvidence(
      tester,
      OiButton.icon(
        key: buttonEvidenceKey,
        icon: OiIcons.plus,
        label: 'Add',
        onTap: () => taps++,
      ),
      theme: _theme(
        OiButtonSizeStyle(iconSize: 18, iconOnlySize: 22),
        globalIconSize: 11,
      ),
    );
    final glyph = _glyphRect(tester, OiIcons.plus);
    final square = tester.getSize(find.byKey(buttonEvidenceKey));
    await tester.tap(find.byKey(buttonEvidenceKey));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(taps, 1);
    expect(square, const Size(32, 32));
    expect(glyph.size, const Size(22, 22));
  });

  testWidgets('split chevron uses selected glyph and keeps separate actions', (
    tester,
  ) async {
    var taps = 0;
    await captureButtonEvidence(
      tester,
      OiButton.split(
        key: buttonEvidenceKey,
        label: 'Go',
        size: OiButtonSize.small,
        onTap: () => taps++,
        dropdown: const Text('Menu'),
      ),
      theme: _theme(
        OiButtonSizeStyle(iconSize: 20, iconOnlySize: 22),
        globalIconSize: 11,
      ),
    );
    final glyph = _glyphRect(tester, OiIcons.arrowDown);
    final actions = find.descendant(
      of: find.byKey(buttonEvidenceKey),
      matching: find.byType(OiTappable),
    );
    expect(actions, findsNWidgets(2));
    expect(tester.getSize(actions.last), const Size(24, 24));
    await tester.tap(actions.first);
    await tester.pump();
    expect(taps, 1);
    await tester.tap(actions.last);
    await tester.pump();
    await tester.pump();
    expect(find.text('Menu'), findsOneWidget);
    expect(taps, 1);
    await tester.tap(actions.last);
    await tester.pump();
    await tester.pump();
    expect(find.text('Menu'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(glyph.size, const Size(20, 20));
  });

  testWidgets('small icon label uses explicit asymmetric content insets', (
    tester,
  ) async {
    await captureButtonEvidence(
      tester,
      OiButton.primary(
        key: buttonEvidenceKey,
        label: 'Go',
        icon: OiIcons.plus,
        size: OiButtonSize.small,
        onTap: () {},
      ),
      theme: _theme(
        OiButtonSizeStyle(
          iconSize: 10,
          padding: const EdgeInsets.all(3),
          iconLabelPadding: const EdgeInsetsDirectional.fromSTEB(5, 2, 13, 4),
        ),
        globalPadding: const EdgeInsets.all(7),
        globalIconLabelPadding: const EdgeInsetsDirectional.fromSTEB(
          2,
          0,
          8,
          0,
        ),
        globalIconGap: 0,
      ),
    );
    final action = _actionRect(tester);
    final glyph = _glyphRect(tester, OiIcons.plus);
    final label = _labelRect(tester, 'Go');
    expect(tester.takeException(), isNull);
    expect(action.height, 24);
    expect(glyph.left - action.left, 5);
    expect(action.right - label.right, 13);
    expect(label.center.dy - action.center.dy, -1);
  });

  testWidgets('selected plain padding shifts actual label edges', (
    tester,
  ) async {
    await captureButtonEvidence(
      tester,
      OiButton.primary(
        key: buttonEvidenceKey,
        label: 'Go',
        onTap: () {},
      ),
      theme: _theme(
        OiButtonSizeStyle(
          padding: const EdgeInsetsDirectional.fromSTEB(7, 1, 19, 3),
          iconLabelPadding: const EdgeInsetsDirectional.all(9),
        ),
        globalPadding: const EdgeInsets.all(2),
      ),
    );
    final action = _actionRect(tester);
    final label = _labelRect(tester, 'Go');
    expect(tester.takeException(), isNull);
    expect(action.height, 32);
    expect(label.left - action.left, 7);
    expect(action.right - label.right, 19);
    expect(label.center.dy - action.center.dy, -1);
  });

  testWidgets('icon-only selected interior padding does not enlarge square', (
    tester,
  ) async {
    await captureButtonEvidence(
      tester,
      OiButton.icon(
        key: buttonEvidenceKey,
        label: 'Add',
        icon: OiIcons.plus,
        onTap: () {},
      ),
      theme: _theme(
        OiButtonSizeStyle(
          iconOnlySize: 10,
          padding: const EdgeInsetsDirectional.fromSTEB(1, 2, 9, 6),
          minWidth: 90,
        ),
        globalPadding: const EdgeInsets.all(3),
        globalMinWidth: 100,
      ),
    );
    final square = tester.getRect(find.byKey(buttonEvidenceKey));
    final glyph = _glyphRect(tester, OiIcons.plus);
    expect(tester.takeException(), isNull);
    expect(square.size, const Size(32, 32));
    expect(glyph.size, const Size(10, 10));
    expect(glyph.center.dx - square.center.dx, -4);
    expect(glyph.center.dy - square.center.dy, -2);
  });

  testWidgets('explicit RTL gap sits between leading glyph and label', (
    tester,
  ) async {
    await captureButtonEvidence(
      tester,
      OiButton.primary(
        key: buttonEvidenceKey,
        label: 'Go',
        icon: OiIcons.plus,
        onTap: () {},
      ),
      theme: _theme(
        OiButtonSizeStyle(
          iconSize: 10,
          iconGap: 9,
          padding: EdgeInsets.zero,
        ),
        globalIconGap: 3,
      ),
      direction: TextDirection.rtl,
    );
    final glyph = _glyphRect(tester, OiIcons.plus);
    final label = _labelRect(tester, 'Go');
    expect(tester.takeException(), isNull);
    expect(glyph.center.dx, greaterThan(label.center.dx));
    expect(glyph.left - label.right, 9);
  });

  testWidgets('selected countdown width persists across timer enablement', (
    tester,
  ) async {
    var taps = 0;
    await captureButtonEvidence(
      tester,
      OiButton.countdown(
        key: buttonEvidenceKey,
        label: 'Go',
        seconds: 1,
        onTap: () => taps++,
      ),
      theme: _theme(OiButtonSizeStyle(minWidth: 160), globalMinWidth: 200),
    );
    final waiting = _actionRect(tester);
    expect(find.text('Go (1)'), findsOneWidget);
    await tester.tap(find.byKey(buttonEvidenceKey));
    await tester.pump();
    expect(taps, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Go'), findsOneWidget);
    final enabled = _actionRect(tester);
    await tester.tap(find.byKey(buttonEvidenceKey));
    await tester.pump();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
    expect(waiting.height, 32);
    expect(enabled.height, 32);
    expect(waiting.width, 160);
    expect(enabled.width, 160);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('selected split width belongs only to main action', (
    tester,
  ) async {
    var taps = 0;
    await captureButtonEvidence(
      tester,
      OiButton.split(
        key: buttonEvidenceKey,
        label: 'Go',
        onTap: () => taps++,
        dropdown: const SizedBox(),
      ),
      theme: _theme(OiButtonSizeStyle(minWidth: 100), globalMinWidth: 180),
    );
    final mainAction = _actionRect(tester);
    final chevron = _actionRect(tester, last: true);
    final total = tester.getSize(find.byKey(buttonEvidenceKey));
    await tester.tapAt(mainAction.center);
    await tester.pump();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
    expect(mainAction.height, 32);
    expect(chevron.size, const Size(32, 32));
    expect(mainAction.width, 100);
    expect(total, const Size(132, 32));
  });

  testWidgets('glyph precedence and missing slots hold for all sizes', (
    tester,
  ) async {
    var observations = 0;
    final cases = <(OiButtonSizeStyle?, double?, double?, bool)>[
      (OiButtonSizeStyle(iconSize: 20, iconOnlySize: 22), 20, 22, false),
      (OiButtonSizeStyle(iconSize: 20), 20, 20, false),
      (OiButtonSizeStyle(iconOnlySize: 21), null, 21, false),
      (OiButtonSizeStyle(), null, null, false),
      (null, null, null, false),
      (OiButtonSizeStyle(iconSize: 20), null, null, true),
    ];
    for (final size in OiButtonSize.values) {
      final oldSize = [14.0, 16.0, 18.0][size.index];
      final height = [24.0, 32.0, 40.0][size.index];
      for (final consumer in ['normal', 'ghost', 'icon', 'split']) {
        for (final entry in cases) {
          var taps = 0;
          await captureButtonEvidence(
            tester,
            _button(consumer, size, withIcon: true, onTap: () => taps++),
            theme: _theme(
              entry.$1,
              globalIconSize: 11,
              onlySize: entry.$4
                  ? OiButtonSize.values[(size.index + 1) % 3]
                  : null,
            ),
          );
          final glyph = _glyphRect(
            tester,
            consumer == 'split' ? OiIcons.arrowDown : OiIcons.plus,
          );
          final expected = consumer == 'icon'
              ? entry.$3 ?? 11
              : consumer == 'split'
              ? entry.$2 ?? oldSize
              : entry.$2 ?? 11;
          expect(glyph.size, Size(expected, expected));
          expect(_actionRect(tester).height, height);
          if (consumer == 'icon') {
            expect(
              tester.getSize(find.byKey(buttonEvidenceKey)),
              Size(height, height),
            );
          }
          await tester.tapAt(_actionRect(tester).center);
          await tester.pump();
          expect(taps, 1);
          expect(tester.takeException(), isNull);
          observations++;
        }
        await captureButtonEvidence(
          tester,
          _button(consumer, size, withIcon: true),
          theme: _theme(OiButtonSizeStyle()),
        );
        expect(
          _glyphRect(
            tester,
            consumer == 'split' ? OiIcons.arrowDown : OiIcons.plus,
          ).size,
          Size(oldSize, oldSize),
        );
        expect(tester.takeException(), isNull);
        observations++;
      }
    }
    expect(observations, 84);
    debugPrint(jsonEncode({'sizeGeometryGlyphObservations': observations}));
  });

  testWidgets('icon label insets mirror actual edges in both directions', (
    tester,
  ) async {
    var observations = 0;
    for (final size in OiButtonSize.values) {
      for (final consumer in ['normal', 'ghost']) {
        for (final direction in TextDirection.values) {
          for (final trailing in [false, true]) {
            await captureButtonEvidence(
              tester,
              _button(consumer, size, withIcon: true, trailing: trailing),
              theme: _theme(
                OiButtonSizeStyle(
                  iconSize: 10,
                  iconGap: 0,
                  iconLabelPadding: const EdgeInsetsDirectional.fromSTEB(
                    5,
                    1,
                    13,
                    3,
                  ),
                  padding: const EdgeInsets.all(4),
                ),
                globalIconLabelPadding: const EdgeInsetsDirectional.fromSTEB(
                  2,
                  0,
                  8,
                  0,
                ),
              ),
              direction: direction,
            );
            final action = _actionRect(tester);
            final glyph = _glyphRect(tester, OiIcons.plus);
            final label = _labelRect(tester, 'Go');
            final glyphOnLeft = trailing == (direction == TextDirection.rtl);
            expect(
              glyphOnLeft
                  ? glyph.left - action.left
                  : action.right - glyph.right,
              5,
            );
            expect(
              glyphOnLeft
                  ? action.right - label.right
                  : label.left - action.left,
              13,
            );
            expect(label.center.dy - action.center.dy, -1);
            expect(action.height, [24, 32, 40][size.index]);
            expect(tester.takeException(), isNull);
            observations++;
          }
        }
      }
    }
    expect(observations, 24);
    debugPrint(jsonEncode({'sizeGeometryInsetObservations': observations}));
  });

  testWidgets('plain selected padding composes with every public consumer', (
    tester,
  ) async {
    var observations = 0;
    for (final size in OiButtonSize.values) {
      for (final consumer in _consumers) {
        for (final direction in TextDirection.values) {
          await captureButtonEvidence(
            tester,
            _button(consumer, size),
            theme: _theme(
              OiButtonSizeStyle(
                iconSize: 10,
                padding: const EdgeInsetsDirectional.fromSTEB(1, 1, 5, 3),
                iconLabelPadding: const EdgeInsetsDirectional.all(9),
              ),
              globalPadding: const EdgeInsets.all(2),
            ),
            direction: direction,
          );
          final action = _actionRect(tester);
          final rtl = direction == TextDirection.rtl;
          if (consumer == 'icon') {
            final glyph = _glyphRect(tester, OiIcons.plus);
            expect(glyph.size, const Size(10, 10));
            expect(glyph.center.dx - action.center.dx, rtl ? 2 : -2);
            expect(glyph.center.dy - action.center.dy, -1);
            expect(action.width, [24, 32, 40][size.index]);
          } else {
            final label = _labelRect(tester, 'Go');
            expect(label.left - action.left, rtl ? 5 : 1);
            expect(action.right - label.right, rtl ? 1 : 5);
            expect(label.center.dy - action.center.dy, -1);
          }
          expect(action.height, [24, 32, 40][size.index]);
          expect(tester.takeException(), isNull);
          observations++;
        }
      }
    }
    expect(observations, 36);
    debugPrint(
      jsonEncode({'sizeGeometryPlainPaddingObservations': observations}),
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('zero and positive selected gaps remain between actual content', (
    tester,
  ) async {
    var observations = 0;
    for (final size in OiButtonSize.values) {
      for (final consumer in ['normal', 'ghost']) {
        for (final direction in TextDirection.values) {
          for (final trailing in [false, true]) {
            for (final gap in [0.0, 9.0]) {
              await captureButtonEvidence(
                tester,
                _button(consumer, size, withIcon: true, trailing: trailing),
                theme: _theme(
                  OiButtonSizeStyle(
                    iconSize: 10,
                    iconGap: gap,
                    padding: EdgeInsets.zero,
                  ),
                  globalIconGap: 3,
                ),
                direction: direction,
              );
              final glyph = _glyphRect(tester, OiIcons.plus);
              final label = _labelRect(tester, 'Go');
              final glyphOnLeft = trailing == (direction == TextDirection.rtl);
              expect(
                glyphOnLeft
                    ? label.left - glyph.right
                    : glyph.left - label.right,
                gap,
              );
              expect(tester.takeException(), isNull);
              observations++;
            }
          }
        }
      }
    }
    expect(observations, 48);
    debugPrint(jsonEncode({'sizeGeometryGapObservations': observations}));
  });

  testWidgets('selected and legacy widths preserve consumer-specific scope', (
    tester,
  ) async {
    var observations = 0;
    for (final size in OiButtonSize.values) {
      final height = [24.0, 32.0, 40.0][size.index];
      final natural = [40.0, 60.0, 80.0][size.index];
      for (final consumer in _consumers) {
        for (final minWidth in [null, 0.0, 160.0]) {
          var taps = 0;
          await captureButtonEvidence(
            tester,
            _button(consumer, size, onTap: () => taps++),
            theme: _theme(
              OiButtonSizeStyle(minWidth: minWidth),
              globalMinWidth: 200,
            ),
          );
          final action = _actionRect(tester);
          final width = consumer == 'icon'
              ? height
              : minWidth == null && ['normal', 'ghost'].contains(consumer)
              ? 200.0
              : minWidth == 160
              ? 160.0
              : natural;
          expect(action.size, Size(width, height));
          if (consumer == 'split') {
            expect(_actionRect(tester, last: true).size, Size(height, height));
            expect(
              tester.getSize(find.byKey(buttonEvidenceKey)),
              Size(width + height, height),
            );
          }
          await tester.tapAt(action.center);
          await tester.pump();
          if (consumer == 'confirm') {
            expect(taps, 0);
            expect(find.text('OK'), findsOneWidget);
            await tester.tapAt(_actionRect(tester).center);
            await tester.pump();
            expect(find.text('Go'), findsOneWidget);
          }
          expect(taps, 1);
          expect(tester.takeException(), isNull);
          observations++;
        }
      }
    }
    expect(observations, 54);
    debugPrint(jsonEncode({'sizeGeometryWidthObservations': observations}));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'partial style preserves legacy absolute gap when field is null',
    (
      tester,
    ) async {
      var observations = 0;
      for (final size in OiButtonSize.values) {
        for (final consumer in ['normal', 'ghost']) {
          for (final direction in TextDirection.values) {
            for (final trailing in [false, true]) {
              await captureButtonEvidence(
                tester,
                _button(consumer, size, withIcon: true, trailing: trailing),
                theme: _theme(
                  OiButtonSizeStyle(iconSize: 10),
                  globalPadding: EdgeInsets.zero,
                  globalIconGap: 7,
                  globalSmallIconGap: 2,
                ),
                direction: direction,
              );
              final glyph = _glyphRect(tester, OiIcons.plus);
              final label = _labelRect(tester, 'Go');
              final glyphOnLeft = trailing == (direction == TextDirection.rtl);
              final expectedGap = direction == TextDirection.rtl
                  ? 0
                  : size == OiButtonSize.small
                  ? 2
                  : 7;
              expect(
                glyphOnLeft
                    ? label.left - glyph.right
                    : glyph.left - label.right,
                expectedGap,
                reason: 'Null opt-in gap must not repair old absolute RTL gap',
              );
              expect(tester.takeException(), isNull);
              observations++;
            }
          }
        }
      }
      expect(observations, 24);
      debugPrint(jsonEncode({'sizeGeometryNullGapObservations': observations}));
    },
  );

  testWidgets(
    'empty, missing and partial slots keep exact legacy frame bytes',
    (
      tester,
    ) async {
      var pairs = 0;
      OiThemeData configured(
        OiButtonSizeStyle? style, {
        OiButtonSize? onlySize,
        bool emptyGroup = false,
      }) => _theme(
        style,
        globalIconSize: 11,
        globalMinWidth: 100,
        globalPadding: const EdgeInsets.fromLTRB(3, 1, 7, 2),
        globalIconLabelPadding: const EdgeInsetsDirectional.fromSTEB(
          5,
          1,
          15,
          3,
        ),
        globalIconGap: 7,
        globalSmallIconGap: 2,
        onlySize: onlySize,
        emptyGroup: emptyGroup,
      );
      for (final size in OiButtonSize.values) {
        for (final consumer in _consumers) {
          for (final direction in TextDirection.values) {
            final button = _button(consumer, size, withIcon: true);
            final before = await captureButtonEvidence(
              tester,
              button,
              theme: configured(null),
              direction: direction,
            );
            final bounds = tester.getRect(find.byKey(buttonEvidenceKey));
            final styles = [
              configured(null, emptyGroup: true),
              configured(OiButtonSizeStyle()),
              configured(OiButtonSizeStyle(textStyle: const TextStyle())),
              configured(
                OiButtonSizeStyle(
                  iconSize: 20,
                  iconOnlySize: 22,
                  iconGap: 9,
                  minWidth: 160,
                  padding: const EdgeInsets.all(2),
                  iconLabelPadding: const EdgeInsetsDirectional.all(3),
                ),
                onlySize: OiButtonSize.values[(size.index + 1) % 3],
              ),
            ];
            for (final theme in styles) {
              final after = await captureButtonEvidence(
                tester,
                button,
                theme: theme,
                direction: direction,
              );
              expect(after.bytes, orderedEquals(before.bytes));
              expect(tester.getRect(find.byKey(buttonEvidenceKey)), bounds);
              expect(tester.takeException(), isNull);
              pairs++;
            }
          }
        }
      }
      expect(pairs, 144);
      debugPrint(jsonEncode({'sizeGeometryLegacyFrameBytePairs': pairs}));
      await tester.pumpWidget(const SizedBox());
    },
  );
}

void _zeroGeometryCases() {
  testWidgets(
    'explicit zero glyphs and insets do not fall back or grow targets',
    (
      tester,
    ) async {
      var observations = 0;
      for (final size in OiButtonSize.values) {
        final height = [24.0, 32.0, 40.0][size.index];
        for (final consumer in ['normal', 'ghost', 'icon', 'split']) {
          var taps = 0;
          await captureButtonEvidence(
            tester,
            _button(consumer, size, withIcon: true, onTap: () => taps++),
            theme: _theme(
              OiButtonSizeStyle(
                iconSize: 0,
                iconOnlySize: 0,
                iconGap: 0,
                padding: EdgeInsets.zero,
                iconLabelPadding: EdgeInsetsDirectional.zero,
                minWidth: 0,
              ),
              globalIconSize: 11,
              globalIconGap: 7,
              globalMinWidth: 200,
              globalPadding: const EdgeInsets.all(4),
              globalIconLabelPadding: const EdgeInsetsDirectional.all(5),
            ),
          );
          expect(
            _glyphRect(
              tester,
              consumer == 'split' ? OiIcons.arrowDown : OiIcons.plus,
            ).size,
            Size.zero,
          );
          final action = _actionRect(tester);
          expect(action.height, height);
          if (consumer == 'icon') {
            expect(action.width, height);
          } else {
            final label = _labelRect(tester, 'Go');
            expect(label.left, action.left);
            expect(label.right, action.right);
          }
          await tester.tapAt(action.center);
          await tester.pump();
          expect(taps, 1);
          expect(tester.takeException(), isNull);
          observations++;
        }
      }
      expect(observations, 12);
      debugPrint(jsonEncode({'sizeGeometryZeroObservations': observations}));
    },
  );
}

OiThemeData _theme(
  OiButtonSizeStyle? selected, {
  double? globalIconSize,
  double? globalMinWidth,
  EdgeInsets? globalPadding,
  EdgeInsetsDirectional? globalIconLabelPadding,
  double? globalIconGap,
  double? globalSmallIconGap,
  OiButtonSize? onlySize,
  bool emptyGroup = false,
}) {
  final base = OiThemeData.light();
  return base.copyWith(
    components: base.components.copyWith(
      button: OiButtonThemeData(
        iconSize: globalIconSize,
        minWidth: globalMinWidth,
        padding: globalPadding,
        iconLabelPadding: globalIconLabelPadding,
        iconGap: globalIconGap,
        smallIconGap: globalSmallIconGap,
        sizeStyles: selected == null
            ? emptyGroup
                  ? const OiButtonSizeStyles()
                  : null
            : OiButtonSizeStyles(
                small: onlySize == null || onlySize == OiButtonSize.small
                    ? selected
                    : null,
                medium: onlySize == null || onlySize == OiButtonSize.medium
                    ? selected
                    : null,
                large: onlySize == null || onlySize == OiButtonSize.large
                    ? selected
                    : null,
              ),
      ),
    ),
  );
}

Rect _glyphRect(WidgetTester tester, IconData icon) {
  final glyph = find.descendant(
    of: find.byKey(buttonEvidenceKey),
    matching: find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == icon,
    ),
  );
  expect(glyph, findsOneWidget);
  return tester.getRect(glyph);
}

Rect _actionRect(WidgetTester tester, {bool last = false}) => tester.getRect(
  find
      .descendant(
        of: find.byKey(buttonEvidenceKey),
        matching: find.byType(OiTappable),
      )
      .at(last ? 1 : 0),
);

Rect _labelRect(WidgetTester tester, String label) {
  final paragraph = buttonEvidenceParagraph(tester, label);
  return paragraph.localToGlobal(Offset.zero) & paragraph.size;
}

const _consumers = ['normal', 'ghost', 'icon', 'split', 'countdown', 'confirm'];

OiButton _button(
  String consumer,
  OiButtonSize size, {
  bool withIcon = false,
  bool trailing = false,
  VoidCallback? onTap,
}) => switch (consumer) {
  'normal' => OiButton.primary(
    key: buttonEvidenceKey,
    label: 'Go',
    size: size,
    icon: withIcon ? OiIcons.plus : null,
    iconPosition: trailing ? OiIconPosition.trailing : OiIconPosition.leading,
    onTap: onTap ?? () {},
  ),
  'ghost' => OiButton.ghost(
    key: buttonEvidenceKey,
    label: 'Go',
    size: size,
    icon: withIcon ? OiIcons.plus : null,
    iconPosition: trailing ? OiIconPosition.trailing : OiIconPosition.leading,
    onTap: onTap ?? () {},
  ),
  'icon' => OiButton.icon(
    key: buttonEvidenceKey,
    label: 'Add',
    icon: OiIcons.plus,
    size: size,
    onTap: onTap ?? () {},
  ),
  'split' => OiButton.split(
    key: buttonEvidenceKey,
    label: 'Go',
    size: size,
    onTap: onTap ?? () {},
    dropdown: const SizedBox(),
  ),
  'countdown' => OiButton.countdown(
    key: buttonEvidenceKey,
    label: 'Go',
    size: size,
    seconds: 0,
    onTap: onTap ?? () {},
  ),
  _ => OiButton.confirm(
    key: buttonEvidenceKey,
    label: 'Go',
    confirmLabel: 'OK',
    size: size,
    onConfirm: onTap ?? () {},
  ),
};
