import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';

/// A command in the command bar.
///
/// Represents an executable action with optional metadata such as category,
/// keyboard shortcut, icon, and nested sub-commands.
///
/// {@category Composites}
@immutable
class OiCommand {
  /// Creates an [OiCommand].
  const OiCommand({
    required this.id,
    required this.label,
    this.description,
    this.icon,
    this.category,
    this.shortcut,
    this.onExecute,
    this.children,
    this.keywords = const [],
    this.priority = 0,
  });

  /// Unique identifier for the command.
  final String id;

  /// The display label shown in the command list.
  final String label;

  /// Optional description shown below the label.
  final String? description;

  /// Optional icon displayed before the label.
  final IconData? icon;

  /// Optional category used for grouping.
  final String? category;

  /// Optional keyboard shortcut activator displayed alongside the command.
  final ShortcutActivator? shortcut;

  /// Called when the command is executed.
  final VoidCallback? onExecute;

  /// Optional nested sub-commands.
  ///
  /// When non-null the command acts as a parent; selecting it drills down
  /// into its children instead of executing.
  final List<OiCommand>? children;

  /// Additional keywords for fuzzy search matching.
  final List<String> keywords;

  /// Priority for sorting. Higher values appear first.
  final int priority;
}

/// A command palette for quick access to actions via fuzzy search.
///
/// VS Code/Raycast-style command bar with fuzzy search, nested commands,
/// keyboard shortcut display, and category grouping.
///
/// {@category Composites}
class OiCommandBar extends StatefulWidget {
  /// Creates an [OiCommandBar].
  const OiCommandBar({
    super.key,
    required this.commands,
    this.onDismiss,
    this.showRecent = true,
    this.fuzzySearch = true,
    this.previewBuilder,
    this.contextCommands,
    required this.label,
  });

  /// The list of available commands.
  final List<OiCommand> commands;

  /// Called when the user dismisses the command bar.
  final VoidCallback? onDismiss;

  /// Whether to show recent commands when the query is empty.
  final bool showRecent;

  /// Whether to use fuzzy matching instead of substring matching.
  final bool fuzzySearch;

  /// Optional builder for a preview pane for the highlighted command.
  final Widget Function(OiCommand)? previewBuilder;

  /// Optional function to provide context-specific commands.
  final List<OiCommand> Function(BuildContext)? contextCommands;

  /// Accessibility label for the command bar.
  final String label;

  @override
  State<OiCommandBar> createState() => _OiCommandBarState();
}

class _OiCommandBarState extends State<OiCommandBar> {
  late TextEditingController _textController;
  late FocusNode _inputFocusNode;
  int _highlightedIndex = 0;
  List<OiCommand> _filteredCommands = [];
  final List<OiCommand> _recentCommands = [];
  List<OiCommand>? _commandStack;
  String? _parentLabel;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _inputFocusNode = FocusNode(onKeyEvent: _handleKeyEvent);
    _filteredCommands = _sortedCommands(widget.commands);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inputFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(OiCommandBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commands != widget.commands) {
      _applyFilter(_textController.text);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // ── Active command list ───────────────────────────────────────────────────

  List<OiCommand> get _activeCommands => _commandStack ?? widget.commands;

  // ── Sorting ───────────────────────────────────────────────────────────────

  List<OiCommand> _sortedCommands(List<OiCommand> commands) {
    return List<OiCommand>.from(commands)
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  void _applyFilter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCommands = _sortedCommands(_activeCommands);
      } else if (widget.fuzzySearch) {
        _filteredCommands = _fuzzyFilter(_activeCommands, query);
      } else {
        _filteredCommands = _substringFilter(_activeCommands, query);
      }
      _highlightedIndex = _filteredCommands.isEmpty ? -1 : 0;
    });
  }

  List<OiCommand> _substringFilter(List<OiCommand> commands, String query) {
    final lower = query.toLowerCase();
    return _sortedCommands(
      commands.where((cmd) {
        final matchLabel = cmd.label.toLowerCase().contains(lower);
        final matchDesc =
            cmd.description?.toLowerCase().contains(lower) ?? false;
        final matchKeywords = cmd.keywords.any(
          (k) => k.toLowerCase().contains(lower),
        );
        return matchLabel || matchDesc || matchKeywords;
      }).toList(),
    );
  }

  List<OiCommand> _fuzzyFilter(List<OiCommand> commands, String query) {
    final lower = query.toLowerCase();
    final scored = <(OiCommand, int)>[];

    for (final cmd in commands) {
      final score = _fuzzyScore(cmd, lower);
      if (score > 0) {
        scored.add((cmd, score));
      }
    }

    scored.sort((a, b) {
      // Higher score first, then higher priority.
      final cmp = b.$2.compareTo(a.$2);
      if (cmp != 0) return cmp;
      return b.$1.priority.compareTo(a.$1.priority);
    });

    return scored.map((e) => e.$1).toList();
  }

  /// Returns a positive score if [query] fuzzy-matches against [cmd],
  /// or 0 if there is no match.
  int _fuzzyScore(OiCommand cmd, String query) {
    final targets = [
      cmd.label.toLowerCase(),
      if (cmd.description != null) cmd.description!.toLowerCase(),
      ...cmd.keywords.map((k) => k.toLowerCase()),
    ];

    var bestScore = 0;
    for (final target in targets) {
      final score = _fuzzyMatchScore(target, query);
      if (score > bestScore) bestScore = score;
    }
    return bestScore;
  }

  /// Simple fuzzy match: checks if all characters of [query] appear in
  /// [target] in order. Returns a score based on how closely they match.
  int _fuzzyMatchScore(String target, String query) {
    var qi = 0;
    var score = 0;
    var lastMatchIndex = -1;

    for (var ti = 0; ti < target.length && qi < query.length; ti++) {
      if (target[ti] == query[qi]) {
        score += 1;
        // Bonus for consecutive matches.
        if (lastMatchIndex == ti - 1) score += 2;
        // Bonus for word boundary matches.
        if (ti == 0 || target[ti - 1] == ' ') score += 3;
        lastMatchIndex = ti;
        qi++;
      }
    }

    // All query characters must be found.
    return qi == query.length ? score : 0;
  }

  // ── Grouped display ───────────────────────────────────────────────────────

  Map<String?, List<OiCommand>> get _grouped {
    final groups = <String?, List<OiCommand>>{};
    for (final cmd in _filteredCommands) {
      groups.putIfAbsent(cmd.category, () => []).add(cmd);
    }
    return groups;
  }

  // ── Drill-down ────────────────────────────────────────────────────────────

  void _drillDown(OiCommand cmd) {
    if (cmd.children != null && cmd.children!.isNotEmpty) {
      setState(() {
        _commandStack = cmd.children;
        _parentLabel = cmd.label;
        _textController.clear();
        _filteredCommands = _sortedCommands(cmd.children!);
        _highlightedIndex = _filteredCommands.isEmpty ? -1 : 0;
      });
      return;
    }

    _executeCommand(cmd);
  }

  void _goBack() {
    setState(() {
      _commandStack = null;
      _parentLabel = null;
      _textController.clear();
      _filteredCommands = _sortedCommands(widget.commands);
      _highlightedIndex = _filteredCommands.isEmpty ? -1 : 0;
    });
  }

  // ── Execution ─────────────────────────────────────────────────────────────

  void _executeCommand(OiCommand cmd) {
    // Track recent.
    _recentCommands
      ..removeWhere((c) => c.id == cmd.id)
      ..insert(0, cmd);
    if (_recentCommands.length > 10) {
      _recentCommands.removeRange(10, _recentCommands.length);
    }

    cmd.onExecute?.call();
  }

  // ── Keyboard ──────────────────────────────────────────────────────────────

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1).clamp(
          0,
          _filteredCommands.length - 1,
        );
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _highlightedIndex = (_highlightedIndex - 1).clamp(
          0,
          _filteredCommands.length - 1,
        );
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 &&
          _highlightedIndex < _filteredCommands.length) {
        _drillDown(_filteredCommands[_highlightedIndex]);
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_commandStack != null) {
        _goBack();
      } else {
        widget.onDismiss?.call();
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _textController.text.isEmpty &&
        _commandStack != null) {
      _goBack();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Shortcut display ──────────────────────────────────────────────────────

  /// Formats a [ShortcutActivator] into a human-readable string.
  String _formatShortcut(ShortcutActivator activator) {
    if (activator is SingleActivator) {
      final parts = <String>[];
      if (activator.control) parts.add('Ctrl');
      if (activator.meta) parts.add('\u2318');
      if (activator.alt) parts.add('Alt');
      if (activator.shift) parts.add('Shift');
      parts.add(activator.trigger.keyLabel);
      return parts.join('+');
    }
    return activator.toString();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final grouped = _grouped;
    final highlightedCommand =
        _highlightedIndex >= 0 && _highlightedIndex < _filteredCommands.length
        ? _filteredCommands[_highlightedIndex]
        : null;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: Container(
        width: widget.previewBuilder != null ? 640 : 480,
        constraints: const BoxConstraints(maxHeight: 420),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.overlay,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Back button when drilled down
                  if (_commandStack != null) ...[
                    GestureDetector(
                      onTap: _goBack,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceActive,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _parentLabel ?? 'Back',
                          style: TextStyle(fontSize: 12, color: colors.text),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OiRawInput(
                      controller: _textController,
                      focusNode: _inputFocusNode,
                      placeholder: _commandStack != null
                          ? 'Search in ${_parentLabel ?? "submenu"}\u2026'
                          : 'Type a command\u2026',
                      onChanged: _applyFilter,
                      leading: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          const IconData(0xe5c5, fontFamily: 'MaterialIcons'),
                          size: 16,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Command list
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCommandList(context, grouped)),
                  if (widget.previewBuilder != null &&
                      highlightedCommand != null)
                    Container(
                      width: 220,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: colors.borderSubtle),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: widget.previewBuilder!(highlightedCommand),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandList(
    BuildContext context,
    Map<String?, List<OiCommand>> grouped,
  ) {
    final colors = context.colors;

    if (_filteredCommands.isEmpty) {
      // Show recent or empty
      if (widget.showRecent &&
          _recentCommands.isNotEmpty &&
          _textController.text.isEmpty) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCategoryHeader(context, 'Recent'),
              for (final cmd in _recentCommands)
                _buildCommandTile(context, cmd),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No commands found',
            style: TextStyle(color: colors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in grouped.entries) ...[
            if (entry.key != null) _buildCategoryHeader(context, entry.key!),
            for (final cmd in entry.value) _buildCommandTile(context, cmd),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String category) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.textMuted,
        ),
      ),
    );
  }

  Widget _buildCommandTile(BuildContext context, OiCommand cmd) {
    final colors = context.colors;
    final index = _filteredCommands.indexOf(cmd);
    final isHighlighted = index == _highlightedIndex;
    final hasChildren = cmd.children != null && cmd.children!.isNotEmpty;

    return GestureDetector(
      onTap: () => _drillDown(cmd),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isHighlighted ? colors.surfaceHover : null,
        child: Row(
          children: [
            if (cmd.icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(cmd.icon, size: 16, color: colors.text),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cmd.label,
                    style: TextStyle(fontSize: 14, color: colors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cmd.description != null)
                    Text(
                      cmd.description!,
                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (hasChildren)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  const IconData(0xe5cc, fontFamily: 'MaterialIcons'),
                  size: 14,
                  color: colors.textMuted,
                ),
              ),
            if (cmd.shortcut != null && !hasChildren)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: Text(
                    _formatShortcut(cmd.shortcut!),
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
