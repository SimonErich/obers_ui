import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// Mutable state backing an [OiFormDialogController].
class _OiFormDialogData {
  bool loading = false;
  String? error;
  bool submitEnabled = true;
}

/// Controls the state of a dialog shown by [OiFormDialog.showCustom].
///
/// The controller is passed to the `builder` callback and provides methods
/// to submit a result, cancel, toggle loading state, set an error message,
/// and enable/disable the submit button.
///
/// {@category Composites}
class OiFormDialogController<T> {
  OiFormDialogController._(this._data, this._notify, this._close);

  final _OiFormDialogData _data;
  final VoidCallback _notify;
  final void Function([T? result]) _close;

  /// Submits the dialog with the given [result].
  ///
  /// Sets the loading state to `true`, then closes the dialog and completes
  /// the [Future] returned by [OiFormDialog.showCustom] with [result].
  Future<void> submit(T result) async {
    _data.loading = true;
    _notify();
    // Allow the UI to reflect the loading state before closing.
    await Future<void>.delayed(Duration.zero);
    _close(result);
  }

  /// Cancels the dialog without returning a result.
  void cancel() {
    _close();
  }

  /// Sets the loading state of the dialog.
  ///
  /// When loading, the submit button shows a spinner and barrier dismissal
  /// is blocked.
  void setLoading({required bool loading}) {
    _data.loading = loading;
    _notify();
  }

  /// Sets an error message displayed between the content and action buttons.
  ///
  /// Pass `null` to clear the error.
  void setError(String? message) {
    _data.error = message;
    _notify();
  }

  /// Enables or disables the submit button.
  void setSubmitEnabled({required bool enabled}) {
    _data.submitEnabled = enabled;
    _notify();
  }
}

/// A static-only utility for showing form dialogs with a managed lifecycle.
///
/// [OiFormDialog.showCustom] presents a modal dialog containing a title,
/// custom form content, an optional error area, and cancel/submit action
/// buttons. The dialog's state (loading, error, submit-enabled) is managed
/// through an [OiFormDialogController] provided to the builder.
///
/// ```dart
/// final result = await OiFormDialog.showCustom<String>(
///   context,
///   title: 'Create Item',
///   builder: (controller) {
///     return OiTextInput(
///       label: 'Name',
///       onChanged: (v) => controller.setSubmitEnabled(v.isNotEmpty),
///     );
///   },
/// );
/// ```
///
/// {@category Composites}
class OiFormDialog {
  const OiFormDialog._();

  /// Shows a dialog with custom form content and returns the submitted
  /// result, or `null` if the user cancels.
  ///
  /// The [builder] receives an [OiFormDialogController] that drives the
  /// dialog's loading, error, and submit-enabled states.
  ///
  /// - [title]: displayed as the dialog heading.
  /// - [submitLabel]: label for the primary action button (defaults to
  ///   `'Save'`).
  /// - [cancelLabel]: label for the cancel button (defaults to `'Cancel'`).
  /// - [dismissible]: whether tapping the barrier closes the dialog
  ///   (blocked while loading).
  /// - [maxWidth]: optional maximum width constraint for the dialog.
  /// - [semanticLabel]: accessibility label for the dialog.
  static Future<T?> showCustom<T>(
    BuildContext context, {
    required String title,
    required Widget Function(OiFormDialogController<T> controller) builder,
    String submitLabel = 'Save',
    String cancelLabel = 'Cancel',
    bool dismissible = true,
    double? maxWidth,
    String? semanticLabel,
  }) {
    return OiDialogShell.show<T>(
      context: context,
      barrierDismissible: dismissible,
      maxWidth: maxWidth,
      semanticLabel: semanticLabel ?? title,
      builder: (close) {
        return _OiFormDialogContent<T>(
          title: title,
          submitLabel: submitLabel,
          cancelLabel: cancelLabel,
          dismissible: dismissible,
          close: close,
          formBuilder: builder,
        );
      },
    );
  }
}

/// The stateful content rendered inside the dialog shell.
class _OiFormDialogContent<T> extends StatefulWidget {
  const _OiFormDialogContent({
    required this.title,
    required this.submitLabel,
    required this.cancelLabel,
    required this.dismissible,
    required this.close,
    required this.formBuilder,
    super.key,
  });

  final String title;
  final String submitLabel;
  final String cancelLabel;
  final bool dismissible;
  final void Function([T? result]) close;
  final Widget Function(OiFormDialogController<T> controller) formBuilder;

  @override
  State<_OiFormDialogContent<T>> createState() =>
      _OiFormDialogContentState<T>();
}

class _OiFormDialogContentState<T> extends State<_OiFormDialogContent<T>> {
  final _data = _OiFormDialogData();
  late final OiFormDialogController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = OiFormDialogController<T>._(
      _data,
      _rebuild,
      widget.close,
    );
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          OiLabel.h3(widget.title),
          SizedBox(height: spacing.md),

          // Form content
          widget.formBuilder(_controller),

          // Error message
          if (_data.error != null) ...[
            SizedBox(height: spacing.sm),
            OiLabel.small(
              _data.error!,
              color: colors.error.base,
            ),
          ],

          SizedBox(height: spacing.lg),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OiButton.ghost(
                label: widget.cancelLabel,
                onTap: _data.loading ? null : _controller.cancel,
              ),
              SizedBox(width: spacing.sm),
              OiButton.primary(
                label: widget.submitLabel,
                loading: _data.loading,
                enabled: _data.submitEnabled && !_data.loading,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
