import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

// ── Data classes ────────────────────────────────────────────────────────────

/// A single color slot in an [OiColorPalettePicker].
///
/// Each slot has a unique [id], a human-readable [label], and an optional
/// [value]. When [value] is `null` the slot is considered unset and renders
/// as an empty dashed circle.
///
/// {@category Components}
@immutable
class OiColorSlot {
  /// Creates an [OiColorSlot].
  const OiColorSlot({required this.id, required this.label, this.value});

  /// Unique identifier for this slot (e.g. `'primary'`, `'accent'`).
  final String id;

  /// Human-readable name displayed below the circle in non-compact mode.
  final String label;

  /// The color assigned to this slot, or `null` if unset.
  final Color? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiColorSlot &&
          id == other.id &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => Object.hash(id, label, value);
}

/// A named collection of colors that can be applied to an
/// [OiColorPalettePicker] in one action.
///
/// {@category Components}
@immutable
class OiColorPalette {
  /// Creates an [OiColorPalette].
  const OiColorPalette({
    required this.id,
    required this.name,
    required this.colors,
    this.category = '',
  });

  /// Unique identifier for this palette.
  final String id;

  /// Display name shown on the preset card.
  final String name;

  /// Optional category grouping (e.g. `'warm'`, `'cool'`).
  final String category;

  /// A map of slot IDs to colors. Keys correspond to [OiColorSlot.id].
  final Map<String, Color> colors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiColorPalette &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          mapEquals(colors, other.colors);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    Object.hashAll(colors.entries.map((e) => Object.hash(e.key, e.value))),
  );
}

// ── Widget ──────────────────────────────────────────────────────────────────

/// A multi-slot color palette picker with optional preset palettes.
///
/// Displays a horizontal row of color circles — one per [OiColorSlot]. Slots
/// with a [OiColorSlot.value] render as filled circles; unset slots render
/// with a dashed border. Each circle is tappable and fires [onSlotChanged].
///
/// When [showPresets] is `true` and [presets] is non-null, a scrollable list
/// of preset palette cards is shown below the slot row. Tapping a card fires
/// [onPresetSelected].
///
/// ```dart
/// OiColorPalettePicker(
///   label: 'Brand colors',
///   slots: [
///     OiColorSlot(id: 'primary', label: 'Primary', value: Color(0xFF3B82F6)),
///     OiColorSlot(id: 'accent', label: 'Accent'),
///   ],
///   onSlotChanged: (slotId, color) { /* ... */ },
/// )
/// ```
///
/// {@category Components}
class OiColorPalettePicker extends StatelessWidget {
  /// Creates an [OiColorPalettePicker].
  const OiColorPalettePicker({
    required this.slots,
    required this.onSlotChanged,
    required this.label,
    this.compact = true,
    this.presets,
    this.onPresetSelected,
    this.showPresets = true,
    this.lockSlotIds = const <String>{},
    this.onRandomize,
    super.key,
  });

  /// The color slots to display.
  final List<OiColorSlot> slots;

  /// Called when a slot circle is tapped.
  ///
  /// The consumer is responsible for opening a color picker or otherwise
  /// determining the new color.
  final void Function(String slotId, Color color) onSlotChanged;

  /// Accessibility label for the entire picker.
  final String label;

  /// When `true` (default), slot labels below each circle are hidden.
  final bool compact;

  /// Optional list of preset palettes to display.
  final List<OiColorPalette>? presets;

  /// Called when a preset palette card is tapped.
  final void Function(OiColorPalette)? onPresetSelected;

  /// Whether to show the presets section. Defaults to `true`.
  final bool showPresets;

  /// IDs of slots that are read-only and cannot be changed by tapping.
  ///
  /// Locked slots render with a reduced opacity to signal they are immutable.
  final Set<String> lockSlotIds;

  /// Called when the user taps a "randomize" button to generate a new palette.
  ///
  /// When non-null, a shuffle button is shown below the slot row.
  final VoidCallback? onRandomize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Slot circles ──────────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: slots.map((slot) {
                  final hasValue = slot.value != null;
                  final isLocked = lockSlotIds.contains(slot.id);
                  Widget circle = SizedBox(
                    width: 28,
                    height: 28,
                    child: hasValue
                        ? DecoratedBox(
                            decoration: BoxDecoration(
                              color: slot.value,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.border),
                            ),
                          )
                        : CustomPaint(
                            painter: _DashedCirclePainter(color: colors.border),
                          ),
                  );

                  // Overlay a lock icon on locked slots.
                  if (isLocked) {
                    circle = Stack(
                      children: [
                        circle,
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: OiIcon.decorative(
                              icon: OiIcons.lock,
                              size: 10,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Opacity(
                    opacity: isLocked ? 0.5 : 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PaletteColorSwatch(
                          child: circle,
                          enabled: !isLocked,
                          semanticLabel: slot.label,
                          onTap: isLocked
                              ? null
                              : () => onSlotChanged(
                                  slot.id,
                                  slot.value ?? colors.primary.base,
                                ),
                        ),
                        if (!compact) ...[
                          SizedBox(height: spacing.xs),
                          OiLabel.tiny(slot.label, color: colors.textMuted),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (onRandomize != null) ...[
                SizedBox(width: spacing.sm),
                OiButton.ghost(
                  label: 'Randomize',
                  icon: OiIcons.shuffle,
                  onTap: onRandomize,
                  size: OiButtonSize.small,
                ),
              ],
            ],
          ),

          // ── Presets section ───────────────────────────────────────────
          if (showPresets && presets != null && presets!.isNotEmpty) ...[
            SizedBox(height: spacing.md),
            ...presets!.map((palette) {
              return Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: GestureDetector(
                  onTap: onPresetSelected != null
                      ? () => onPresetSelected!(palette)
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.borderSubtle),
                      borderRadius: context.radius.md,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: spacing.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Small color circles for the preset.
                          ...palette.colors.values.map((c) {
                            return Padding(
                              padding: EdgeInsets.only(right: spacing.xs),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.border,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          SizedBox(width: spacing.xs),
                          OiLabel.small(palette.name),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ── Dashed circle painter ───────────────────────────────────────────────────

/// Paints a dashed circle outline to indicate an unset color slot.
class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addOval(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2));

    const dashLength = 4.0;
    const gapLength = 3.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      color != oldDelegate.color;
}

// ── Hover-aware color swatch ────────────────────────────────────────────────

class _PaletteColorSwatch extends StatefulWidget {
  const _PaletteColorSwatch({
    required this.child,
    required this.enabled,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final bool enabled;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<_PaletteColorSwatch> createState() => _PaletteColorSwatchState();
}

class _PaletteColorSwatchState extends State<_PaletteColorSwatch> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final highlighted = _hovered && widget.enabled;

    Widget swatch = Container(
      width: 28,
      height: 28,
      decoration: highlighted
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.base,
                width: 2.5,
              ),
            )
          : null,
      child: widget.child,
    );

    if (widget.semanticLabel != null) {
      swatch = Semantics(
        label: widget.semanticLabel,
        button: true,
        child: swatch,
      );
    }

    return MouseRegion(
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: swatch,
      ),
    );
  }
}
