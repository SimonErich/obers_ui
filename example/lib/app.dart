import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/shell/home_screen.dart';
import 'package:obers_ui_example/shell/showcase_shell.dart';
import 'package:obers_ui_example/theme/alpine_theme.dart';
import 'package:obers_ui_example/theme/arco_theme.dart';
import 'package:obers_ui_example/theme/blue_danube_theme.dart';
import 'package:obers_ui_example/theme/finesse_theme.dart';
import 'package:obers_ui_example/theme/theme_state.dart';
import 'package:obers_ui_example/theme/vienna_night_theme.dart';

/// Root showcase application widget.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  final _themeState = ThemeState();

  @override
  void dispose() {
    _themeState.dispose();
    super.dispose();
  }

  OiThemeData _lightTheme(ThemePreset preset) => switch (preset) {
    ThemePreset.alpine => alpineTheme,
    ThemePreset.blueDanube => blueDanubeTheme,
    ThemePreset.arco => arcoTheme,
    ThemePreset.finesse => finesseTheme,
  };

  OiThemeData _darkTheme(ThemePreset preset) => switch (preset) {
    ThemePreset.alpine => viennaNightTheme,
    ThemePreset.blueDanube => blueDanubeDarkTheme,
    ThemePreset.arco => arcoDarkTheme,
    ThemePreset.finesse => finesseDarkTheme,
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OiThemeMode>(
      valueListenable: _themeState,
      builder: (context, mode, _) {
        return OiApp(
          title: 'obers_ui Showcase',
          theme: _lightTheme(_themeState.preset),
          darkTheme: _darkTheme(_themeState.preset),
          themeMode: mode,
          home: ShowcaseShell(
            title: 'obers_ui',
            themeState: _themeState,
            showBack: false,
            child: HomeScreen(themeState: _themeState),
          ),
        );
      },
    );
  }
}
