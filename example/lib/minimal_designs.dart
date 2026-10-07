import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Run with `flutter run -t lib/minimal_designs.dart -d chrome`.
void main() => runApp(const MinimalDesignApp());

/// Two independent visual systems built with the same public library modules.
class MinimalDesignApp extends StatefulWidget {
  /// Creates the standalone component example.
  const MinimalDesignApp({super.key});

  @override
  State<MinimalDesignApp> createState() => _MinimalDesignAppState();
}

class _MinimalDesignAppState extends State<MinimalDesignApp> {
  bool _quiet = true;

  @override
  Widget build(BuildContext context) => OiApp(
    theme: minimalDesignTheme(quiet: _quiet),
    home: MinimalDesignScreen(
      quiet: _quiet,
      onChangeDesign: () => setState(() => _quiet = !_quiet),
    ),
  );
}

/// Component tokens for the reference album and an unrelated workshop design.
OiThemeData minimalDesignTheme({required bool quiet}) {
  const ink = Color(0xff22201c);
  const ground = Color(0xfff6f3ee);
  const surface = Color(0xfffffefc);
  const sand = Color(0xffece8e1);
  final base = OiThemeData.fromBrand(
    color: quiet ? const Color(0xff8a3b2d) : const Color(0xff155eef),
    fontFamily: 'Figtree',
    radiusPreference: quiet
        ? OiRadiusPreference.rounded
        : OiRadiusPreference.sharp,
  );
  final colors = quiet
      ? base.colors.copyWith(
          background: ground,
          surface: surface,
          surfaceSubtle: sand,
          surfaceHover: sand,
          surfaceActive: sand,
          text: ink,
          textSubtle: const Color(0xff6e6a63),
          textMuted: const Color(0xffc9c3b9),
          border: const Color(0xffe3ded5),
        )
      : base.colors;
  final horizontal = OiResponsive<EdgeInsetsGeometry>.breakpoints({
    OiBreakpoint.compact: const EdgeInsets.symmetric(horizontal: 24),
    OiBreakpoint.expanded: const EdgeInsets.symmetric(horizontal: 48),
  });
  return base.copyWith(
    colors: colors,
    textTheme: base.textTheme.copyWith(
      headingScale: OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.expanded: quiet ? 44 / 34 : 1.2,
      }),
      textHeightBehavior: const TextHeightBehavior(
        leadingDistribution: TextLeadingDistribution.even,
      ),
      h1: TextStyle(
        fontFamily: quiet ? 'Newsreader' : 'Figtree',
        fontSize: quiet ? 34 : 32,
        height: 1.08,
        fontWeight: quiet ? FontWeight.w500 : FontWeight.w800,
        letterSpacing: quiet ? -.34 : -1,
        color: colors.text,
      ),
      body: TextStyle(
        fontFamily: 'Figtree',
        fontSize: 16,
        height: 1.5,
        color: colors.textSubtle,
      ),
    ),
    components: base.components.copyWith(
      dockedPage: OiDockedPageThemeData(
        maxWidth: 1136,
        headerPadding: horizontal,
        bodyPadding: const OiResponsive<EdgeInsetsGeometry>(EdgeInsets.all(24)),
        bodyPaddingWithHeader: OiResponsive<EdgeInsetsGeometry>.breakpoints({
          OiBreakpoint.compact: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          OiBreakpoint.expanded: const EdgeInsets.fromLTRB(48, 8, 48, 32),
        }),
        dockPadding: OiResponsive<EdgeInsetsGeometry>.breakpoints({
          OiBreakpoint.compact: const EdgeInsets.fromLTRB(24, 12, 24, 34),
          OiBreakpoint.expanded: const EdgeInsets.symmetric(
            horizontal: 48,
            vertical: 16,
          ),
        }),
        dockDecoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
      ),
      button: OiButtonThemeData(
        largeHeight: 52,
        mediumHeight: 44,
        borderRadius: quiet ? BorderRadius.circular(999) : BorderRadius.zero,
      ),
      choiceScale: OiChoiceScaleThemeData(
        labelStyle: TextStyle(
          fontFamily: 'Figtree',
          fontSize: 13,
          height: 1.2,
          fontWeight: FontWeight.w500,
          color: colors.textSubtle,
        ),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: colors.text,
        ),
        markerColor: colors.textMuted,
        lineColor: colors.border,
      ),
      mediaTile: OiMediaTileThemeData(
        borderRadius: quiet ? BorderRadius.circular(24) : BorderRadius.zero,
        selectedBorder: quiet
            ? null
            : BorderSide(color: colors.primary.base, width: 3),
        unselectedOpacity: quiet ? .38 : .6,
        desaturateUnselected: quiet,
      ),
    ),
  );
}

/// Interactive controlled-state examples, with no application-model dependency.
class MinimalDesignScreen extends StatefulWidget {
  /// Creates a design demonstration using optional caller-provided media.
  const MinimalDesignScreen({
    required this.quiet,
    required this.onChangeDesign,
    this.image,
    super.key,
  });

  /// Whether the Quiet Album visual system is active.
  final bool quiet;

  /// Switches to the other visual system.
  final VoidCallback onChangeDesign;

  /// Optional media provider; defaults to the example's bundled photo.
  final ImageProvider<Object>? image;

  @override
  State<MinimalDesignScreen> createState() => _MinimalDesignScreenState();
}

class _MinimalDesignScreenState extends State<MinimalDesignScreen> {
  int _choice = 2;
  bool _selected = true;
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final quiet = widget.quiet;
    final labels = quiet
        ? ['Gentle', 'Calm', 'Bright', 'Upbeat', 'Punchy']
        : ['Basic', 'Light', 'Everyday', 'Pro', 'Expert'];
    final media = OiMediaTile(
      label: quiet ? 'Include this moment' : 'Include this workshop kit',
      selected: _selected,
      onChanged: (value) => setState(() {
        _selected = value;
        _saved = false;
      }),
      aspectRatio: 4 / 5,
      overlays: [
        PositionedDirectional(
          start: context.spacing.md,
          end: context.spacing.md,
          bottom: context.spacing.md,
          child: OiSurface(
            color: context.colors.surface,
            padding: EdgeInsets.all(context.spacing.sm),
            child: OiLabel.body(_selected ? 'Included' : 'Tap to include'),
          ),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, bounds) => OiImage.provider(
          provider:
              widget.image ??
              const AssetImage('assets/minimal_designs/photo.png'),
          alt: quiet ? 'A quiet moment' : 'Example kit photograph',
          fit: BoxFit.cover,
          cacheWidth: (bounds.maxWidth * MediaQuery.devicePixelRatioOf(context))
              .ceil(),
          cacheHeight:
              (bounds.maxHeight * MediaQuery.devicePixelRatioOf(context))
                  .ceil(),
        ),
      ),
    );
    final controls = OiColumn(
      breakpoint: context.breakpoint,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      gap: OiResponsive(context.spacing.md),
      children: [
        OiBalancedText(quiet ? 'Last two weeks' : 'Choose your workshop kit'),
        OiLabel.body(
          quiet ? 'How should it feel?' : 'Choose a kit for your experience.',
        ),
        OiChoiceScale<int>(
          label: quiet ? 'Mood' : 'Experience level',
          value: _choice,
          options: [
            for (final (i, label) in labels.indexed)
              OiChoiceScaleOption(value: i, label: label),
          ],
          onChanged: (value) => setState(() {
            _choice = value;
            _saved = false;
          }),
        ),
        OiLabel.body('Selected: ${labels[_choice]}'),
      ],
    );
    return OiDockedPage(
      header: SizedBox(
        height: 64,
        child: OiRow(
          breakpoint: context.breakpoint,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OiLabel.body(quiet ? 'Quiet Album' : 'Workshop'),
            OiButton.icon(
              icon: OiIcons.settings,
              label: 'Change design',
              onTap: widget.onChangeDesign,
            ),
          ],
        ),
      ),
      dock: OiButton.primary(
        label: _saved ? 'Selection saved' : 'Save selection',
        size: OiButtonSize.large,
        onTap: _selected ? () => setState(() => _saved = true) : null,
        enabled: _selected,
      ),
      child: LayoutBuilder(
        builder: (context, bounds) => context.isExpandedOrWider
            ? OiRow(
                breakpoint: context.breakpoint,
                crossAxisAlignment: CrossAxisAlignment.start,
                gap: OiResponsive(context.spacing.xl),
                children: [
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: media,
                      ),
                    ),
                  ),
                  SizedBox(width: 400, child: controls),
                ],
              )
            : OiColumn(
                breakpoint: context.breakpoint,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                gap: OiResponsive(context.spacing.xl),
                children: [media, controls],
              ),
      ),
    );
  }
}
