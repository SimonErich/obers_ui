import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui/src/foundation/oi_app.dart' as direct;

void main() {
  test(
    'legacy root imports and const subclass constructors stay compatible',
    () {
      const app = _InheritedRoot();
      expect(app.home, isA<SizedBox>());
      expect(app.themeMode, direct.OiThemeMode.dark);
      expect(app.density, direct.OiDensity.dense);
      expect(identical(OiDensity.dense, direct.OiDensity.dense), isTrue);
      const scope = direct.OiDensityScope(
        density: direct.OiDensity.compact,
        child: SizedBox(),
      );
      expect(scope, isA<OiDensityScope>());
      expect(scope.density, OiDensity.compact);
    },
  );

  testWidgets(
    'OS motion preference preserves policy and restores authored timing',
    (
      tester,
    ) async {
      const lightMotion = OiAnimationConfig(
        fast: Duration(milliseconds: 120),
        normal: Duration(milliseconds: 200),
        slow: Duration(milliseconds: 320),
        reducedMotion: false,
        defaultPageTransition: OiPageTransitionType.slideHorizontal,
        pageTransitionDuration: Duration(milliseconds: 460),
        pageEntryCurve: Cubic(.2, .8, .2, 1),
        pageExitCurve: Cubic(.4, 0, 1, 1),
      );
      const darkMotion = OiAnimationConfig(
        fast: Duration(milliseconds: 130),
        normal: Duration(milliseconds: 210),
        slow: Duration(milliseconds: 330),
        reducedMotion: false,
        defaultPageTransition: OiPageTransitionType.scaleUp,
        pageTransitionDuration: Duration(milliseconds: 470),
        pageEntryCurve: Curves.bounceOut,
        pageExitCurve: Curves.linear,
      );
      const performance = OiPerformanceConfig.low();
      final light = OiThemeData.light().copyWith(animations: lightMotion);
      final dark = OiThemeData.dark().copyWith(animations: darkMotion);
      final platform = tester.platformDispatcher
        ..platformBrightnessTestValue = Brightness.light
        ..accessibilityFeaturesTestValue = const FakeAccessibilityFeatures();
      addTearDown(platform.clearPlatformBrightnessTestValue);
      addTearDown(platform.clearAccessibilityFeaturesTestValue);
      OiThemeData? captured;
      await tester.pumpWidget(
        OiApp(
          theme: light,
          darkTheme: dark,
          performanceConfig: performance,
          home: Builder(
            builder: (context) {
              captured = OiTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured!.animations, same(lightMotion));
      platform.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      await tester.pump();
      _expectReducedPolicy(captured!, light, performance);
      platform.platformBrightnessTestValue = Brightness.dark;
      await tester.pump();
      _expectReducedPolicy(captured!, dark, performance);
      platform.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures();
      await tester.pump();
      expect(captured!.animations, same(darkMotion));
      expect(captured!.colors, same(dark.colors));
      expect(captured!.performanceConfig, same(performance));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'OS motion policy never clears an authored reduced-motion choice',
    (
      tester,
    ) async {
      const authored = OiAnimationConfig(
        fast: Duration.zero,
        normal: Duration.zero,
        slow: Duration.zero,
        reducedMotion: true,
        defaultPageTransition: OiPageTransitionType.slideVertical,
        pageTransitionDuration: Duration.zero,
        pageEntryCurve: Curves.linear,
        pageExitCurve: Curves.bounceIn,
      );
      final platform = tester.platformDispatcher
        ..accessibilityFeaturesTestValue = const FakeAccessibilityFeatures();
      addTearDown(platform.clearAccessibilityFeaturesTestValue);
      final theme = OiThemeData.light().copyWith(animations: authored);
      OiAnimationConfig? captured;
      await tester.pumpWidget(
        OiApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              captured = OiTheme.of(context).animations;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, same(authored));
      platform.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      await tester.pump();
      expect(captured!.defaultPageTransition, authored.defaultPageTransition);
      expect(captured!.pageEntryCurve, same(authored.pageEntryCurve));
      expect(captured!.pageExitCurve, same(authored.pageExitCurve));
      platform.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures();
      await tester.pump();
      expect(captured, same(authored));
      expect(tester.takeException(), isNull);
    },
  );
}

class _InheritedRoot extends OiApp {
  const _InheritedRoot()
    : super(
        home: const SizedBox(),
        themeMode: OiThemeMode.dark,
        density: OiDensity.dense,
      );
}

void _expectReducedPolicy(
  OiThemeData actual,
  OiThemeData authored,
  OiPerformanceConfig performance,
) {
  final animations = actual.animations;
  expect(animations.reducedMotion, isTrue);
  expect(animations.fast, Duration.zero);
  expect(animations.normal, Duration.zero);
  expect(animations.slow, Duration.zero);
  expect(animations.pageTransitionDuration, Duration.zero);
  expect(
    animations.defaultPageTransition,
    authored.animations.defaultPageTransition,
  );
  expect(animations.pageEntryCurve, same(authored.animations.pageEntryCurve));
  expect(animations.pageExitCurve, same(authored.animations.pageExitCurve));
  expect(actual.colors, same(authored.colors));
  expect(actual.textTheme, same(authored.textTheme));
  expect(actual.effects, same(authored.effects));
  expect(actual.components, same(authored.components));
  expect(actual.performanceConfig, same(performance));
}
