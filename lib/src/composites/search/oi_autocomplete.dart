import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

/// A search input with suggestions floating below it.
///
/// Unlike `OiComboBox`, the input is the field itself and nothing opens until
/// the user types. The suggestion list closes when the query is cleared, on
/// Escape, or on a tap outside. Arrow keys move the highlight and Enter
/// selects it.
///
/// Selecting is an action (e.g. navigate to the item), not a value the field
/// keeps: [onSelect] is called and the field resets.
///
/// ```dart
/// OiAutocomplete<Product>(
///   label: 'Search products',
///   placeholder: 'Product name',
///   emptyLabel: 'No products found',
///   search: (query) => repository.search(query),
///   labelOf: (product) => product.name,
///   onSelect: (product) => router.push('/products/${product.id}'),
/// )
/// ```
///
/// {@category Composites}
class OiAutocomplete<T> extends StatefulWidget {
  /// Creates an [OiAutocomplete].
  const OiAutocomplete({
    required this.label,
    required this.search,
    required this.labelOf,
    required this.onSelect,
    this.placeholder,
    this.emptyLabel,
    this.maxListHeight = 320,
    super.key,
  });

  /// Accessibility label for the input.
  final String label;

  /// Returns the suggestions for the typed query. Only called for a
  /// non-blank query; a result arriving after a newer query is discarded.
  final Future<List<T>> Function(String query) search;

  /// Display text of a suggestion.
  final String Function(T) labelOf;

  /// Called with the suggestion the user selected.
  final ValueChanged<T> onSelect;

  /// Placeholder shown while the input is empty.
  final String? placeholder;

  /// Shown in the list when [search] finds nothing. When null, the list stays
  /// closed instead.
  final String? emptyLabel;

  /// Height after which the suggestion list scrolls.
  final double maxListHeight;

  @override
  State<OiAutocomplete<T>> createState() => _OiAutocompleteState<T>();
}

class _OiAutocompleteState<T> extends State<OiAutocomplete<T>> {
  final _controller = TextEditingController();
  late final _focusNode = FocusNode(onKeyEvent: _onKeyEvent);
  final _tapRegionGroup = Object();

  List<T> _results = const [];
  int _highlighted = 0;
  bool _open = false;

  /// Bumped per query so a slow earlier search cannot overwrite a newer one.
  int _queryId = 0;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String query) async {
    final queryId = ++_queryId;
    if (query.trim().isEmpty) {
      _close();
      return;
    }

    final results = await widget.search(query);
    if (!mounted || queryId != _queryId) return;
    setState(() {
      _results = results;
      _highlighted = 0;
      _open = results.isNotEmpty || widget.emptyLabel != null;
    });
  }

  void _close() {
    if (_open) setState(() => _open = false);
  }

  void _select(T item) {
    _queryId++;
    _controller.clear();
    _focusNode.unfocus();
    _close();
    widget.onSelect(item);
  }

  KeyEventResult _onKeyEvent(FocusNode _, KeyEvent event) {
    if (!_open || event is KeyUpEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _close();
    } else if (_results.isEmpty) {
      return KeyEventResult.ignored;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlighted = (_highlighted + 1) % _results.length);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      setState(
        () => _highlighted =
            (_highlighted - 1 + _results.length) % _results.length,
      );
    } else if (key == LogicalKeyboardKey.enter) {
      _select(_results[_highlighted]);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => OiFloating(
        visible: _open,
        anchor: TapRegion(
          groupId: _tapRegionGroup,
          onTapOutside: (_) => _close(),
          child: Semantics(
            label: widget.label,
            child: OiTextInput(
              controller: _controller,
              focusNode: _focusNode,
              placeholder: widget.placeholder,
              leading: const Icon(OiIcons.search, size: 18),
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
            ),
          ),
        ),
        child: TapRegion(
          groupId: _tapRegionGroup,
          child: SizedBox(
            width: constraints.maxWidth,
            child: _SuggestionList<T>(
              results: _results,
              highlighted: _highlighted,
              emptyLabel: widget.emptyLabel,
              maxHeight: widget.maxListHeight,
              labelOf: widget.labelOf,
              onSelect: _select,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionList<T> extends StatelessWidget {
  const _SuggestionList({
    required this.results,
    required this.highlighted,
    required this.emptyLabel,
    required this.maxHeight,
    required this.labelOf,
    required this.onSelect,
  });

  final List<T> results;
  final int highlighted;
  final String? emptyLabel;
  final double maxHeight;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;
    final rowPadding = EdgeInsets.symmetric(horizontal: sp.md, vertical: sp.sm);

    return OiSurface(
      color: colors.surface,
      borderRadius: context.radius.md,
      border: OiBorderStyle.solid(colors.borderSubtle, 1),
      shadow: context.shadows.md,
      padding: EdgeInsets.symmetric(vertical: sp.xs),
      child: results.isEmpty
          ? Padding(
              padding: rowPadding,
              child: OiLabel.body(emptyLabel ?? '', color: colors.textMuted),
            )
          : ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return OiTappable(
                    onTap: () => onSelect(item),
                    focusable: false,
                    child: ColoredBox(
                      color: index == highlighted
                          ? colors.surfaceHover
                          : const Color(0x00000000),
                      child: Padding(
                        padding: rowPadding,
                        child: OiLabel.body(
                          labelOf(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
