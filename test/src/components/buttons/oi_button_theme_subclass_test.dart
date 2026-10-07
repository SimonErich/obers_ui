import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart' show OiButtonFontSizeScale;
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_theme_data.dart'
    as theme;

class _OldSignatureOverride extends theme.OiButtonThemeData {
  const _OldSignatureOverride({super.padding, super.sizeStyles});
  @override
  theme.OiButtonThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsetsDirectional? iconLabelPadding,
    TextStyle? textStyle,
    OiButtonFontSizeScale? fontSizes,
    double? smallHeight,
    double? mediumHeight,
    double? largeHeight,
    double? height,
    double? minWidth,
    double? iconSize,
    double? iconGap,
    double? smallIconGap,
    theme.OiButtonVariantStyle? primaryStyle,
    theme.OiButtonVariantStyle? outlineStyle,
    theme.OiButtonVariantStyle? ghostStyle,
    theme.OiButtonVariantStyle? destructiveStyle,
    theme.OiButtonVariantStyle? softStyle,
    theme.OiButtonVariantStyle? secondaryStyle,
  }) => super.copyWith(
    borderRadius: borderRadius,
    padding: padding ?? const EdgeInsets.all(11),
    iconLabelPadding: iconLabelPadding,
    textStyle: textStyle,
    fontSizes: fontSizes,
    smallHeight: smallHeight,
    mediumHeight: mediumHeight,
    largeHeight: largeHeight,
    height: height,
    minWidth: minWidth,
    iconSize: iconSize,
    iconGap: iconGap,
    smallIconGap: smallIconGap,
    primaryStyle: primaryStyle,
    outlineStyle: outlineStyle,
    ghostStyle: ghostStyle,
    destructiveStyle: destructiveStyle,
    softStyle: softStyle,
    secondaryStyle: secondaryStyle,
  );
}

void main() {
  test('old copyWith override compiles and carries opt-in size styles', () {
    final sizes = theme.OiButtonSizeStyles(
      medium: theme.OiButtonSizeStyle(
        textStyle: const TextStyle(fontSize: 14, height: 20 / 14),
      ),
    );
    final original = _OldSignatureOverride(
      padding: const EdgeInsets.all(7),
      sizeStyles: sizes,
    );
    final copied = original.copyWith(padding: const EdgeInsets.all(9));
    expect(copied.padding, const EdgeInsets.all(9));
    expect(copied.sizeStyles, same(sizes));
    expect(copied.sizeStyles?.medium?.textStyle?.height, 20 / 14);
    expect(copied.copyWith().sizeStyles, same(sizes));
    expect(original.copyWith().padding, const EdgeInsets.all(11));
    expect(original.padding, const EdgeInsets.all(7));
    expect(const _OldSignatureOverride().copyWith().sizeStyles, isNull);
  });
}
