import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Traps keyboard focus within its child widget tree.
///
/// [OiFocusTrap] creates an isolated [FocusScopeNode] so that Tab and
/// Shift+Tab navigation cycles only through focusable elements inside the
/// trap, never escaping to outer focus nodes.
///
/// **Behaviour:**
/// - `Tab` — moves focus to the next focusable descendant, wrapping around
///   to the first when the last is reached.
/// - `Shift+Tab` — moves focus to the previous focusable descendant, wrapping
///   around to the last when the first is reached.
/// - `Escape` — calls [onEscape] when provided.
/// - Android back button — calls [onEscape] when provided (via [PopScope]).
/// - [initialFocus] — when `true` (the default), the first focusable element
///   inside the scope receives focus after the first frame. When `false`, the
///   scope itself takes focus instead: no descendant is highlighted, but key
///   events still reach the trap so Escape and Tab keep working.
/// - [restoreFocus] — when `true` (the default), the widget that held focus
///   before the trap was built regains it when the trap is disposed.
///
/// {@category Primitives}
class OiFocusTrap extends StatefulWidget {
  /// Creates an [OiFocusTrap].
  const OiFocusTrap({
    required this.child,
    this.initialFocus = true,
    this.restoreFocus = true,
    this.onEscape,
    super.key,
  });

  /// The widget subtree within which focus is trapped.
  final Widget child;

  /// Whether the first focusable descendant should receive focus automatically
  /// after the first frame.
  ///
  /// When `false` the trap focuses its own scope node instead of a descendant.
  /// The scope must hold focus for [FocusScope.onKeyEvent] to fire at all, so
  /// leaving focus outside the trap entirely would make Escape and Tab dead.
  final bool initialFocus;

  /// Whether the widget that held focus before this trap was built should
  /// regain focus when the trap is disposed.
  final bool restoreFocus;

  /// Called when the user presses Escape (or the Android back button).
  final VoidCallback? onEscape;

  @override
  State<OiFocusTrap> createState() => _OiFocusTrapState();
}

class _OiFocusTrapState extends State<OiFocusTrap> {
  late final FocusScopeNode _scopeNode;

  /// The focus node that was primary before this trap was mounted.
  FocusNode? _previousFocus;

  @override
  void initState() {
    super.initState();
    _scopeNode = FocusScopeNode(debugLabel: 'OiFocusTrap');

    if (widget.restoreFocus) {
      _previousFocus = FocusManager.instance.primaryFocus;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialFocus) {
        // Move to the first focusable descendant inside the scope.
        _scopeNode.nextFocus();
      } else {
        // Focus the scope itself rather than a descendant. Key events still
        // reach onKeyEvent — so Escape and Tab work — but no descendant is
        // focused, so nothing draws a focus ring the user did not ask for.
        _scopeNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    if (widget.restoreFocus && _previousFocus != null) {
      _previousFocus!.requestFocus();
    }
    _scopeNode.dispose();
    super.dispose();
  }

  // ── Keyboard handling ──────────────────────────────────────────────────────

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isTab = event.logicalKey == LogicalKeyboardKey.tab;
    final isEscape = event.logicalKey == LogicalKeyboardKey.escape;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    if (isEscape) {
      widget.onEscape?.call();
      return KeyEventResult.handled;
    }

    if (isTab) {
      // nextFocus / previousFocus cycle within the scope and wrap around
      // automatically because _scopeNode is the active FocusScope.
      if (isShift) {
        _scopeNode.previousFocus();
      } else {
        _scopeNode.nextFocus();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // PopScope intercepts the Android system back gesture / button and
    // translates it into an [onEscape] callback.  canPop is set to false only
    // when there is an onEscape handler to consume the back event.
    return PopScope(
      canPop: widget.onEscape == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onEscape?.call();
      },
      child: FocusScope(
        node: _scopeNode,
        onKeyEvent: _handleKeyEvent,
        child: widget.child,
      ),
    );
  }
}
