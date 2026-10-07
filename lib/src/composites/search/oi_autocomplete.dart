import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A search input with asynchronous suggestions, keyboard selection and reset
/// after a pick. Flutter's autocomplete handles stale search completions.
class OiAutocomplete<T> extends StatefulWidget {
  /// Creates a search field that reports selected suggestions to [onSelect].
  const OiAutocomplete({
    required this.label,
    required this.placeholder,
    required this.emptyLabel,
    required this.search,
    required this.labelOf,
    required this.onSelect,
    super.key,
  });

  /// Accessible name of the search input.
  final String label;

  /// Prompt displayed while the query is empty.
  final String placeholder;

  /// Message displayed when a nonempty query has no suggestions.
  final String emptyLabel;

  /// Loads suggestions for the current query.
  final Future<List<T>> Function(String query) search;

  /// Display and accessible label for each suggestion.
  final String Function(T) labelOf;

  /// Reports a pick before the search input resets.
  final ValueChanged<T> onSelect;

  @override
  State<OiAutocomplete<T>> createState() => _OiAutocompleteState<T>();
}

class _OiAutocompleteState<T> extends State<OiAutocomplete<T>> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<Iterable<_Suggestion<T>>> _search(TextEditingValue value) async {
    if (value.text.trim().isEmpty) return [];
    final results = await widget.search(value.text);
    return results.isEmpty
        ? [_EmptySuggestion<T>()]
        : results.map(_ItemSuggestion<T>.new);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => RawAutocomplete<_Suggestion<T>>(
      textEditingController: _controller,
      focusNode: _focus,
      optionsBuilder: _search,
      displayStringForOption: (option) => switch (option) {
        _ItemSuggestion<T>(:final item) => widget.labelOf(item),
        _EmptySuggestion<T>() => '',
      },
      onSelected: (option) {
        if (option case _ItemSuggestion<T>(:final item)) {
          widget.onSelect(item);
        }
        _controller.clear();
      },
      fieldViewBuilder: (context, controller, focus, submit) =>
          OiTextInput.search(
            controller: controller,
            focusNode: focus,
            semanticLabel: widget.label,
            placeholder: widget.placeholder,
            onSubmitted: (_) => submit(),
          ),
      optionsViewBuilder: (context, select, options) {
        final suggestions = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: constraints.maxWidth,
            child: OiSurface(
              border: OiBorderStyle.solid(context.colors.border, 1),
              borderRadius: context.radius.sm,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(context.spacing.xs),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    if (suggestion is! _ItemSuggestion<T>) {
                      return Padding(
                        padding: EdgeInsets.all(context.spacing.sm),
                        child: OiLabel.body(widget.emptyLabel),
                      );
                    }
                    final highlighted =
                        AutocompleteHighlightedOption.of(context) == index;
                    return OiTappable(
                      semanticLabel: widget.labelOf(suggestion.item),
                      focusable: false,
                      onTap: () => select(suggestion),
                      child: OiSurface(
                        color: highlighted ? context.colors.surfaceHover : null,
                        padding: EdgeInsets.all(context.spacing.sm),
                        child: OiLabel.body(widget.labelOf(suggestion.item)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

sealed class _Suggestion<T> {}

class _ItemSuggestion<T> extends _Suggestion<T> {
  _ItemSuggestion(this.item);
  final T item;
}

class _EmptySuggestion<T> extends _Suggestion<T> {}
