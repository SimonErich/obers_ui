import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/overlays/oi_snack_bar.dart';
import 'package:obers_ui/src/components/overlays/oi_toast.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';

/// Orchestrates optimistic UI updates with undo and automatic rollback.
///
/// Apply a change immediately, give the user a window to undo, then
/// commit the real operation. If the commit fails, rolls back automatically.
///
/// ```dart
/// await OiOptimisticAction.execute(
///   context,
///   apply: () => setState(() => items.remove(item)),
///   rollback: () => setState(() => items.insert(index, item)),
///   commit: () => api.deleteItem(item.id),
///   message: 'Item deleted',
/// );
/// ```
///
/// {@category Foundation}
class OiOptimisticAction {
  OiOptimisticAction._();

  /// The pending action of each overlays service.
  ///
  /// Scoped to the service rather than the process, so two apps (or two
  /// tests) do not commit or cancel each other's pending action.
  static final Expando<_PendingAction> _pendingByScope =
      Expando<_PendingAction>('OiOptimisticAction.pending');

  /// Scope used when the context has no [OiOverlays] ancestor.
  static final Object _unscoped = Object();

  static Object _scopeOf(BuildContext context) =>
      OiOverlays.maybeOf(context) ?? _unscoped;

  /// Execute an optimistic action with undo support.
  ///
  /// 1. Calls [apply] immediately (optimistic update).
  /// 2. Shows an [OiSnackBar] with [message] and an Undo button.
  /// 3. If Undo is tapped within [undoDuration], calls [onRollback].
  /// 4. If the timer expires, calls [commit].
  /// 5. If [commit] throws anything (an [Exception] or an [Error]), calls
  ///    [onRollback] and shows an error toast.
  ///
  /// Returns `true` if the commit succeeded, `false` if undone or failed.
  static Future<bool> execute(
    BuildContext context, {
    required VoidCallback apply,
    required VoidCallback onRollback,
    required Future<void> Function() commit,
    required String message,
    Duration undoDuration = const Duration(seconds: 5),
    String undoLabel = 'Undo',
    String? errorMessage,
    OiToastLevel errorLevel = OiToastLevel.error,
    String? semanticLabel,
    OiSnackBarPosition position = OiSnackBarPosition.bottom,
  }) {
    final scope = _scopeOf(context);

    // If this app already has a pending action, commit it immediately.
    _pendingByScope[scope]?.commitImmediately();

    // Apply the optimistic change immediately.
    apply();

    final completer = Completer<bool>();
    final action = _PendingAction(
      onRollback: onRollback,
      commit: commit,
      completer: completer,
      errorMessage: errorMessage,
      errorLevel: errorLevel,
      context: context,
    );
    _pendingByScope[scope] = action;

    // Show snackbar with undo.
    final handle = OiSnackBar.show(
      context,
      message: message,
      actionLabel: undoLabel,
      onAction: () {
        if (_pendingByScope[scope] == action) {
          _pendingByScope[scope] = null;
        }
        action.undo();
      },
      duration: undoDuration,
      position: position,
      onDismissed: () {
        // Timer expired — commit.
        if (!action.isResolved) {
          action.commitAsync();
        }
      },
    );
    action.snackBarHandle = handle;

    return completer.future;
  }

  /// Cancel the pending optimistic action of the app [context] belongs to.
  /// Rolls back the pending change if one exists.
  static void cancelPending(BuildContext context) {
    final scope = _scopeOf(context);
    final pending = _pendingByScope[scope];
    if (pending != null) {
      pending.snackBarHandle?.dismiss();
      pending.undo();
      _pendingByScope[scope] = null;
    }
  }
}

class _PendingAction {
  _PendingAction({
    required this.onRollback,
    required this.commit,
    required this.completer,
    required this.errorMessage,
    required this.errorLevel,
    required this.context,
  });

  final VoidCallback onRollback;
  final Future<void> Function() commit;
  final Completer<bool> completer;
  final String? errorMessage;
  final OiToastLevel errorLevel;
  final BuildContext context;
  OiOverlayHandle? snackBarHandle;

  bool _resolved = false;
  bool get isResolved => _resolved;

  void undo() {
    if (_resolved) return;
    _resolved = true;
    onRollback();
    if (!completer.isCompleted) completer.complete(false);
  }

  void commitImmediately() {
    if (_resolved) return;
    _resolved = true;
    snackBarHandle?.dismiss();
    unawaited(_commitAndHandleError());
  }

  void commitAsync() {
    if (_resolved) return;
    _resolved = true;
    unawaited(_commitAndHandleError());
  }

  Future<void> _commitAndHandleError() async {
    try {
      await commit();
      if (!completer.isCompleted) completer.complete(true);
    } on Object catch (e, st) {
      // Errors (StateError, TypeError, ...) count as a failed commit too:
      // the optimistic change must be rolled back and the future completed.
      log(
        'OiOptimisticAction commit failed',
        error: e,
        stackTrace: st,
        name: 'obers_ui.optimistic_action',
      );
      try {
        onRollback();
      } on Object catch (rollbackError, rollbackSt) {
        log(
          'OiOptimisticAction rollback also failed',
          error: rollbackError,
          stackTrace: rollbackSt,
          name: 'obers_ui.optimistic_action',
        );
      }
      if (context.mounted) {
        OiToast.show(
          context,
          message: errorMessage ?? 'Action failed',
          level: errorLevel,
        );
      }
      if (!completer.isCompleted) completer.complete(false);
    }
  }
}
