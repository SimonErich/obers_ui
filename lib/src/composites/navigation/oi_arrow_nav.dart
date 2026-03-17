import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Wraps a list of focusable children and enables arrow key navigation.
///
/// This is a behavior widget, not visual. It manages the [highlightedIndex]
/// and fires callbacks. The visual highlighting is done by the consumer
/// widget based on the index.
///
/// Used by [OiSelect], [OiComboBox], [OiCommandBar], [OiContextMenu],
/// [OiTable], [OiTree], and any widget with keyboard-navigable lists.
///
/// {@category Composites}
class OiArrowNav extends StatefulWidget {
  /// Creates an [OiArrowNav].
  const OiArrowNav({
    required this.child,
    required this.itemCount,
    super.key,
    this.highlightedIndex,
    this.onHighlightChange,
    this.onSelect,
    this.onEscape,
    this.direction = Axis.vertical,
    this.loop = true,
    this.typeAhead = false,
    this.enabled = true,
  });

  /// The widget subtree that contains the navigable items.
  final Widget child;

  /// The total number of items available for navigation.
  ///
  /// When zero, all keyboard handling is effectively a no-op.
  final int itemCount;

  /// The currently highlighted item index.
  ///
  /// When `null`, no item is highlighted. Arrow key presses will start
  /// from index 0 (down/right) or the last index (up/left).
  final int? highlightedIndex;

  /// Called when the highlighted index changes due to arrow key input.
  final ValueChanged<int>? onHighlightChange;

  /// Called when the user presses Enter to select the highlighted item.
  ///
  /// Receives the current [highlightedIndex]. Not called when no item
  /// is highlighted.
  final ValueChanged<int>? onSelect;

  /// Called when the user presses the Escape key.
  final VoidCallback? onEscape;

  /// The navigation axis.
  ///
  /// [Axis.vertical] listens for Up/Down arrows; [Axis.horizontal] listens
  /// for Left/Right arrows. Defaults to [Axis.vertical].
  final Axis direction;

  /// Whether navigation wraps around at the ends of the list.
  ///
  /// When `true` (the default), pressing down on the last item moves to the
  /// first, and pressing up on the first item moves to the last.
  final bool loop;

  /// Whether type-ahead character matching is enabled.
  ///
  /// When `true`, typing a character will jump to the next item whose label
  /// starts with that character. Currently reserved for future implementation.
  final bool typeAhead;

  /// Whether keyboard handling is active.
  ///
  /// When `false`, all key events are ignored and passed through.
  final bool enabled;

  @override
  State<OiArrowNav> createState() => _OiArrowNavState();
}

class _OiArrowNavState extends State<OiArrowNav> {
  // ── Key handling ──────────────────────────────────────────────────────────

  /// Returns the logical key that moves to the next item.
  LogicalKeyboardKey get _nextKey => widget.direction == Axis.vertical
      ? LogicalKeyboardKey.arrowDown
      : LogicalKeyboardKey.arrowRight;

  /// Returns the logical key that moves to the previous item.
  LogicalKeyboardKey get _prevKey => widget.direction == Axis.vertical
      ? LogicalKeyboardKey.arrowUp
      : LogicalKeyboardKey.arrowLeft;

  /// Handles key events for arrow navigation, Enter, and Escape.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // ── Escape ────────────────────────────────────────────────────────────
    if (key == LogicalKeyboardKey.escape) {
      widget.onEscape?.call();
      return KeyEventResult.handled;
    }

    // ── Enter / Select ────────────────────────────────────────────────────
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (widget.highlightedIndex != null && widget.itemCount > 0) {
        widget.onSelect?.call(widget.highlightedIndex!);
      }
      return KeyEventResult.handled;
    }

    // ── Arrow keys ────────────────────────────────────────────────────────
    if (key == _nextKey) {
      _moveNext();
      return KeyEventResult.handled;
    }

    if (key == _prevKey) {
      _movePrev();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Moves the highlight to the next item.
  void _moveNext() {
    if (widget.itemCount == 0) return;

    final current = widget.highlightedIndex;

    if (current == null) {
      widget.onHighlightChange?.call(0);
      return;
    }

    if (current >= widget.itemCount - 1) {
      // At the end.
      if (widget.loop) {
        widget.onHighlightChange?.call(0);
      }
      // When loop is false, do nothing at the boundary.
      return;
    }

    widget.onHighlightChange?.call(current + 1);
  }

  /// Moves the highlight to the previous item.
  void _movePrev() {
    if (widget.itemCount == 0) return;

    final current = widget.highlightedIndex;

    if (current == null) {
      widget.onHighlightChange?.call(widget.itemCount - 1);
      return;
    }

    if (current <= 0) {
      // At the beginning.
      if (widget.loop) {
        widget.onHighlightChange?.call(widget.itemCount - 1);
      }
      // When loop is false, do nothing at the boundary.
      return;
    }

    widget.onHighlightChange?.call(current - 1);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
