import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
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

  /// Creates a "Page not found" empty state (404).
  ///
  /// Accepts optional [title] override (defaults to "Page not found"),
  /// [description], [actionLabel] and [onAction] for a primary action button.
  factory OiEmptyState.notFound({
    String? title,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) {
    return OiEmptyState(
      key: key,
      title: title ?? 'Page not found',
      icon: const IconData(0xe894, fontFamily: 'MaterialIcons'), // search_off
      description: description,
      action: actionLabel != null && onAction != null
          ? OiButton.primary(
              label: actionLabel,
              onTap: onAction,
              semanticLabel: actionLabel,
            )
          : null,
    );
  }

  /// Creates an "Access denied" empty state (403).
  ///
  /// Accepts optional [title] override (defaults to "Access denied"),
  /// [description], [actionLabel] and [onAction] for a primary action button.
  factory OiEmptyState.forbidden({
    String? title,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) {
    return OiEmptyState(
      key: key,
      title: title ?? 'Access denied',
      icon: const IconData(0xe897, fontFamily: 'MaterialIcons'), // lock
      description: description,
      action: actionLabel != null && onAction != null
          ? OiButton.primary(
              label: actionLabel,
              onTap: onAction,
              semanticLabel: actionLabel,
            )
          : null,
    );
  }

  /// Creates a "Something went wrong" empty state (500).
  ///
  /// Accepts optional [title] override (defaults to "Something went wrong"),
  /// [description], [actionLabel], [onAction], and an optional [error] object
  /// whose `.toString()` is shown in debug mode only.
  factory OiEmptyState.error({
    String? title,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    Object? error,
    Key? key,
  }) {
    var resolvedDescription = description;
    if (error != null && kDebugMode) {
      final errorStr = error.toString();
      resolvedDescription = resolvedDescription != null
          ? '$resolvedDescription\n$errorStr'
          : errorStr;
    }
    return OiEmptyState(
      key: key,
      title: title ?? 'Something went wrong',
      icon: const IconData(0xe002, fontFamily: 'MaterialIcons'), // error
      description: resolvedDescription,
      action: actionLabel != null && onAction != null
          ? OiButton.primary(
              label: actionLabel,
              onTap: onAction,
              semanticLabel: actionLabel,
            )
          : null,
    );
  }

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
