import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_focus_trap.dart';

/// Shows a modal dialog and returns a future that completes when dismissed.
///
/// This is the recommended way to show dialogs that need to return a value.
/// The [builder] receives a `close` callback that dismisses the dialog and
/// completes the returned future with an optional result.
Future<T?> showOiDialog<T>(
  BuildContext context, {
  required Widget Function(
    BuildContext context,
    void Function([T? result]) close,
  )
  builder,
  bool dismissible = true,
  String? semanticLabel,
}) {
  return OiDialogShell.show<T>(
    context: context,
    semanticLabel: semanticLabel,
    barrierDismissible: dismissible,
    builder: (close) => builder(context, close),
  );
}

/// The visual / behavioural variant of an [OiDialog].
///
/// {@category Components}
enum OiDialogVariant {
  /// A standard dialog with title, content, and arbitrary actions.
  standard,

  /// An alert dialog: title, content, and a single "OK" action.
  alert,

  /// A confirmation dialog: title, content, and "Cancel" / "Confirm" actions.
  confirm,

  /// A form dialog: title, scrollable content area, and actions.
  form,

  /// A dialog that occupies the full screen.
  fullScreen,
}

/// A modal dialog overlay.
///
/// [OiDialog] renders a modal panel centred on screen (or full-screen when
/// using [OiDialog.fullScreen]). A semi-transparent scrim sits behind the
/// panel. [OiFocusTrap] keeps keyboard focus inside the dialog. Pressing
/// Escape calls [onClose]; tapping the scrim also calls [onClose] when
/// [dismissible] is `true`.
///
/// Use the named constructors for each dialog variant:
/// - [OiDialog.standard]: a general-purpose dialog with arbitrary actions.
/// - [OiDialog.alert]: a simple informational dialog with a single action.
/// - [OiDialog.confirm]: a dialog with "Cancel" / "Confirm" actions.
/// - [OiDialog.form]: a dialog with scrollable content for form inputs.
/// - [OiDialog.fullScreen]: a dialog that fills the entire screen.
///
/// Use the static [OiDialog.show] helper to push a dialog onto the widget
/// tree via the nearest [OiOverlays] service or, as a fallback, via the raw
/// [Overlay].
///
/// {@category Components}
class OiDialog extends StatelessWidget {
  // ── Private base constructor ──────────────────────────────────────────────

  const OiDialog._({
    required this.label,
    required this.variant,
    this.title,
    this.content,
    this.actions,
    this.onClose,
    this.onSave,
    this.unsavedChanges = false,
    this.dismissible = true,
    super.key,
  });

  // ── Named variant constructors ────────────────────────────────────────────

  /// Creates a standard dialog with title, content, and arbitrary actions.
  const OiDialog.standard({
    required String label,
    String? title,
    Widget? content,
    List<Widget>? actions,
    VoidCallback? onClose,
    bool dismissible = true,
    Key? key,
  }) : this._(
         label: label,
         variant: OiDialogVariant.standard,
         title: title,
         content: content,
         actions: actions,
         onClose: onClose,
         dismissible: dismissible,
         key: key,
       );

  /// Creates an alert dialog for simple informational messages.
  const OiDialog.alert({
    required String label,
    String? title,
    Widget? content,
    List<Widget>? actions,
    VoidCallback? onClose,
    bool dismissible = true,
    Key? key,
  }) : this._(
         label: label,
         variant: OiDialogVariant.alert,
         title: title,
         content: content,
         actions: actions,
         onClose: onClose,
         dismissible: dismissible,
         key: key,
       );

  /// Creates a confirmation dialog with cancel/confirm semantics.
  const OiDialog.confirm({
    required String label,
    String? title,
    Widget? content,
    List<Widget>? actions,
    VoidCallback? onClose,
    bool dismissible = true,
    Key? key,
  }) : this._(
         label: label,
         variant: OiDialogVariant.confirm,
         title: title,
         content: content,
         actions: actions,
         onClose: onClose,
         dismissible: dismissible,
         key: key,
       );

  /// Creates a form dialog with scrollable content.
  const OiDialog.form({
    required String label,
    String? title,
    Widget? content,
    List<Widget>? actions,
    VoidCallback? onClose,
    bool dismissible = true,
    Key? key,
  }) : this._(
         label: label,
         variant: OiDialogVariant.form,
         title: title,
         content: content,
         actions: actions,
         onClose: onClose,
         dismissible: dismissible,
         key: key,
       );

  /// Creates a full-screen dialog.
  ///
  /// When [unsavedChanges] is `true`, scrim tap and Escape key are
  /// suppressed — the user must use the explicit close button.
  ///
  /// [onSave] is an optional save callback, typically wired to a header-bar
  /// save button by the consumer.
  const OiDialog.fullScreen({
    required String label,
    String? title,
    Widget? content,
    List<Widget>? actions,
    VoidCallback? onClose,
    VoidCallback? onSave,
    bool unsavedChanges = false,
    bool dismissible = true,
    Key? key,
  }) : this._(
         label: label,
         variant: OiDialogVariant.fullScreen,
         title: title,
         content: content,
         actions: actions,
         onClose: onClose,
         onSave: onSave,
         unsavedChanges: unsavedChanges,
         dismissible: dismissible,
         key: key,
       );

  /// Accessible label describing the dialog for screen readers.
  final String label;

  /// Optional heading text displayed at the top of the dialog.
  final String? title;

  /// The main body content of the dialog.
  final Widget? content;

  /// Action widgets displayed at the bottom (e.g. buttons).
  final List<Widget>? actions;

  /// Visual / behavioural variant.
  final OiDialogVariant variant;

  /// Called when the dialog should close (Escape key or scrim tap).
  final VoidCallback? onClose;

  /// Called when the user saves in a [OiDialog.fullScreen] dialog.
  final VoidCallback? onSave;

  /// When `true` in a [OiDialog.fullScreen] dialog, the scrim tap and Escape
  /// key are suppressed, forcing the user to use the explicit close button.
  final bool unsavedChanges;

  /// Whether tapping the scrim closes the dialog. Defaults to `true`.
  final bool dismissible;

  /// Shows [dialog] as an overlay above the current widget tree.
  ///
  /// Uses [OiOverlays.of] when available, otherwise falls back to the
  /// Flutter [Overlay]. Returns an [OiOverlayHandle] that can be used to
  /// dismiss the overlay programmatically.
  static OiOverlayHandle show(
    BuildContext context, {
    required String label,
    required Widget dialog,
  }) {
    final service = OiOverlays.maybeOf(context);
    if (service != null) {
      return service.show(
        label: label,
        builder: (_) => dialog,
        zOrder: OiOverlayZOrder.dialog,
        dismissible: false,
      );
    }

    // Fallback: insert directly into the nearest Flutter Overlay.
    final entry = OverlayEntry(builder: (_) => dialog);
    Overlay.of(context).insert(entry);
    return createOiOverlayHandle(entry);
  }

  /// Shows an opinionated [OiDialog] as a modal overlay and returns a future
  /// that completes when the dialog is dismissed.
  ///
  /// This is a convenience wrapper around [OiDialogShell.show] for the
  /// pre-built dialog variants. Use the top-level [showOiDialog] function
  /// when you need a fully custom dialog body.
  static Future<T?> showAsync<T>(
    BuildContext context, {
    required String label,
    String? title,
    Widget? content,
    List<Widget>? actions,
    bool dismissible = true,
  }) async {
    return OiDialogShell.show<T>(
      context: context,
      semanticLabel: label,
      barrierDismissible: dismissible,
      builder: (close) => OiDialog.standard(
        label: label,
        title: title,
        content: content,
        actions: actions,
        dismissible: dismissible,
        onClose: () => close(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final dt = context.components.dialog;
    final isFullScreen = variant == OiDialogVariant.fullScreen;
    final isForm = variant == OiDialogVariant.form;
    // When unsavedChanges is true on fullScreen, suppress scrim/Escape.
    final effectiveDismissible =
        !(isFullScreen && unsavedChanges) && dismissible;

    final hPad = dt?.contentPadding?.left ?? 24.0;
    final topPad = dt?.contentPadding?.top ?? 20.0;
    final bottomPad = dt?.contentPadding?.bottom ?? 20.0;
    final titleBodyGap = dt?.titleBodyGap ?? 8.0;
    final contentButtonGap = dt?.contentButtonGap ?? 12.0;
    final buttonGap = dt?.buttonGap ?? 8.0;

    // Local aliases to satisfy promotion for use inside closures / conditionals.
    final titleText = title;
    final bodyContent = content;
    final actionList = actions;

    final dialogContent = Column(
      mainAxisSize: isFullScreen ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Title ──────────────────────────────────────────────────────────
        if (titleText != null)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, titleBodyGap),
            child: Text(
              titleText,
              style: textTheme.h4.copyWith(color: colors.text),
            ),
          ),

        // ── Content ────────────────────────────────────────────────────────
        if (bodyContent != null)
          if (isForm)
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bottomPad),
                child: bodyContent,
              ),
            )
          else
            Padding(
              padding: EdgeInsets.fromLTRB(
                hPad,
                titleBodyGap,
                hPad,
                actionList != null && actionList.isNotEmpty
                    ? titleBodyGap
                    : bottomPad,
              ),
              child: bodyContent,
            ),

        // ── Actions ────────────────────────────────────────────────────────
        if (actionList != null && actionList.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              contentButtonGap,
              hPad,
              bottomPad,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var i = 0; i < actionList.length; i++) ...[
                  if (i > 0) SizedBox(width: buttonGap),
                  actionList[i],
                ],
              ],
            ),
          ),
      ],
    );

    // Use OiDialogShell for non-fullScreen variants to ensure visual
    // consistency between opinionated and custom dialogs.
    Widget panel;
    if (isFullScreen) {
      panel = ColoredBox(
        color: dt?.backgroundColor ?? colors.surface,
        child: dialogContent,
      );
    } else {
      panel = OiDialogShell(maxWidth: 480, minWidth: 280, child: dialogContent);
    }

    panel = OiFocusTrap(
      onEscape: effectiveDismissible ? onClose : null,
      child: panel,
    );

    if (isFullScreen) {
      panel = Positioned.fill(child: panel);
    } else {
      panel = Center(child: panel);
    }

    return Semantics(
      label: label,
      scopesRoute: true,
      explicitChildNodes: true,
      child: Stack(
        children: [
          // ── Scrim ───────────────────────────────────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: effectiveDismissible ? onClose : null,
              child: ColoredBox(color: colors.overlay),
            ),
          ),
          // ── Panel ───────────────────────────────────────────────────────────
          panel,
        ],
      ),
    );
  }
}
