import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

/// A storybook-like interface to browse every component.
///
/// Renders a catalog of all obers_ui components organized by category,
/// with prop toggles and theme switching. Intended for use in the
/// example app or as a development tool.
///
/// {@category Tools}
class OiPlayground extends StatefulWidget {
  /// Creates an [OiPlayground].
  const OiPlayground({
    super.key,
    this.theme,
    this.darkTheme,
    this.initialCategory,
  });

  /// The light theme to use. Defaults to [OiThemeData.light].
  final OiThemeData? theme;

  /// The dark theme. Defaults to [OiThemeData.dark].
  final OiThemeData? darkTheme;

  /// The initial category to display.
  final String? initialCategory;

  @override
  State<OiPlayground> createState() => _OiPlaygroundState();
}

class _OiPlaygroundState extends State<OiPlayground> {
  late String _selectedCategory;
  bool _isDark = false;

  /// The categories available in the playground.
  static const categories = [
    'Buttons',
    'Inputs',
    'Display',
    'Feedback',
    'Overlays',
    'Navigation',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? categories.first;
  }

  OiThemeData get _effectiveTheme {
    if (_isDark) {
      return widget.darkTheme ?? OiThemeData.dark();
    }
    return widget.theme ?? OiThemeData.light();
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
  }

  @override
  Widget build(BuildContext context) {
    return OiTheme(
      data: _effectiveTheme,
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return ColoredBox(
            color: colors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(context),
                // Body
                Expanded(
                  child: Row(
                    children: [
                      // Sidebar
                      _buildSidebar(context),
                      // Content area
                      Expanded(child: _buildContent(context)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.surface,
      child: Row(
        children: [
          Text(
            'OiPlayground',
            key: const ValueKey('playground_title'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colors.text,
            ),
          ),
          const Spacer(),
          GestureDetector(
            key: const ValueKey('playground_theme_toggle'),
            onTap: _toggleTheme,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _isDark ? 'Light' : 'Dark',
                style: TextStyle(fontSize: 12, color: colors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 160,
      color: colors.surfaceSubtle,
      child: ListView(
        children: [
          for (final category in categories)
            GestureDetector(
              key: ValueKey('playground_cat_$category'),
              onTap: () => _selectCategory(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: _selectedCategory == category
                    ? colors.primary.base.withValues(alpha: 0.1)
                    : null,
                child: Text(
                  category,
                  style: TextStyle(
                    color: _selectedCategory == category
                        ? colors.primary.base
                        : colors.text,
                    fontWeight: _selectedCategory == category
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedCategory,
            key: const ValueKey('playground_category_title'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildSamples(context)),
        ],
      ),
    );
  }

  Widget _buildSamples(BuildContext context) {
    switch (_selectedCategory) {
      case 'Buttons':
        return _buildButtonSamples(context);
      case 'Inputs':
        return _buildInputSamples(context);
      case 'Display':
        return _buildDisplaySamples(context);
      default:
        return Center(
          child: Text(
            'Coming soon: $_selectedCategory',
            style: TextStyle(color: context.colors.textMuted),
          ),
        );
    }
  }

  Widget _buildButtonSamples(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OiButton.primary(label: 'Primary', onTap: () {}),
        OiButton.secondary(label: 'Secondary', onTap: () {}),
        OiButton.outline(label: 'Outline', onTap: () {}),
        OiButton.ghost(label: 'Ghost', onTap: () {}),
        const OiButton.primary(label: 'Disabled'),
      ],
    );
  }

  Widget _buildInputSamples(BuildContext context) {
    return ListView(
      children: const [
        OiTextInput(label: 'Text input'),
        SizedBox(height: 12),
        OiTextInput(label: 'Disabled input', enabled: false),
      ],
    );
  }

  Widget _buildDisplaySamples(BuildContext context) {
    return ListView(
      children: [
        const OiCard(child: Text('Sample card')),
        const SizedBox(height: 12),
        const OiBadge(label: 'Badge'),
        const SizedBox(height: 12),
        const OiProgress(value: 0.6, label: 'Progress'),
      ],
    );
  }
}
