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
  OiShortcutScopeState() : commandBarActive = ValueNotifier<bool>(false);

  /// Notifier that becomes `true` while the command bar is open.
  ///
  /// Set to `false` once the bar is dismissed.
  final ValueNotifier<bool> commandBarActive;

  /// Releases resources held by this state.
  void dispose() {
    commandBarActive.dispose();
  }
}

// Internal InheritedWidget used to provide [OiShortcutScopeState] to the tree.
class _OiShortcutScopeInherited extends InheritedWidget {
  const _OiShortcutScopeInherited({required this.state, required super.child});

  final OiShortcutScopeState state;

  @override
  bool updateShouldNotify(_OiShortcutScopeInherited oldWidget) => false;
}

/// Registers global keyboard shortcuts (Ctrl+Z undo, Ctrl+K command bar,
/// `?` help) and provides [OiShortcutScopeState] to descendants.
///
/// Ctrl+Z (Cmd+Z) undoes the [OiUndoStack], but in a focused text field it
/// undoes the typing, as in any text field.
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
          SingleActivator(LogicalKeyboardKey.keyK, control: true):
              OiCommandBarIntent(),
          SingleActivator(LogicalKeyboardKey.keyK, meta: true):
              OiCommandBarIntent(),
          SingleActivator(LogicalKeyboardKey.question): OiHelpIntent(),
        },
        child: Actions(
          actions: {
            OiUndoIntent: _OiUndoAction(
              () => OiUndoStack.maybeOf(context)?.undo(),
            ),
            OiCommandBarIntent: CallbackAction<OiCommandBarIntent>(
              onInvoke: (_) {
                _state.commandBarActive.value = true;
                return null;
              },
            ),
            OiHelpIntent: CallbackAction<OiHelpIntent>(onInvoke: (_) => null),
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Undoes the last step of the [OiUndoStack], except while a text field
/// has the focus: there Ctrl+Z (Cmd+Z) undoes the typing.
///
/// Not enabled then, so the key goes on to Flutter's text editing
/// shortcuts above this scope (in the `WidgetsApp`), which undo the
/// field's own history. Enabled, this action would take the key from them.
class _OiUndoAction extends Action<OiUndoIntent> {
  _OiUndoAction(this._undo);

  final VoidCallback _undo;

  // The getter `isEnabled` reads, not `isEnabled` itself: public
  // is-prefixed bool methods are against REQ-0017.
  @override
  bool get isActionEnabled =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorStateOfType<EditableTextState>() ==
      null;

  @override
  Object? invoke(OiUndoIntent intent) {
    _undo();
    return null;
  }
}
