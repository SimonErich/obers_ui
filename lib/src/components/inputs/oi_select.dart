import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';
import 'package:obers_ui/src/primitives/scroll/oi_virtual_list.dart';

/// Tracks which [OiSelect] is currently open within a subtree.
///
/// When any [OiSelect] opens, it notifies this notifier with its own key so
/// that sibling selects can close themselves. Wrap a group of selects (or an
/// entire form) with [OiSelectScope] to enable mutual exclusion.
///
/// {@category Components}
class OiSelectScope extends StatefulWidget {
  /// Creates an [OiSelectScope].
  const OiSelectScope({required this.child, super.key});

  /// The widget subtree that shares the select group.
  final Widget child;

  // Returns the nearest [_OiSelectScopeNotifier] above [context], or null.
  static _OiSelectScopeNotifier? _of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_OiSelectScopeInherited>()
        ?.notifier;
  }

  @override
  State<OiSelectScope> createState() => _OiSelectScopeState();
}

class _OiSelectScopeState extends State<OiSelectScope> {
  final _OiSelectScopeNotifier _notifier = _OiSelectScopeNotifier();

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OiSelectScopeInherited(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class _OiSelectScopeNotifier extends ChangeNotifier {
  Object? _openKey;

  void requestOpen(Object key) {
    if (_openKey == key) return;
    _openKey = key;
    notifyListeners();
  }

  void requestClose(Object key) {
    if (_openKey != key) return;
    _openKey = null;
    notifyListeners();
  }

  bool isOpen(Object key) => _openKey == key;
}

class _OiSelectScopeInherited extends InheritedNotifier<_OiSelectScopeNotifier> {
  const _OiSelectScopeInherited({
    required super.notifier,
    required super.child,
  });
}

/// A single selectable option for [OiSelect].
///
/// {@category Components}
@immutable
class OiSelectOption<T> {
  /// Creates an [OiSelectOption].
  const OiSelectOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  /// The underlying value represented by this option.
  final T value;

  /// The human-readable label shown in the list.
  final String label;

  /// Whether the option can be selected.
  final bool enabled;
}

/// A dropdown select input component.
///
/// Displays the currently selected option (or [placeholder]) inside an
/// [OiInputFrame] and opens an [OiFloating] dropdown on tap. When
/// [searchable] is true a text-filter field is shown at the top of the
/// dropdown. On compact breakpoints [bottomSheetOnCompact] renders the
/// dropdown as a bottom sheet instead.
///
/// {@category Components}
class OiSelect<T> extends StatefulWidget {
  /// Creates an [OiSelect].
  const OiSelect({
    required this.options,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.placeholder,
    this.enabled = true,
    this.searchable = false,
    this.bottomSheetOnCompact = false,
    super.key,
  });

  /// The currently selected value.
  final T? value;

  /// The list of options to display.
  final List<OiSelectOption<T>> options;

  /// Called when the user selects an option.
  final ValueChanged<T?>? onChanged;

  /// Optional label rendered above the frame.
  final String? label;

  /// Optional hint rendered below the frame.
  final String? hint;

  /// Validation error message.
  final String? error;

  /// Text shown when no value is selected.
  final String? placeholder;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// When true a search field is shown at the top of the dropdown.
  final bool searchable;

  /// When true the dropdown appears as a bottom sheet on compact breakpoints.
  final bool bottomSheetOnCompact;

  @override
  State<OiSelect<T>> createState() => _OiSelectState<T>();
}

class _OiSelectState<T> extends State<OiSelect<T>> {
  bool _open = false;
  String _query = '';
  late TextEditingController _searchCtrl;
  late FocusNode _searchFocus;
  _OiSelectScopeNotifier? _scope;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchFocus = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newScope = OiSelectScope._of(context);
    if (newScope != _scope) {
      _scope?.removeListener(_onScopeChanged);
      _scope = newScope;
      _scope?.addListener(_onScopeChanged);
    }
  }

  void _onScopeChanged() {
    if (_open && !(_scope?.isOpen(widget.key ?? this) ?? true)) {
      setState(() => _open = false);
    }
  }

  @override
  void dispose() {
    _scope?.removeListener(_onScopeChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<OiSelectOption<T>> get _filtered {
    if (_query.isEmpty) return widget.options;
    final lower = _query.toLowerCase();
    return widget.options
        .where((o) => o.label.toLowerCase().contains(lower))
        .toList();
  }

  void _open_() {
    if (!widget.enabled) return;
    _query = '';
    _searchCtrl.clear();
    _scope?.requestOpen(widget.key ?? this);
    setState(() => _open = true);
    if (widget.searchable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    }
  }

  void _close() {
    _scope?.requestClose(widget.key ?? this);
    setState(() => _open = false);
  }

  void _select(OiSelectOption<T> option) {
    if (!option.enabled) return;
    widget.onChanged?.call(option.value);
    _close();
  }

  String? get _selectedLabel {
    if (widget.value == null) return null;
    for (final o in widget.options) {
      if (o.value == widget.value) return o.label;
    }
    return null;
  }

  Widget _buildDropdown(BuildContext context) {
    final colors = context.colors;
    final filtered = _filtered;
    const itemHeight = 44.0;
    final maxHeight = (itemHeight * 6).clamp(0.0, 300.0);

    return UnconstrainedBox(
      alignment: Alignment.topLeft,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colors.overlay,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.all(8),
                child: OiRawInput(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  placeholder: 'Search…',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No options',
                  style: TextStyle(color: colors.textMuted, fontSize: 14),
                ),
              )
            else
              SizedBox(
                height: (itemHeight * filtered.length).clamp(0.0, maxHeight),
                child: OiVirtualList(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final option = filtered[i];
                    final isSelected = option.value == widget.value;
                    return GestureDetector(
                      onTap: option.enabled ? () => _select(option) : null,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: itemHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        color: isSelected
                            ? colors.primary.base.withValues(alpha: 0.1)
                            : null,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: !option.enabled
                                  ? colors.textMuted
                                  : isSelected
                                  ? colors.primary.base
                                  : colors.text,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = _selectedLabel;
    final displayText = label ?? widget.placeholder ?? '';
    final hasValue = label != null;

    final chevron = Icon(
      OiIcons.arrowDown,
      size: 16,
      color: colors.textMuted,
    );

    final anchor = GestureDetector(
      onTap: widget.enabled ? _open_ : null,
      behavior: HitTestBehavior.opaque,
      child: OiInputFrame(
        label: widget.label,
        hint: widget.hint,
        error: widget.error,
        focused: _open,
        enabled: widget.enabled,
        trailing: chevron,
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            color: hasValue ? colors.text : colors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    return OiFloating(
      visible: _open,
      bottomSheetOnCompact: widget.bottomSheetOnCompact,
      onDismiss: _close,
      anchor: anchor,
      child: _buildDropdown(context),
    );
  }
}
