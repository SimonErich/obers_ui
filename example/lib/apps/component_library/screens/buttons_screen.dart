import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for all button-related widgets.
class ButtonsScreen extends StatefulWidget {
  const ButtonsScreen({super.key});

  @override
  State<ButtonsScreen> createState() => _ButtonsScreenState();
}

class _ButtonsScreenState extends State<ButtonsScreen> {
  // Toggle button state
  bool _bold = false;
  bool _italic = false;
  bool _underline = true;

  // Sort button state
  OiSortOption _currentSort = const OiSortOption(field: 'name', label: 'Name');

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── OiButton ────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Button',
            widgetName: 'OiButton',
            description:
                'The primary interactive element. Supports multiple visual '
                'variants, sizes, icons, loading state, and disabled state.',
            examples: [
              ComponentExample(
                title: 'Variants',
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    OiButton.primary(label: 'Primary', onTap: () {}),
                    OiButton.secondary(label: 'Secondary', onTap: () {}),
                    OiButton.outline(label: 'Outline', onTap: () {}),
                    OiButton.ghost(label: 'Ghost', onTap: () {}),
                    OiButton.destructive(label: 'Destructive', onTap: () {}),
                    OiButton.soft(label: 'Soft', onTap: () {}),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Sizes',
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OiButton.primary(
                      label: 'Small',
                      size: OiButtonSize.small,
                      onTap: () {},
                    ),
                    OiButton.primary(label: 'Medium', onTap: () {}),
                    OiButton.primary(
                      label: 'Large',
                      size: OiButtonSize.large,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'States',
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: const [
                    OiButton.primary(label: 'Loading', loading: true),
                    OiButton.primary(label: 'Disabled'),
                    OiButton.outline(label: 'Disabled Outline'),
                  ],
                ),
              ),
              ComponentExample(
                title: 'With Icons',
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    OiButton.primary(
                      label: 'Save',
                      icon: OiIcons.save,
                      onTap: () {},
                    ),
                    OiButton.secondary(
                      label: 'Download',
                      icon: OiIcons.download,
                      onTap: () {},
                    ),
                    OiButton.outline(
                      label: 'Search',
                      icon: OiIcons.search,
                      onTap: () {},
                    ),
                    OiButton.destructive(
                      label: 'Delete',
                      icon: OiIcons.trash,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Icon-Only Buttons',
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    OiButton.icon(
                      icon: OiIcons.plus,
                      label: 'Add',
                      onTap: () {},
                    ),
                    OiButton.icon(
                      icon: OiIcons.settings,
                      label: 'Settings',
                      onTap: () {},
                    ),
                    OiButton.icon(
                      icon: OiIcons.heart,
                      label: 'Favourite',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiButtonGroup ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Button Group',
            widgetName: 'OiButtonGroup',
            description:
                'Groups related buttons together with shared styling and '
                'optional exclusive selection.',
            examples: [
              ComponentExample(
                title: 'Non-Exclusive Group',
                child: OiButtonGroup(
                  label: 'Actions',
                  items: [
                    OiButtonGroupItem(label: 'Cut', onTap: () {}),
                    OiButtonGroupItem(label: 'Copy', onTap: () {}),
                    OiButtonGroupItem(label: 'Paste', onTap: () {}),
                  ],
                ),
              ),
              ComponentExample(
                title: 'With Icons',
                child: OiButtonGroup(
                  label: 'Navigation',
                  items: [
                    OiButtonGroupItem(
                      label: 'Mail',
                      icon: OiIcons.mail,
                      onTap: () {},
                    ),
                    OiButtonGroupItem(
                      label: 'Search',
                      icon: OiIcons.search,
                      onTap: () {},
                    ),
                    OiButtonGroupItem(
                      label: 'Settings',
                      icon: OiIcons.settings,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiIconButton ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Icon Button',
            widgetName: 'OiIconButton',
            description:
                'A convenience wrapper around OiButton.icon for standalone '
                'icon-only buttons.',
            examples: [
              ComponentExample(
                title: 'Icon Buttons',
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    OiIconButton(
                      icon: OiIcons.heart,
                      semanticLabel: 'Like',
                      onTap: () {},
                    ),
                    OiIconButton(
                      icon: OiIcons.star,
                      semanticLabel: 'Star',
                      onTap: () {},
                    ),
                    OiIconButton(
                      icon: OiIcons.copy,
                      semanticLabel: 'Copy',
                      onTap: () {},
                    ),
                    OiIconButton(
                      icon: OiIcons.download,
                      semanticLabel: 'Download',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiToggleButton ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Toggle Button',
            widgetName: 'OiToggleButton',
            description:
                'A button that toggles between selected and unselected states. '
                'Ideal for formatting toolbars and binary options.',
            examples: [
              ComponentExample(
                title: 'Text Formatting Toggles',
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    OiToggleButton(
                      icon: OiIcons.bold,
                      selected: _bold,
                      semanticLabel: 'Bold',
                      onChanged: (value) => setState(() => _bold = value),
                    ),
                    OiToggleButton(
                      icon: OiIcons.italic,
                      selected: _italic,
                      semanticLabel: 'Italic',
                      onChanged: (value) => setState(() => _italic = value),
                    ),
                    OiToggleButton(
                      icon: OiIcons.underline,
                      selected: _underline,
                      semanticLabel: 'Underline',
                      onChanged: (value) => setState(() => _underline = value),
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Current State',
                child: OiLabel.small(
                  'Bold: $_bold, Italic: $_italic, Underline: $_underline',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiBackButton ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Back Button',
            widgetName: 'OiBackButton',
            description:
                'A themed back-navigation button with RTL-aware chevron icon.',
            examples: [
              ComponentExample(
                title: 'Default',
                child: OiBackButton(onPressed: () {}),
              ),
            ],
          ),

          // ── OiSortButton ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Sort Button',
            widgetName: 'OiSortButton',
            description:
                'A dropdown button for sorting lists. Displays the current '
                'sort field and direction with radio options.',
            examples: [
              ComponentExample(
                title: 'Sort Dropdown',
                child: OiSortButton(
                  label: 'Sort by',
                  options: const [
                    OiSortOption(field: 'name', label: 'Name'),
                    OiSortOption(field: 'date', label: 'Date'),
                    OiSortOption(field: 'size', label: 'Size'),
                  ],
                  currentSort: _currentSort,
                  onSortChange: (option) =>
                      setState(() => _currentSort = option),
                ),
              ),
            ],
          ),

          // ── OiExportButton ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Export Button',
            widgetName: 'OiExportButton',
            description:
                'A button that triggers data export. Supports single or '
                'multiple formats with a dropdown picker.',
            examples: [
              ComponentExample(
                title: 'Single Format',
                child: OiExportButton(
                  label: 'Export CSV',
                  onExport: (_) async {},
                ),
              ),
              ComponentExample(
                title: 'Multiple Formats',
                child: OiExportButton(
                  label: 'Export',
                  formats: const [
                    OiExportFormat.csv,
                    OiExportFormat.xlsx,
                    OiExportFormat.json,
                  ],
                  onExport: (_) async {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
