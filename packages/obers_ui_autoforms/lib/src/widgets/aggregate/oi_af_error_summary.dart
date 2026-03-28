import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiIcon, OiIcons, OiLabel, OiSurface;
import 'package:obers_ui/obers_ui.dart' show OiTheme;
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_controller.dart';
import 'package:obers_ui_autoforms/src/widgets/root/oi_af_scope.dart';

/// Displays a summary of all current form validation errors.
///
/// Global errors are shown first, followed by field-level errors in
/// registration order. Tapping a field error item focuses that field.
class OiAfErrorSummary<TField extends Enum> extends StatefulWidget {
  const OiAfErrorSummary({
    this.title,
    this.showFieldErrors = true,
    this.showGlobalErrors = true,
    this.showOnlyAfterSubmit = false,
    this.hideWhenEmpty = true,
    this.focusFieldOnTap = true,
    this.maxItems,
    super.key,
  });

  /// Optional title for the error summary.
  final String? title;

  /// Whether to show field-level errors.
  final bool showFieldErrors;

  /// Whether to show global (form-level) errors.
  final bool showGlobalErrors;

  /// Whether to show the summary only after a submit attempt.
  final bool showOnlyAfterSubmit;

  /// Whether to hide the widget when there are no errors.
  final bool hideWhenEmpty;

  /// Whether tapping a field error focuses that field.
  final bool focusFieldOnTap;

  /// Maximum number of error items to display.
  final int? maxItems;

  @override
  State<OiAfErrorSummary<TField>> createState() =>
      _OiAfErrorSummaryState<TField>();
}

class _OiAfErrorSummaryState<TField extends Enum>
    extends State<OiAfErrorSummary<TField>> {
  OiAfController<TField, Object?>? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller?.removeListener(_onChanged);
    _controller = OiAfScope.of<TField, Object?>(context);
    _controller!.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    if (ctrl == null) return const SizedBox.shrink();

    if (widget.showOnlyAfterSubmit && !ctrl.hasSubmitted) {
      return const SizedBox.shrink();
    }

    final items = ctrl.buildErrorSummaryItems();

    // Filter
    final filtered = items.where((item) {
      if (item.isGlobal && !widget.showGlobalErrors) return false;
      if (!item.isGlobal && !widget.showFieldErrors) return false;
      return true;
    }).toList();

    if (filtered.isEmpty && widget.hideWhenEmpty) {
      return const SizedBox.shrink();
    }

    final displayItems = widget.maxItems != null
        ? filtered.take(widget.maxItems!).toList()
        : filtered;

    final colors = OiTheme.of(context).colors;

    return Semantics(
      label: 'Form errors',
      child: OiSurface(
        color: colors.error.muted,
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null || displayItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const OiIcon.decorative(icon: OiIcons.alertCircle),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OiLabel.bodyStrong(
                        widget.title ??
                            '${displayItems.length} error${displayItems.length == 1 ? '' : 's'} found',
                      ),
                    ),
                  ],
                ),
              ),
            ...displayItems.map((item) {
              return GestureDetector(
                onTap: widget.focusFieldOnTap && item.field != null
                    ? () => ctrl.focusField(item.field!)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OiLabel.small('• '),
                      if (item.fieldLabel != null) ...[
                        OiLabel.smallStrong('${item.fieldLabel}: '),
                      ],
                      Expanded(child: OiLabel.small(item.message)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
