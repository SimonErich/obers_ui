import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiApp;
import 'package:obers_ui/src/foundation/oi_app.dart' show OiApp;

/// A single undoable action.
///
/// Encapsulates the forward (redo) and backward (undo) operations,
/// plus an optional [merge] function for coalescing rapid consecutive
/// actions of the same type (e.g. typing).
///
/// {@category Foundation}
@immutable
class OiUndoAction {
  /// Creates an [OiUndoAction].
  const OiUndoAction({
    required this.label,
    required this.execute,
    required this.undo,
    this.merge,
    this.groupId,
  });

  /// Human-readable label for the action (e.g. "Rename column").
  final String label;

  /// Performs (or re-performs) the action.
  final VoidCallback execute;

  /// Reverses the action.
  final VoidCallback undo;

  /// Optional merger — if provided, the undo stack may call this with the
  /// next pushed action to produce a merged action (grouping rapid edits).
  ///
  /// Returns null if the two actions cannot be merged.
  final OiUndoAction? Function(OiUndoAction next)? merge;

  /// Optional group identifier for merging related actions.
  ///
  /// Actions with the same non-null [groupId] are eligible for merging.
  final String? groupId;
}

/// A history stack for undo/redo operations.
///
/// Push [OiUndoAction]s when the user performs undoable operations.
/// The stack automatically handles merging of adjacent actions with the
/// same [OiUndoAction.groupId] when a merge function is provided.
///
/// Access the stack from the widget tree via [OiUndoStackProvider] and
/// [OiUndoStack.of].
///
/// {@category Foundation}
class OiUndoStack extends ChangeNotifier {
  /// Creates an [OiUndoStack] with an optional history limit.
  OiUndoStack({int maxHistory = 50}) : _maxHistory = maxHistory;

  final int _maxHistory;
  final List<OiUndoAction> _history = [];
  final List<OiUndoAction> _future = [];

  /// Whether there are actions available to undo.
  bool get canUndo => _history.isNotEmpty;

  /// Whether there are actions available to redo.
  bool get canRedo => _future.isNotEmpty;

  /// The current undo history (oldest first).
  List<OiUndoAction> get history => List.unmodifiable(_history);

  /// The available redo steps (most-recent-undone first).
  List<OiUndoAction> get future => List.unmodifiable(_future);

  /// The label of the next action that would be undone, or null.
  String? get nextUndoLabel => _history.isNotEmpty ? _history.last.label : null;

  /// The label of the next action that would be redone, or null.
  String? get nextRedoLabel => _future.isNotEmpty ? _future.last.label : null;

  /// Pushes [action] onto the history stack and executes it.
  ///
  /// Clears the redo stack. If the new action can be merged with the
  /// previous one (same groupId and a merge function), they are
  /// coalesced into one entry.
  void push(OiUndoAction action) {
    // Attempt merge with the most recent history entry
    if (_history.isNotEmpty) {
      final last = _history.last;
      if (last.groupId != null &&
          last.groupId == action.groupId &&
          last.merge != null) {
        final merged = last.merge!(action);
        if (merged != null) {
          _history
            ..removeLast()
            ..add(merged);
          _future.clear();
          notifyListeners();
          return;
        }
      }
    }

    _history.add(action);
    _future.clear();

    // Enforce max history limit
    while (_history.length > _maxHistory) {
      _history.removeAt(0);
    }

    notifyListeners();
  }

  /// Undoes the most recent action, moving it to the redo stack.
  ///
  /// Does nothing if [canUndo] is false.
  void undo() {
    if (!canUndo) return;
    final action = _history.removeLast();
    action.undo();
    _future.add(action);
    notifyListeners();
  }

  /// Redoes the most recently undone action.
  ///
  /// Does nothing if [canRedo] is false.
  void redo() {
    if (!canRedo) return;
    final action = _future.removeLast();
    action.execute();
    _history.add(action);
    notifyListeners();
  }

  /// Clears both the history and future stacks.
  void clear() {
    _history.clear();
    _future.clear();
    notifyListeners();
  }

  /// Returns the stack from the nearest [OiUndoStackProvider].
  ///
  /// Throws if no [OiUndoStackProvider] is found.
  static OiUndoStack of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<OiUndoStackProvider>();
    assert(
      provider != null,
      'No OiUndoStackProvider found in the widget tree.',
    );
    return provider!.stack;
  }

  /// Returns the stack from the nearest [OiUndoStackProvider], or null.
  static OiUndoStack? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<OiUndoStackProvider>()
        ?.stack;
  }
}

/// Provides an [OiUndoStack] to all descendant widgets.
///
/// Typically placed inside [OiApp] to make undo/redo globally available.
///
/// {@category Foundation}
class OiUndoStackProvider extends InheritedNotifier<OiUndoStack> {
  /// Creates an [OiUndoStackProvider] that provides [stack].
  const OiUndoStackProvider({
    required OiUndoStack stack,
    required super.child,
    super.key,
  }) : super(notifier: stack);

  /// The undo stack made available to descendants.
  OiUndoStack get stack => notifier!;
}
