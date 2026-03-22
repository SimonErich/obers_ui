import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_kanban_settings.dart';
import 'package:obers_ui/src/primitives/gesture/oi_double_tap.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Supporting types
// ---------------------------------------------------------------------------

/// A column in an [OiKanban] board.
///
/// Each column has a unique [key], a [title], a list of [items], and an
/// optional [color] accent applied to the column header.
@immutable
class OiKanbanColumn<T> {
  /// Creates an [OiKanbanColumn].
  const OiKanbanColumn({
    required this.key,
    required this.title,
    required this.items,
    this.color,
  });

  /// Unique identifier for this column.
  final Object key;

  /// Title displayed in the column header.
  final String title;

  /// The cards contained in this column.
  final List<T> items;

  /// Optional accent colour for the column header.
  final Color? color;
}

// ---------------------------------------------------------------------------
// OiKanban
// ---------------------------------------------------------------------------

/// A Kanban board with draggable cards across columns.
///
/// Supports drag-and-drop between columns, column reordering, WIP limits,
/// collapsible columns, and quick card editing.
///
/// On compact screens, renders a single-column swipe view so users can
/// navigate between columns with left/right swipe gestures.
///
/// {@category Modules}
class OiKanban<T> extends StatefulWidget {
  /// Creates an [OiKanban].
  const OiKanban({
    required this.columns,
    required this.label,
    super.key,
    this.onCardMove,
    this.onColumnReorder,
    this.cardBuilder,
    this.columnHeader,
    this.reorderColumns = true,
    this.wipLimits,
    this.quickEdit = true,
    this.collapsibleColumns = true,
    this.addColumn = false,
    this.onAddColumn,
    this.cardKey,
    this.settingsDriver,
    this.settingsKey,
    this.settingsNamespace = 'oi_kanban',
  });

  /// The columns displayed on the board.
  final List<OiKanbanColumn<T>> columns;

  /// Accessible label for the kanban board.
  final String label;

  /// Called when a card is moved between columns.
  final void Function(T item, Object fromColumn, Object toColumn, int newIndex)?
  onCardMove;

  /// Called when columns are reordered.
  final void Function(int oldIndex, int newIndex)? onColumnReorder;

  /// Custom builder for card widgets. Falls back to [toString] in a card.
  final Widget Function(T item)? cardBuilder;

  /// Custom builder for column header widgets.
  final Widget Function(OiKanbanColumn<T>)? columnHeader;

  /// Whether columns may be reordered by the user.
  final bool reorderColumns;

  /// Work-in-progress limits per column, keyed by [OiKanbanColumn.key].
  final Map<Object, int>? wipLimits;

  /// Whether quick-edit mode is enabled (double-tap column title to edit).
  final bool quickEdit;

  /// Whether columns can be collapsed.
  final bool collapsibleColumns;

  /// Whether to show an "Add column" button at the end.
  final bool addColumn;

  /// Called when the user taps the "Add column" button.
  final VoidCallback? onAddColumn;

  /// Extracts a unique key from each card item.
  final Object Function(T)? cardKey;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this kanban's settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  @override
  State<OiKanban<T>> createState() => _OiKanbanState<T>();
}

class _OiKanbanState<T> extends State<OiKanban<T>>
    with OiSettingsMixin<OiKanban<T>, OiKanbanSettings> {
  final Set<Object> _collapsedColumns = {};
  Object? _editingColumnKey;
  final TextEditingController _editingController = TextEditingController();
  final FocusNode _editingFocusNode = FocusNode();
  final PageController _pageController = PageController();
  int _compactPageIndex = 0;

  /// Resolved driver: explicit widget prop → OiSettingsProvider → null.
  OiSettingsDriver? _resolvedDriver;

  // ── OiSettingsMixin contract ───────────────────────────────────────────────

  @override
  String get settingsNamespace => widget.settingsNamespace;

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => _resolvedDriver;

  @override
  OiKanbanSettings get defaultSettings => const OiKanbanSettings();

  @override
  OiKanbanSettings deserializeSettings(Map<String, dynamic> json) =>
      OiKanbanSettings.fromJson(json);

  @override
  OiKanbanSettings mergeSettings(
    OiKanbanSettings saved,
    OiKanbanSettings defaults,
  ) => saved.mergeWith(defaults);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    _resolvedDriver = widget.settingsDriver;
    super.initState();
    _editingFocusNode.addListener(_onEditFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        reloadSettings();
      }
    }
    if (settingsLoaded && settingsDriver != null) {
      _applySettings(currentSettings);
    }
  }

  @override
  void dispose() {
    _editingController.dispose();
    _editingFocusNode
      ..removeListener(_onEditFocusChange)
      ..dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _applySettings(OiKanbanSettings settings) {
    _collapsedColumns
      ..clear()
      ..addAll(settings.collapsedColumnKeys);
  }

  OiKanbanSettings _toSettings() {
    return OiKanbanSettings(
      collapsedColumnKeys: Set<Object>.from(_collapsedColumns),
    );
  }

  void _onEditFocusChange() {
    if (!_editingFocusNode.hasFocus && _editingColumnKey != null) {
      setState(() => _editingColumnKey = null);
    }
  }

  void _toggleCollapse(Object columnKey) {
    setState(() {
      if (_collapsedColumns.contains(columnKey)) {
        _collapsedColumns.remove(columnKey);
      } else {
        _collapsedColumns.add(columnKey);
      }
    });
    updateSettings(_toSettings());
  }

  void _startEditing(OiKanbanColumn<T> column) {
    setState(() {
      _editingColumnKey = column.key;
      _editingController.text = column.title;
    });
    _editingFocusNode.requestFocus();
  }

  void _commitEdit() {
    setState(() => _editingColumnKey = null);
    _editingFocusNode.unfocus();
  }

  bool _isOverWipLimit(OiKanbanColumn<T> column) {
    if (widget.wipLimits == null) return false;
    final limit = widget.wipLimits![column.key];
    if (limit == null) return false;
    return column.items.length > limit;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    return Semantics(
      label: widget.label,
      container: true,
      child: isCompact
          ? _buildCompactView(context)
          : _buildExpandedView(context),
    );
  }

  Widget _buildExpandedView(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final column in widget.columns) _buildColumn(context, column),
          if (widget.addColumn) _buildAddColumnButton(context),
        ],
      ),
    );
  }

  Widget _buildCompactView(BuildContext context) {
    final colors = context.colors;
    final totalColumns = widget.columns.length;

    if (totalColumns == 0) {
      return widget.addColumn
          ? _buildAddColumnButton(context)
          : const SizedBox.shrink();
    }

    return Column(
      children: [
        // Page indicator with navigation arrows.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OiTappable(
                onTap: _compactPageIndex > 0
                    ? () {
                        final reduced =
                            context.animations.reducedMotion ||
                            MediaQuery.disableAnimationsOf(context);
                        final next = _compactPageIndex - 1;
                        if (reduced) {
                          _pageController.jumpToPage(next);
                        } else {
                          _pageController.animateToPage(
                            next,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                    : null,
                child: Icon(
                  OiIcons.chevronLeft,
                  size: 20,
                  color: _compactPageIndex > 0 ? colors.text : colors.textMuted,
                ),
              ),
              Text(
                '${_compactPageIndex + 1} / $totalColumns',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textSubtle,
                ),
              ),
              OiTappable(
                onTap: _compactPageIndex < totalColumns - 1
                    ? () {
                        final reduced =
                            context.animations.reducedMotion ||
                            MediaQuery.disableAnimationsOf(context);
                        final next = _compactPageIndex + 1;
                        if (reduced) {
                          _pageController.jumpToPage(next);
                        } else {
                          _pageController.animateToPage(
                            next,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                    : null,
                child: Icon(
                  OiIcons.chevronRight,
                  size: 20,
                  color: _compactPageIndex < totalColumns - 1
                      ? colors.text
                      : colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalColumns,
            onPageChanged: (index) {
              setState(() => _compactPageIndex = index);
            },
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: _buildColumn(context, widget.columns[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, OiKanbanColumn<T> column) {
    final colors = context.colors;
    final collapsed = _collapsedColumns.contains(column.key);
    final overWip = _isOverWipLimit(column);

    return Container(
      width: 280,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: overWip ? colors.error.base : colors.borderSubtle,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildColumnHeader(context, column, collapsed, overWip),
          if (!collapsed) _buildColumnBody(context, column),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(
    BuildContext context,
    OiKanbanColumn<T> column,
    bool collapsed,
    bool overWip,
  ) {
    final colors = context.colors;

    if (widget.columnHeader != null) {
      return widget.columnHeader!(column);
    }

    final wipLimit = widget.wipLimits?[column.key];
    final isEditing = _editingColumnKey == column.key;

    Widget titleWidget;
    if (isEditing) {
      titleWidget = EditableText(
        controller: _editingController,
        focusNode: _editingFocusNode,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
        cursorColor: colors.primary.base,
        backgroundCursorColor: colors.surfaceHover,
        onSubmitted: (_) => _commitEdit(),
      );
    } else {
      titleWidget = Text(
        column.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final headerContent = OiDoubleTap(
      enabled: widget.quickEdit && !isEditing,
      onDoubleTap: () => _startEditing(column),
      child: OiTappable(
        onTap: widget.collapsibleColumns && !isEditing
            ? () => _toggleCollapse(column.key)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: column.color?.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              if (column.color != null)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: column.color,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(child: titleWidget),
              Text(
                wipLimit != null
                    ? '${column.items.length}/$wipLimit'
                    : '${column.items.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: overWip ? colors.error.base : colors.textMuted,
                ),
              ),
              if (widget.collapsibleColumns) ...[
                const SizedBox(width: 4),
                Icon(
                  collapsed
                      ? OiIcons.chevronDown
                      : OiIcons.chevronUp,
                  size: 16,
                  color: colors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return headerContent;
  }

  Widget _buildColumnBody(BuildContext context, OiKanbanColumn<T> column) {
    final colors = context.colors;

    if (column.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No items',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: colors.textMuted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < column.items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
              child: _buildCard(context, column.items[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, T item) {
    final colors = context.colors;

    if (widget.cardBuilder != null) {
      return widget.cardBuilder!(item);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Text(
        item.toString(),
        style: TextStyle(fontSize: 13, color: colors.text),
      ),
    );
  }

  Widget _buildAddColumnButton(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: OiTappable(
        onTap: widget.onAddColumn,
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                OiIcons.plus,
                size: 16,
                color: colors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'Add column',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
