import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A centered empty-state layout with an icon or illustration, title,
/// optional description, and an optional action widget.
///
/// Typically used to fill a container when there is no data to display.
///
/// {@category Components}
class OiEmptyState extends StatelessWidget {
  /// Creates an [OiEmptyState].
  const OiEmptyState({
    required this.title,
    this.icon,
    this.illustration,
    this.description,
    this.action,
    super.key,
  });

  /// An optional icon shown above the title.
  ///
  /// Ignored when [illustration] is provided.
  final IconData? icon;

  /// An optional custom illustration widget shown above the title.
  ///
  /// Takes priority over [icon].
  final Widget? illustration;

  /// The primary title text.
  final String title;

  /// Optional descriptive text rendered below [title].
  final String? description;

  /// Optional action widget (e.g. a button) rendered below the description.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: illustration,
              )
            else if (icon != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Icon(icon, size: 56, color: colors.textMuted),
              ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: colors.textMuted),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
