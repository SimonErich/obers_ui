part of '../oi_filter_bar.dart';

// ── Filter popover ──────────────────────────────────────────────────────────

/// An overlay popover that collects a filter value from the user.
///
/// Positioned as a dropdown below the [anchor] point. For select filters the
/// options are shown directly and tapping one applies immediately. For
/// multi-select filters, checkboxes are shown with an Apply button. For text
/// filters with suggestions, a search input with a filterable list is shown.
class _FilterPopover extends StatefulWidget {
  const _FilterPopover({
    required this.definition,
    required this.onApply,
    required this.onClose,
    required this.anchor,
    this.currentFilter,
  });

  final OiFilterDefinition definition;
  final OiColumnFilter? currentFilter;
  final ValueChanged<OiColumnFilter> onApply;
  final VoidCallback onClose;
  final Offset anchor;

  @override
  State<_FilterPopover> createState() => _FilterPopoverState();
}

class _FilterPopoverState extends State<_FilterPopover> {
  late TextEditingController _textController;
  late Set<String> _selectedValues;
  final FocusNode _textFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.currentFilter?.value?.toString() ?? '';
    _textController = TextEditingController(text: initial);

    // Initialize multi-select state.
    final currentValue = widget.currentFilter?.value;
    if (currentValue is List<String>) {
      _selectedValues = Set<String>.of(currentValue);
    } else {
      _selectedValues = {};
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _apply() {
    final value = _textController.text;
    if (value.isNotEmpty) {
      widget.onApply(OiColumnFilter(value: value));
    }
  }

  bool get _isSelect =>
      widget.definition.type == OiFilterType.select &&
      widget.definition.options != null &&
      widget.definition.options!.isNotEmpty;

  bool get _isMultiSelect =>
      widget.definition.type == OiFilterType.multiSelect &&
      widget.definition.options != null &&
      widget.definition.options!.isNotEmpty;

  bool get _isTextWithSuggestions =>
      widget.definition.type == OiFilterType.text &&
      widget.definition.suggestions != null &&
      widget.definition.suggestions!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget content;
    if (_isMultiSelect) {
      content = _buildMultiSelectOptions(context);
    } else if (_isSelect) {
      content = _buildSelectOptions(context);
    } else if (_isTextWithSuggestions) {
      content = _buildSearchSuggestions(context);
    } else {
      content = _buildTextInput(context);
    }

    final needsPadding = !_isSelect && !_isMultiSelect;

    return Stack(
      children: [
        // Barrier that dismisses on tap but lets scroll gestures pass through.
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => widget.onClose(),
          ),
        ),
        // Dropdown positioned below the chip.
        Positioned(
          left: widget.anchor.dx,
          top: widget.anchor.dy,
          child: Container(
            key: const Key('oi_filter_popover'),
            width: _isMultiSelect ? 260 : 220,
            padding: needsPadding
                ? const EdgeInsets.all(12)
                : const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: colors.overlay.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectOptions(BuildContext context) {
    final currentValue = widget.currentFilter?.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in widget.definition.options!)
          _FilterOption(
            label: option.label,
            selected: currentValue == option.value,
            onTap: () => widget.onApply(OiColumnFilter(value: option.value)),
          ),
      ],
    );
  }

  Widget _buildMultiSelectOptions(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in widget.definition.options!)
          _FilterCheckboxOption(
            label: option.label,
            checked: _selectedValues.contains(option.value),
            onChanged: (checked) {
              setState(() {
                if (checked) {
                  _selectedValues.add(option.value);
                } else {
                  _selectedValues.remove(option.value);
                }
              });
            },
          ),
        // Apply button.
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: GestureDetector(
            onTap: () {
              if (_selectedValues.isNotEmpty) {
                widget.onApply(
                  OiColumnFilter(value: _selectedValues.toList()),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _selectedValues.isNotEmpty
                    ? colors.primary.base
                    : colors.border,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                'Apply${_selectedValues.isNotEmpty ? ' (${_selectedValues.length})' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textOnPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    final colors = context.colors;
    final suggestions = widget.definition.suggestions!;
    final filtered = _searchQuery.isEmpty
        ? suggestions
        : suggestions
              .where(
                (s) => s.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiTextInput.search(
          controller: _textController,
          autofocus: true,
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          onSubmitted: (_) => _apply(),
        ),
        if (filtered.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final suggestion in filtered)
                    _FilterOption(
                      label: suggestion,
                      selected: _textController.text == suggestion,
                      onTap: () => widget.onApply(
                        OiColumnFilter(
                          value: suggestion,
                          operator: OiFilterOperator.contains,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ] else if (_searchQuery.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'No results',
              style: TextStyle(fontSize: 13, color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextInput(BuildContext context) {
    final colors = context.colors;

    if (widget.definition.type == OiFilterType.custom &&
        widget.definition.customBuilder != null) {
      return widget.definition.customBuilder!(
        widget.currentFilter?.value,
        (v) => _textController.text = v.toString(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: EditableText(
            controller: _textController,
            focusNode: _textFocusNode,
            style: TextStyle(fontSize: 14, color: colors.text),
            cursorColor: colors.primary.base,
            backgroundCursorColor: colors.border,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          key: const Key('oi_filter_apply'),
          onTap: _apply,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary.base,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
