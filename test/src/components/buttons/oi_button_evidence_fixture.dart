import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/paint_pixels.dart';

const ValueKey<String> buttonEvidenceKey = ValueKey('button-evidence');
const buttonEvidenceFrame = Size(320, 96);

TextStyle buttonEvidenceStyle(String family, double size, double line) =>
    TextStyle(
      fontFamily: family,
      fontSize: size,
      height: line / size,
      fontWeight: FontWeight.w500,
      fontVariations: const [
        FontVariation('wght', 500),
        FontVariation('wdth', 100),
      ],
      leadingDistribution: TextLeadingDistribution.even,
      letterSpacing: size == 15 ? .045 : .042,
    );

Future<PaintPixels> captureButtonEvidence(
  WidgetTester tester,
  Widget button, {
  OiThemeData? theme,
  OiDensity density = OiDensity.compact,
  TextDirection direction = TextDirection.ltr,
  OiInputModality modality = OiInputModality.pointer,
}) => tester.capturePaint(
  _ButtonEvidenceFrame(
    theme: theme ?? OiThemeData.light(),
    density: density,
    direction: direction,
    modality: modality,
    child: button,
  ),
  size: buttonEvidenceFrame,
);

RenderParagraph buttonEvidenceParagraph(WidgetTester tester, String label) =>
    tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byKey(buttonEvidenceKey),
        matching: find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText() == label,
        ),
      ),
    );

class _ButtonEvidenceFrame extends StatelessWidget {
  const _ButtonEvidenceFrame({
    required this.theme,
    required this.density,
    required this.direction,
    required this.modality,
    required this.child,
  });

  final OiThemeData theme;
  final OiDensity density;
  final TextDirection direction;
  final OiInputModality modality;
  final Widget child;

  @override
  Widget build(BuildContext context) => OiTheme(
    data: theme,
    child: OiDensityScope(
      density: density,
      child: OiPlatform(
        data: OiPlatformData(
          platform: TargetPlatform.linux,
          keyboardHeight: 0,
          keyboardVisible: false,
          inputModality: modality,
        ),
        child: Directionality(
          textDirection: direction,
          child: ColoredBox(
            color: theme.colors.background,
            child: Center(child: child),
          ),
        ),
      ),
    ),
  );
}
