import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import 'oi_button_evidence_fixture.dart';

void main() {
  test('new scalar and LTR/RTL inset geometry is validated in factory', () {
    for (final invalid in [-1.0, double.nan, double.infinity]) {
      expect(() => OiButtonSizeStyle(iconSize: invalid), throwsArgumentError);
      expect(
        () => OiButtonSizeStyle(iconOnlySize: invalid),
        throwsArgumentError,
      );
      expect(() => OiButtonSizeStyle(iconGap: invalid), throwsArgumentError);
      expect(() => OiButtonSizeStyle(minWidth: invalid), throwsArgumentError);
      for (final edges in [
        EdgeInsets.only(left: invalid),
        EdgeInsets.only(top: invalid),
        EdgeInsets.only(right: invalid),
        EdgeInsets.only(bottom: invalid),
        EdgeInsetsDirectional.only(start: invalid),
        EdgeInsetsDirectional.only(end: invalid),
      ]) {
        expect(() => OiButtonSizeStyle(padding: edges), throwsArgumentError);
      }
      expect(
        () => OiButtonSizeStyle(
          iconLabelPadding: EdgeInsetsDirectional.only(start: invalid),
        ),
        throwsArgumentError,
      );
    }
    final style = OiButtonSizeStyle(
      padding: const EdgeInsets.only(left: 8).add(
        const EdgeInsetsDirectional.only(end: 2),
      ),
      iconLabelPadding: const EdgeInsetsDirectional.fromSTEB(4, 2, 9, 3),
      iconGap: 0,
    );
    expect(
      style.padding?.resolve(TextDirection.ltr),
      const EdgeInsets.fromLTRB(8, 0, 2, 0),
    );
    expect(
      style.padding?.resolve(TextDirection.rtl),
      const EdgeInsets.fromLTRB(10, 0, 0, 0),
    );
    expect(
      style.iconLabelPadding?.resolve(TextDirection.ltr),
      const EdgeInsets.fromLTRB(4, 2, 9, 3),
    );
    expect(
      style.iconLabelPadding?.resolve(TextDirection.rtl),
      const EdgeInsets.fromLTRB(9, 2, 4, 3),
    );
    expect(style.copyWith(), style);
    expect(style.copyWith().hashCode, style.hashCode);
    expect(const OiButtonSizeStyles().small, isNull);
  });

  testWidgets('empty per-size groups retain exact legacy public pixels', (
    tester,
  ) async {
    final empty = OiButtonSizeStyle();
    final sizes = OiButtonSizeStyles(small: empty, medium: empty, large: empty);
    expect(sizes.copyWith(), sizes);
    expect(sizes.copyWith().hashCode, sizes.hashCode);
    final base = OiThemeData.light();
    final configured = base.copyWith(
      components: base.components.copyWith(
        button: OiButtonThemeData(sizeStyles: sizes),
      ),
    );
    for (final size in OiButtonSize.values) {
      for (final consumer in [
        'normal',
        'split',
        'countdown',
        'confirm',
        'icon',
      ]) {
        final button = switch (consumer) {
          'normal' => OiButton.primary(
            key: buttonEvidenceKey,
            label: 'Action Hg',
            size: size,
          ),
          'split' => OiButton.split(
            key: buttonEvidenceKey,
            label: 'Action Hg',
            size: size,
            onTap: () {},
            dropdown: const SizedBox(),
          ),
          'countdown' => OiButton.countdown(
            key: buttonEvidenceKey,
            label: 'Action Hg',
            size: size,
            onTap: () {},
            seconds: 0,
          ),
          'confirm' => OiButton.confirm(
            key: buttonEvidenceKey,
            label: 'Action Hg',
            size: size,
            confirmLabel: 'Confirm Hg',
            onConfirm: () {},
          ),
          _ => OiButton.icon(
            key: buttonEvidenceKey,
            label: 'Add',
            icon: OiIcons.plus,
            size: size,
          ),
        };
        final legacy = await captureButtonEvidence(tester, button, theme: base);
        final unchanged = await captureButtonEvidence(
          tester,
          button,
          theme: configured,
        );
        expect(unchanged.bytes, orderedEquals(legacy.bytes));
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox());
  });
}
