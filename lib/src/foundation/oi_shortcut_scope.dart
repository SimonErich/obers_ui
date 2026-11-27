import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiApp;
import 'package:obers_ui/src/foundation/oi_app.dart' show OiApp;
import 'package:obers_ui/src/foundation/oi_undo_stack.dart';

/// Intent fired when the user presses Ctrl+Z (or Cmd+Z on macOS).
///
/// {@category Foundation}
class OiUndoIntent extends Intent {
  /// Creates an [OiUndoIntent].
  const OiUndoIntent();
}

/// Intent fired when the user presses Ctrl+Shift+Z, Cmd+Shift+Z or Ctrl+Y.
///
/// {@category Foundation}
class OiRedoIntent extends Intent {
  /// Creates an [OiRedoIntent].
  const OiRedoIntent();
}

/// Intent fired when the user presses Ctrl+K (or Cmd+K on macOS) to open
/// the command bar.
///
/// {@category Foundation}
class OiCommandBarIntent extends Intent {
  /// Creates an [OiCommandBarIntent].
  const OiCommandBarIntent();
}

/// Intent fired when the user presses `?` to open the help overlay.
///
/// {@category Foundation}
class OiHelpIntent extends Intent {
  /// Creates an [OiHelpIntent].
  const OiHelpIntent();
}

/// Holds mutable state for [OiShortcutScope] that descendants can read.
///
/// Obtain via [OiShortcutScope.of] or [OiShortcutScope.maybeOf].
///
/// {@category Foundation}
class OiShortcutScopeState {
  /// Creates an [OiShortcutScopeState].
  OiShortcutScopeState()
    : commandBarActive = ValueNotifier<bool>(false),
      helpActive = ValueNotifier<bool>(false);

  /// Notifier that becomes `true` while the command bar is open.
  ///
  /// Set to `false` once the bar is dismissed.
  final ValueNotifier<bool> commandBarActive;

  /// Notifier that becomes `true` when the user presses `?` to ask for help.
  ///
  /// Listen to it to show a help or shortcuts overlay, and set it back to
  /// `false` once that is dismissed.
  final ValueNotifier<bool> helpActive;

  /// Releases resources held by this state.
  void dispose() {
    commandBarActive.dispose();
    helpActive.dispose();
  }
}

// Internal InheritedWidget used to provide [OiShortcutScopeState] to the tree.
class _OiShortcutScopeInherited extends InheritedWidget {
  const _OiShortcutScopeInherited({required this.state, required super.child});

  final OiShortcutScopeState state;

  @override
  bool updateShouldNotify(_OiShortcutScopeInherited oldWidget) => false;
}

/// Registers global keyboard shortcuts (Ctrl+Z undo, Ctrl+Shift+Z / Ctrl+Y
/// redo, Ctrl+K command bar, `?` help) and provides [OiShortcutScopeState]
/// to descendants.
///
/// Ctrl+Z (Cmd+Z) undoes the [OiUndoStack] and Ctrl+Shift+Z (Cmd+Shift+Z) or
/// Ctrl+Y redoes it, but in a focused text field they undo and redo the
/// typing, as in any text field. `?` sets
/// [OiShortcutScopeState.helpActive], except in a text field, where it is
/// typed.
///
/// [OiApp] places this widget above the content so that the shortcuts are
/// available throughout the entire application.
///
/// ```dart
/// final state = OiShortcutScope.of(context);
/// state.commandBarActive.addListener(() { ... });
/// ```
///
/// {@category Foundation}
class OiShortcutScope extends StatefulWidget {
  /// Creates an [OiShortcutScope].
  const OiShortcutScope({required this.child, super.key});

  /// The widget below this widget in the tree.
  final Widget child;

  /// Returns the [OiShortcutScopeState] from the nearest [OiShortcutScope],
  /// or `null` if none is found.
  static OiShortcutScopeState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_OiShortcutScopeInherited>()
        ?.state;
  }

  /// Returns the [OiShortcutScopeState] from the nearest [OiShortcutScope].
  ///
  /// Throws if no [OiShortcutScope] is found in the widget tree.
  static OiShortcutScopeState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No OiShortcutScope found in the widget tree.');
    return state!;
  }

  @override
  State<OiShortcutScope> createState() => _OiShortcutScopeState();
}

class _OiShortcutScopeState extends State<OiShortcutScope> {
  late final OiShortcutScopeState _state;

  @override
  void initState() {
    super.initState();
    _state = OiShortcutScopeState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OiShortcutScopeInherited(
      state: _state,
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.keyZ, control: true):
              OiUndoIntent(),
          SingleActivator(LogicalKeyboardKey.keyZ, meta: true): OiUndoIntent(),
          SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
              OiRedoIntent(),
          SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
              OiRedoIntent(),
          SingleActivator(LogicalKeyboardKey.keyY, control: true):
              OiRedoIntent(),
          SingleActivator(LogicalKeyboardKey.keyK, control: true):
              OiCommandBarIntent(),
          SingleActivator(LogicalKeyboardKey.keyK, meta: true):
              OiCommandBarIntent(),
          // By character, not by key: "?" is Shift+/ on most layouts, and a
          // SingleActivator for the question key only matches without Shift.
          CharacterActivator('?'): OiHelpIntent(),
        },
        child: Actions(
          actions: {
            OiUndoIntent: _OiOutsideTextFieldAction<OiUndoIntent>(
              () => OiUndoStack.maybeOf(context)?.undo(),
            ),
            OiRedoIntent: _OiOutsideTextFieldAction<OiRedoIntent>(
              () => OiUndoStack.maybeOf(context)?.redo(),
            ),
            OiCommandBarIntent: CallbackAction<OiCommandBarIntent>(
              onInvoke: (_) {
                _state.commandBarActive.value = true;
                return null;
              },
            ),
            OiHelpIntent: _OiOutsideTextFieldAction<OiHelpIntent>(
              () => _state.helpActive.value = true,
            ),
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Runs a global shortcut, except while a text field has the focus: there
/// Ctrl+Z / Ctrl+Shift+Z undo and redo the typing, and `?` is a character.
///
/// Not enabled then, so the key goes on to Flutter's text editing
/// shortcuts above this scope (in the `WidgetsApp`), which undo the
/// field's own history, or to the text input. Enabled, this action would
/// take the key from them.
class _OiOutsideTextFieldAction<T extends Intent> extends Action<T> {
  _OiOutsideTextFieldAction(this._run);

  final VoidCallback _run;

  // The getter `isEnabled` reads, not `isEnabled` itself: public
  // is-prefixed bool methods are against REQ-0017.
  @override
  bool get isActionEnabled =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorStateOfType<EditableTextState>() ==
      null;

  @override
  Object? invoke(T intent) {
    _run();
    return null;
  }
}
