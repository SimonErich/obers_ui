import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart'
    show OiComboBox, OiCommandBar, OiContextMenu, OiSelect, OiTable, OiTree;

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
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.typeAhead = false,
    this.itemLabel,
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

  /// An optional [FocusNode] to use for this widget's keyboard focus.
  ///
  /// When `null`, an internal focus node is created automatically.
  /// Supply your own to control focus from outside (e.g. requesting focus
  /// programmatically or sharing a node with another widget).
  final FocusNode? focusNode;

  /// Whether this widget should request focus when first inserted.
  ///
  /// Defaults to `false`. As a behavior widget, [OiArrowNav] does not
  /// assume it should steal focus — the consumer decides.
  final bool autofocus;

  /// Whether typing characters jumps to the first matching item.
  ///
  /// When `true`, typing a letter jumps to the first item whose label
  /// (provided by [itemLabel]) starts with the typed characters, similar to
  /// native OS list boxes. Characters accumulate for 500 ms before resetting.
  ///
  /// Requires [itemLabel] to be set.
  final bool typeAhead;

  /// Returns the label for the item at index.
  ///
  /// Required when [typeAhead] is `true`. Used to match typed characters
  /// against item labels (case-insensitive).
  final String Function(int index)? itemLabel;

  /// Whether keyboard handling is active.
  ///
  /// When `false`, all key events are ignored and passed through.
  final bool enabled;

  @override
  State<OiArrowNav> createState() => _OiArrowNavState();
}

class _OiArrowNavState extends State<OiArrowNav> {
  // ── Type-ahead state ────────────────────────────────────────────────────────

  /// Accumulated typed characters for type-ahead matching.
  String _typeAheadBuffer = '';

  /// Timer that resets the type-ahead buffer after inactivity.
  Timer? _typeAheadTimer;

  /// Duration before the type-ahead buffer resets.
  static const _typeAheadTimeout = Duration(milliseconds: 500);

  @override
  void dispose() {
    _typeAheadTimer?.cancel();
    super.dispose();
  }

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

    // ── Type-ahead ─────────────────────────────────────────────────────────
    if (widget.typeAhead && widget.itemLabel != null) {
      final character = event.character;
      if (character != null &&
          character.length == 1 &&
          !character.contains(RegExp(r'[\x00-\x1F]'))) {
        _handleTypeAhead(character);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  /// Handles a typed character for type-ahead navigation.
  void _handleTypeAhead(String character) {
    _typeAheadTimer?.cancel();
    _typeAheadBuffer += character.toLowerCase();
    _typeAheadTimer = Timer(_typeAheadTimeout, () {
      _typeAheadBuffer = '';
    });

    final labelFn = widget.itemLabel!;
    for (var i = 0; i < widget.itemCount; i++) {
      if (labelFn(i).toLowerCase().startsWith(_typeAheadBuffer)) {
        widget.onHighlightChange?.call(i);
        return;
      }
    }
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
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
