import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// Displays a summary of all form validation errors.
///
/// Place inside an [OiFormScope] to automatically show all field errors.
///
/// ```dart
/// OiFormErrorSummary<SignupFields>()
/// ```
class OiFormErrorSummary<E extends Enum> extends StatelessWidget {
  const OiFormErrorSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OiFormScope.maybeOf<E>(context);
    if (controller == null) return const SizedBox.shrink();

    final errors = controller.getErrors();
    if (errors.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(spacing.sm),
        decoration: BoxDecoration(
          color: colors.error.light,
          borderRadius: context.radius.sm,
          border: Border.all(color: colors.error.base),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            OiLabel.smallStrong(
              'Please fix the following errors:',
              color: colors.error.base,
            ),
            SizedBox(height: spacing.xs),
            for (final entry in errors.entries)
              for (final error in entry.value)
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.xs / 2),
                  child: OiLabel.small(
                    '• ${entry.key.name}: $error',
                    color: colors.error.base,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
