import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_focus_trap.dart';

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
    required OiDialogVariant variant,
    this.title,
    this.content,
    this.actions,
    this.onClose,
    this.dismissible = true,
    super.key,
  }) : variant = variant;

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
  const OiDialog.fullScreen({
    required String label,
    String? title,
    Widget? content,
    List<Widget>? actions,
    VoidCallback? onClose,
    bool dismissible = true,
    Key? key,
  }) : this._(
         label: label,
         variant: OiDialogVariant.fullScreen,
         title: title,
         content: content,
         actions: actions,
         onClose: onClose,
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

  /// Whether tapping the scrim closes the dialog. Defaults to `true`.
  final bool dismissible;

  /// Shows [dialog] as an overlay above the current widget tree.
  ///
  /// Uses [OiOverlays.of] when available, otherwise falls back to the
  /// Flutter [Overlay]. Returns an [OiOverlayHandle] that can be used to
  /// dismiss the overlay programmatically.
  static OiOverlayHandle show(BuildContext context, {required Widget dialog}) {
    final service = OiOverlays.maybeOf(context);
    if (service != null) {
      return service.show(
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final isFullScreen = variant == OiDialogVariant.fullScreen;
    final isForm = variant == OiDialogVariant.form;

    // Local aliases to satisfy promotion for use inside closures / conditionals.
    final titleText = title;
    final bodyContent = content;
    final actionList = actions;

    Widget panel = Container(
      constraints: isFullScreen
          ? null
          : const BoxConstraints(maxWidth: 480, minWidth: 280),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: isFullScreen ? null : BorderRadius.circular(12),
        boxShadow: isFullScreen
            ? null
            : [
                BoxShadow(
                  color: colors.overlay.withValues(alpha: 0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: isFullScreen ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Title ──────────────────────────────────────────────────────────
          if (titleText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: bodyContent,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: bodyContent,
              ),

          // ── Actions ────────────────────────────────────────────────────────
          if (actionList != null && actionList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var i = 0; i < actionList.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    actionList[i],
                  ],
                ],
              ),
            ),
        ],
      ),
    );

    panel = OiFocusTrap(onEscape: onClose, child: panel);

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
              onTap: dismissible ? onClose : null,
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
