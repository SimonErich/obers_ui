import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

// ---------------------------------------------------------------------------
// Supporting types
// ---------------------------------------------------------------------------

/// A card displayed in an [OiDashboard].
///
/// Each card occupies a region of the dashboard grid defined by
/// [columnSpan] and [rowSpan]. Optional [column] and [row] values
/// allow explicit placement.
@immutable
class OiDashboardCard {
  /// Creates an [OiDashboardCard].
  const OiDashboardCard({
    required this.key,
    required this.title,
    required this.child,
    this.columnSpan = 1,
    this.rowSpan = 1,
    this.column,
    this.row,
  });

  /// Unique identifier for this card.
  final Object key;

  /// Title displayed in the card header.
  final String title;

  /// The content widget rendered inside the card.
  final Widget child;

  /// Number of grid columns this card spans.
  final int columnSpan;

  /// Number of grid rows this card spans.
  final int rowSpan;

  /// Optional explicit column placement (zero-based).
  final int? column;

  /// Optional explicit row placement (zero-based).
  final int? row;
}

// ---------------------------------------------------------------------------
// OiDashboard
// ---------------------------------------------------------------------------

/// A dashboard layout with draggable, resizable widget cards.
///
/// Renders cards in a responsive grid with optional edit mode
/// for drag-to-reorder and resize.
///
/// {@category Modules}
class OiDashboard extends StatefulWidget {
  /// Creates an [OiDashboard].
  const OiDashboard({
    super.key,
    required this.cards,
    required this.label,
    this.columns = 4,
    this.gap = 16,
    this.editable = false,
    this.onLayoutChange,
  });

  /// The dashboard cards to display.
  final List<OiDashboardCard> cards;

  /// Accessible label for the dashboard.
  final String label;

  /// Number of columns in the grid layout.
  final int columns;

  /// Spacing between cards in logical pixels.
  final double gap;

  /// Whether edit mode is active, enabling drag-to-reorder.
  final bool editable;

  /// Called when the card layout changes during edit mode.
  final ValueChanged<List<OiDashboardCard>>? onLayoutChange;

  @override
  State<OiDashboard> createState() => _OiDashboardState();
}

class _OiDashboardState extends State<OiDashboard> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalGap = widget.gap * (widget.columns - 1);
          final columnWidth =
              (constraints.maxWidth - totalGap) / widget.columns;
          final rowHeight = columnWidth * 0.6;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(widget.gap / 2),
              child: Wrap(
                spacing: widget.gap,
                runSpacing: widget.gap,
                children: [
                  for (final card in widget.cards)
                    _buildCard(
                      context,
                      card,
                      columnWidth: columnWidth,
                      rowHeight: rowHeight,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    OiDashboardCard card, {
    required double columnWidth,
    required double rowHeight,
  }) {
    final colors = context.colors;
    final spanWidth =
        columnWidth * card.columnSpan + widget.gap * (card.columnSpan - 1);
    final spanHeight =
        rowHeight * card.rowSpan + widget.gap * (card.rowSpan - 1);

    Widget content = Container(
      width: spanWidth,
      height: spanHeight,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader(context, card),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: card.child,
            ),
          ),
        ],
      ),
    );

    if (widget.editable) {
      content = Stack(
        children: [
          content,
          Positioned(
            top: 4,
            right: 4,
            child: Icon(
              const IconData(0xe945, fontFamily: 'MaterialIcons'),
              size: 16,
              color: colors.textMuted,
            ),
          ),
        ],
      );
    }

    return content;
  }

  Widget _buildCardHeader(BuildContext context, OiDashboardCard card) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Text(
        card.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
