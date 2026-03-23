import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_search_debounce.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_morph.dart';
import 'package:obers_ui/src/primitives/overlay/oi_visibility.dart';

/// A toolbar for file browser navigation.
///
/// Displays a breadcrumb path bar with an optional search toggle. When
/// [selectedCount] is greater than zero the toolbar transitions to a selection
/// bar showing the count and [bulkActions].
///
/// {@category Composites}
class OiFileToolbar extends StatefulWidget {
  /// Creates an [OiFileToolbar].
  const OiFileToolbar({
    required this.breadcrumbs,
    required this.label,
    this.selectedCount = 0,
    this.bulkActions = const [],
    this.onSearch,
    super.key,
  });

  /// Breadcrumb items describing the current path.
  final List<OiBreadcrumbItem> breadcrumbs;

  /// Number of currently selected items. When greater than zero the toolbar
  /// transitions to selection mode.
  final int selectedCount;

  /// Widgets rendered in the action area during selection mode.
  final List<Widget> bulkActions;

  /// Called with the search query after a 300 ms debounce. When null the
  /// search icon is hidden.
  final ValueChanged<String>? onSearch;

  /// Semantic label for the toolbar.
  final String label;

  @override
  State<OiFileToolbar> createState() => _OiFileToolbarState();
}

class _OiFileToolbarState extends State<OiFileToolbar> {
  bool _searchOpen = false;
  final OiSearchDebounce _debounce = OiSearchDebounce();
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void didUpdateWidget(OiFileToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset search state when entering selection mode.
    if (widget.selectedCount > 0 && oldWidget.selectedCount == 0) {
      _resetSearch();
    }
  }

  @override
  void dispose() {
    _debounce.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetSearch() {
    _debounce.cancel();
    _searchOpen = false;
    _searchController.clear();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _debounce.cancel();
        _searchController.clear();
      }
    });
  }

  void _onQueryChanged(String query) {
    final callback = widget.onSearch;
    if (callback == null) return;
    _debounce.call(query, callback);
  }

  // ── Build helpers ──────────────────────────────────────────────────────────

  Widget _buildNormalBar(BuildContext context) {
    return Row(
      key: const ValueKey('normal'),
      children: [
        Expanded(child: _buildPathOrSearch(context)),
        if (widget.onSearch != null)
          OiIconButton(
            icon: _searchOpen
                ? OiIcons.x // close
                : OiIcons.search, // search
            semanticLabel: _searchOpen ? 'Close search' : 'Search',
            onTap: _toggleSearch,
          ),
      ],
    );
  }

  Widget _buildSelectionBar(BuildContext context) {
    final theme = OiTheme.of(context);
    return Row(
      key: const ValueKey('selection'),
      children: [
        Expanded(
          child: Text(
            '${widget.selectedCount} selected',
            style: theme.textTheme.body,
          ),
        ),
        ...widget.bulkActions,
      ],
    );
  }

  Widget _buildPathOrSearch(BuildContext context) {
    return OiMorph(
      // ignore: avoid_redundant_argument_values, explicit for clarity.
      transition: OiTransition.fade,
      child: _searchOpen
          ? OiTextInput.search(
              key: const ValueKey('search'),
              controller: _searchController,
              autofocus: true,
              onChanged: _onQueryChanged,
            )
          : OiBreadcrumbs(
              key: const ValueKey('path'),
              items: widget.breadcrumbs,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = widget.selectedCount > 0;
    return Semantics(
      label: widget.label,
      child: OiMorph(
        // ignore: avoid_redundant_argument_values, explicit for clarity.
        transition: OiTransition.fade,
        child: isSelectionMode
            ? _buildSelectionBar(context)
            : _buildNormalBar(context),
      ),
    );
  }
}
