part of '../oi_app.dart';

class _OiAppState extends State<OiApp> {
  late final OiUndoStack _undoStack;
  late final OiOverlaysService _overlaysService;
  final HeroController _heroController = HeroController();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) unawaited(BrowserContextMenu.disableContextMenu());
    _undoStack = OiUndoStack(maxHistory: widget.undoStackMaxHistory);
    _overlaysService = createOiOverlaysService();
  }

  @override
  void dispose() {
    _undoStack.dispose();
    super.dispose();
  }

  OiThemeData _resolveTheme(Brightness platformBrightness) {
    final lightTheme = widget.theme ?? OiThemeData.light();
    // When darkTheme is null, use the primary (light) theme for both modes.
    final darkTheme = widget.darkTheme ?? lightTheme;

    OiThemeData resolved;
    switch (widget.themeMode) {
      case OiThemeMode.light:
        resolved = lightTheme;
      case OiThemeMode.dark:
        resolved = darkTheme;
      case OiThemeMode.system:
        resolved = platformBrightness == Brightness.dark
            ? darkTheme
            : lightTheme;
    }

    if (widget.performanceConfig != null) {
      return resolved.copyWith(performanceConfig: widget.performanceConfig);
    }
    return resolved;
  }

  OiDensity _resolveDensity() {
    if (widget.density != null) return widget.density!;
    // Auto-detect: use comfortable on touch devices
    if (kIsWeb) return OiDensity.compact;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return OiDensity.comfortable;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return OiDensity.compact;
    }
  }

  /// Maps a [Locale] to the appropriate [TextDirection].
  ///
  /// RTL is used for Arabic, Hebrew, Persian, Urdu, and related scripts.
  /// Falls back to [TextDirection.ltr] when [locale] is null.
  TextDirection _resolveTextDirection(Locale? locale) {
    if (locale == null) return TextDirection.ltr;
    const rtlLanguageCodes = {
      'ar', // Arabic
      'he', // Hebrew
      'fa', // Persian / Farsi
      'ur', // Urdu
      'ps', // Pashto
      'sd', // Sindhi
      'ug', // Uyghur
      'yi', // Yiddish
      'dv', // Divehi / Maldivian
    };
    return rtlLanguageCodes.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Builds the full injection scaffold that wraps the navigated content.
  ///
  /// Injection order (outermost → innermost):
  /// [OiTheme] → [Directionality] → [OiDensityScope] → [OiA11yScope]
  /// → [OiInputModalityDetector] (provides [OiPlatform])
  /// → [OiUndoStackProvider] → [OiShortcutScope]
  /// → [OiTourScope] → OiOverlaysHost
  Widget _buildScaffold(BuildContext context, Widget? child) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    var themeData = _resolveTheme(platformBrightness);

    if (MediaQuery.disableAnimationsOf(context)) {
      themeData = themeData.copyWith(
        animations: themeData.animations.copyWith(
          fast: Duration.zero,
          normal: Duration.zero,
          slow: Duration.zero,
          reducedMotion: true,
          pageTransitionDuration: Duration.zero,
        ),
      );
    }

    Widget result = OiTheme(
      data: themeData,
      child: ColoredBox(
        color: themeData.colors.background,
        child: Directionality(
          textDirection: _resolveTextDirection(widget.locale),
          child: OiDensityScope(
            density: _resolveDensity(),
            child: OiA11yScope(
              child: OiInputModalityDetector(
                child: OiUndoStackProvider(
                  stack: _undoStack,
                  child: OiShortcutScope(
                    child: OiTourScope(
                      child: OiSelectScope(
                        child: buildOiOverlaysHost(
                          service: _overlaysService,
                          child: child ?? const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    result = ScrollConfiguration(
      behavior: const OiScrollBehavior(),
      child: FocusTraversalGroup(
        policy: _OiAttachedReadingOrderTraversalPolicy(),
        child: result,
      ),
    );

    if (widget.settingsDriver != null) {
      result = OiSettingsProvider(
        driver: widget.settingsDriver!,
        child: result,
      );
    }

    // Provide a HeroController for router-based navigation where
    // navigatorObservers is not available on WidgetsApp.router.
    if (widget._useRouter) {
      result = HeroControllerScope(
        controller: _heroController,
        child: result,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: themeData.colors.background.computeLuminance() > 0.5
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget._useRouter) {
      return WidgetsApp.router(
        color: const Color(0xFF2563EB),
        locale: widget.locale,
        localizationsDelegates: widget.localizationsDelegates,
        supportedLocales: widget.supportedLocales,
        title: widget.title,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        routerConfig: widget.routerConfig,
        builder: _buildScaffold,
      );
    }

    return WidgetsApp(
      color: const Color(0xFF2563EB),
      locale: widget.locale,
      localizationsDelegates: widget.localizationsDelegates,
      supportedLocales: widget.supportedLocales,
      title: widget.title,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      navigatorObservers: [HeroController()],
      pageRouteBuilder: <T>(settings, builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
      builder: _buildScaffold,
      home: widget.home,
    );
  }
}
