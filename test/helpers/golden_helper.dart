import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

/// Builds an Alchemist [GoldenTestGroup] of named scenarios, each wrapped in an
/// [OiApp] so the widget has the full obers theme / density / a11y / overlay
/// context (the same context it gets in a real app).
///
/// Pass the result as the `builder` of [goldenTest]:
/// ```dart
/// await goldenTest(
///   'OiButton variants',
///   fileName: 'oi_button_variants',
///   builder: () => obersGoldenGroup(
///     columns: 3,
///     children: {
///       'Primary': const OiButton.primary(label: 'Click'),
///       'Secondary': const OiButton.secondary(label: 'Click'),
///     },
///   ),
/// );
/// ```
Widget obersGoldenGroup({
  required Map<String, Widget> children,
  int columns = 2,
  OiThemeData? theme,
  Size cellSize = const Size(260, 96),
}) {
  return GoldenTestGroup(
    columns: columns,
    children: [
      for (final entry in children.entries)
        GoldenTestScenario(
          name: entry.key,
          child: _ObersGoldenCell(
            theme: theme,
            size: cellSize,
            child: entry.value,
          ),
        ),
    ],
  );
}

/// Wraps a single scenario child in [OiApp].
///
/// [OiApp] mounts a full-screen `Overlay` (`OiOverlaysHost`) and a `WidgetsApp`,
/// neither of which shrink-wraps. Alchemist measures each scenario with
/// unbounded constraints, so the cell is given a bounded box: the app sizes to
/// it, the Overlay is happy, and content is centered without clipping.
class _ObersGoldenCell extends StatelessWidget {
  const _ObersGoldenCell({
    required this.child,
    required this.size,
    this.theme,
  });

  final Widget child;
  final Size size;
  final OiThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: OiApp(
        theme: theme ?? OiThemeData.light(),
        home: Center(child: child),
      ),
    );
  }
}
