// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/foundation/oi_shortcut_scope.dart';
import 'package:obers_ui/src/foundation/oi_tour_scope.dart';
import 'package:obers_ui/src/foundation/oi_undo_stack.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

// ---------------------------------------------------------------------------
// Minimal router helpers used by OiApp.router() tests
// ---------------------------------------------------------------------------

class _TestRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _TestRouterDelegate(this._child);

  final Widget _child;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) =>
          PageRouteBuilder<void>(pageBuilder: (_, __, ___) => _child),
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

RouterConfig<Object> _testRouterConfig(Widget child) {
  return RouterConfig<Object>(routerDelegate: _TestRouterDelegate(child));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('OiApp', () {
    // ── REQ-0032: injection chain ──────────────────────────────────────────

    // TC-01
    testWidgets('provides OiTheme to descendants', (tester) async {
      late OiThemeData? capturedTheme;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (ctx) {
              capturedTheme = OiTheme.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(capturedTheme, isNotNull);
    });

    // TC-02
    testWidgets('provides OiUndoStack to descendants', (tester) async {
      late OiUndoStack? captured;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (ctx) {
              captured = OiUndoStack.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, isNotNull);
    });

    // TC-03
    testWidgets('provides OiPlatform to descendants', (tester) async {
      late OiPlatformData? captured;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (ctx) {
              captured = OiPlatform.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, isNotNull);
    });

    // TC-04
    testWidgets('provides OiA11yScope to descendants', (tester) async {
      late OiA11yScope? captured;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (ctx) {
              captured = ctx.findAncestorWidgetOfExactType<OiA11yScope>();
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, isNotNull);
    });

    // TC-05
    testWidgets('provides OiShortcutScope to descendants', (tester) async {
      late OiShortcutScopeState? captured;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (ctx) {
              captured = OiShortcutScope.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, isNotNull);
    });

    // TC-06
    testWidgets('provides OiTourScope to descendants', (tester) async {
      late OiTourScopeData? captured;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (ctx) {
              captured = OiTourScope.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, isNotNull);
    });

    // TC-07
    testWidgets('OiApp.router() provides OiTheme to descendants', (
      tester,
    ) async {
      late OiThemeData? capturedTheme;
      final child = Builder(
        builder: (ctx) {
          capturedTheme = OiTheme.maybeOf(ctx);
          return const SizedBox();
        },
      );
      await tester.pumpWidget(
        OiApp.router(routerConfig: _testRouterConfig(child)),
      );
      await tester.pump();
      expect(capturedTheme, isNotNull);
    });

    // TC-08
    testWidgets('OiApp.router() provides OiUndoStack to descendants', (
      tester,
    ) async {
      late OiUndoStack? captured;
      final child = Builder(
        builder: (ctx) {
          captured = OiUndoStack.maybeOf(ctx);
          return const SizedBox();
        },
      );
      await tester.pumpWidget(
        OiApp.router(routerConfig: _testRouterConfig(child)),
      );
      await tester.pump();
      expect(captured, isNotNull);
    });

    // ── REQ-0033: theme mode ───────────────────────────────────────────────

    // TC-09
    testWidgets('light themeMode uses light theme', (tester) async {
      final lightTheme = OiThemeData.light();
      late OiThemeData? captured;
      await tester.pumpWidget(
        OiApp(
          theme: lightTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (ctx) {
              captured = OiTheme.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured?.isLight, isTrue);
    });

    // TC-10
    testWidgets('dark themeMode uses dark theme', (tester) async {
      final darkTheme = OiThemeData.dark();
      late OiThemeData? captured;
      await tester.pumpWidget(
        OiApp(
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (ctx) {
              captured = OiTheme.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured?.isDark, isTrue);
    });

    // TC-11
    testWidgets('darkTheme=null + themeMode=dark uses light theme', (
      tester,
    ) async {
      final lightTheme = OiThemeData.light();
      late OiThemeData? captured;
      await tester.pumpWidget(
        OiApp(
          theme: lightTheme,
          // darkTheme intentionally omitted (null)
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (ctx) {
              captured = OiTheme.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured?.isLight, isTrue);
    });

    // TC-12
    testWidgets('themeMode=system + dark platform uses dark theme', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final darkTheme = OiThemeData.dark();
      late OiThemeData? captured;
      await tester.pumpWidget(
        OiApp(
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: Builder(
            builder: (ctx) {
              captured = OiTheme.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured?.isDark, isTrue);
    });

    // TC-13
    testWidgets('themeMode=system + light platform uses light theme', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final lightTheme = OiThemeData.light();
      late OiThemeData? captured;
      await tester.pumpWidget(
        OiApp(
          theme: lightTheme,
          themeMode: ThemeMode.system,
          home: Builder(
            builder: (ctx) {
              captured = OiTheme.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured?.isLight, isTrue);
    });

    // ── REQ-0034: locale / directionality ─────────────────────────────────

    // TC-14
    testWidgets('locale=ar resolves TextDirection.rtl', (tester) async {
      late TextDirection? captured;
      await tester.pumpWidget(
        OiApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          home: Builder(
            builder: (ctx) {
              captured = Directionality.of(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, equals(TextDirection.rtl));
    });

    // TC-15
    testWidgets('locale=en resolves TextDirection.ltr', (tester) async {
      late TextDirection? captured;
      await tester.pumpWidget(
        OiApp(
          locale: const Locale('en'),
          home: Builder(
            builder: (ctx) {
              captured = Directionality.of(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, equals(TextDirection.ltr));
    });

    // TC-16
    testWidgets('locale=null defaults to TextDirection.ltr', (tester) async {
      late TextDirection? captured;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (ctx) {
              captured = Directionality.of(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, equals(TextDirection.ltr));
    });

    // TC-17
    testWidgets('supportedLocales are forwarded to WidgetsApp', (tester) async {
      const locales = [Locale('fr'), Locale('de')];
      await tester.pumpWidget(
        OiApp(
          locale: const Locale('fr'),
          supportedLocales: locales,
          home: const SizedBox(),
        ),
      );
      final widgetsApp = tester.widget<WidgetsApp>(find.byType(WidgetsApp));
      expect(widgetsApp.supportedLocales, equals(locales));
    });

    // ── REQ-0024: MediaQuery.disableAnimationsOf → OiAnimationConfig ─────

    // TC-18
    testWidgets(
      'MediaQuery.disableAnimationsOf flows to OiAnimationConfig.reducedMotion',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );

        late OiThemeData? captured;
        await tester.pumpWidget(
          OiApp(
            home: Builder(
              builder: (ctx) {
                captured = OiTheme.maybeOf(ctx);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(captured?.animations.reducedMotion, isTrue);
      },
    );

    // ── Existing density test (kept) ───────────────────────────────────────

    testWidgets('OiDensityScope is provided', (tester) async {
      late OiDensity? captured;
      await tester.pumpWidget(
        OiApp(
          density: OiDensity.dense,
          home: Builder(
            builder: (ctx) {
              captured = OiDensityScope.of(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, equals(OiDensity.dense));
    });
  });
}
