import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_morph.dart';

/// A path segment for the [OiPathBar].
///
/// {@category Components}
@immutable
class OiPathSegment {
  /// Creates an [OiPathSegment].
  const OiPathSegment({
    required this.id,
    required this.label,
    this.icon,
    this.onTap,
  });

  /// Unique identifier for this segment.
  final String id;

  /// Display label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Callback when tapped.
  final VoidCallback? onTap;
}

/// A dual-mode path navigation bar.
///
/// In **breadcrumb mode**, shows clickable path segments. In **edit mode**
/// (activated by click or keyboard shortcut), shows a text input where the
/// user can type or paste a path directly.
///
/// ```dart
/// OiPathBar(
///   segments: [OiPathSegment(id: 'home', label: 'Home')],
///   onNavigate: (segment) => navigateTo(segment),
/// )
/// ```
///
/// {@category Components}
class OiPathBar extends StatefulWidget {
  /// Creates an [OiPathBar].
  const OiPathBar({
    required this.segments,
    required this.onNavigate,
    this.onPathSubmit,
    this.editable = true,
    this.showIcon = true,
    this.semanticsLabel,
    super.key,
  });

  /// Path segments to display as breadcrumbs.
  final List<OiPathSegment> segments;

  /// Called when a segment is tapped.
  final ValueChanged<OiPathSegment> onNavigate;

  /// Called when a path is submitted in edit mode.
  final ValueChanged<String>? onPathSubmit;

  /// Whether the path bar can switch to edit mode.
  final bool editable;

  /// Whether to show a folder icon before the first segment.
  final bool showIcon;

  /// Accessibility label.
  final String? semanticsLabel;

  @override
  State<OiPathBar> createState() => _OiPathBarState();
}

class _OiPathBarState extends State<OiPathBar> {
  bool _editing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _fullPath =>
      widget.segments.map((s) => s.label).join(' / ');

  void _enterEditMode() {
    if (!widget.editable) return;
    setState(() {
      _editing = true;
      _controller.text = _fullPath;
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _exitEditMode() {
    setState(() {
      _editing = false;
    });
  }

  void _submitPath() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onPathSubmit?.call(text);
    }
    _exitEditMode();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: widget.semanticsLabel ?? 'Path navigation',
      child: OiMorph(
        child: _editing ? _buildEditMode(colors) : _buildBreadcrumbMode(colors),
      ),
    );
  }

  Widget _buildBreadcrumbMode(dynamic colors) {
    final items = <OiBreadcrumbItem>[];

    for (var i = 0; i < widget.segments.length; i++) {
      final segment = widget.segments[i];
      final isLast = i == widget.segments.length - 1;
      items.add(OiBreadcrumbItem(
        label: segment.label,
        onTap: isLast ? null : () => widget.onNavigate(segment),
      ));
    }

    return GestureDetector(
      key: const ValueKey('breadcrumb-mode'),
      onTap: _enterEditMode,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          if (widget.showIcon && widget.segments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                const IconData(0xe2c7, fontFamily: 'MaterialIcons'), // folder
                size: 16,
                color: (colors as dynamic).textSubtle as Color,
              ),
            ),
          Expanded(
            child: OiBreadcrumbs(items: items),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(dynamic colors) {
    return KeyedSubtree(
      key: const ValueKey('edit-mode'),
      child: OiTextInput(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        onSubmitted: (_) => _submitPath(),
        onEditingComplete: _submitPath,
      ),
    );
  }
}
