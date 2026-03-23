import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A themed sliver list that wraps [SliverList] with consistent padding,
/// optional dividers, and accessibility support.
///
/// Use [OiSliverList] inside a [CustomScrollView] or any sliver-based scroll
/// view to display a lazily-built list of items with design-system defaults.
///
/// When [separated] is `true` or a custom [separatorBuilder] is provided, a
/// themed divider (1 px line using `colors.borderSubtle`) is inserted
/// between items.
///
/// ```dart
/// OiSliverList(
///   itemCount: items.length,
///   itemBuilder: (context, index) => OiLabel.body(items[index]),
///   separated: true,
///   padding: EdgeInsets.all(context.spacing.md),
/// )
/// ```
///
/// {@category Primitives}
class OiSliverList extends StatelessWidget {
  /// Creates an [OiSliverList] using the builder pattern.
  ///
  /// Items are built lazily via [itemBuilder]. When [separated] is `true`, a
  /// default divider is shown between items. Provide [separatorBuilder] to
  /// override the default separator widget.
  const OiSliverList({
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.separated = false,
    this.separatorBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticLabel,
    super.key,
  }) : children = null;

  /// Creates a sliver list from an explicit list of [children].
  ///
  /// Prefer the default constructor with [itemBuilder] for large or dynamic
  /// lists. This constructor is convenient for short, static lists that are
  /// already materialised.
  const OiSliverList.children({
    required List<Widget> this.children,
    this.padding,
    this.semanticLabel,
    super.key,
  })  : itemCount = 0,
        itemBuilder = null,
        separated = false,
        separatorBuilder = null,
        addAutomaticKeepAlives = true,
        addRepaintBoundaries = true,
        addSemanticIndexes = true;

  /// The total number of items in the list.
  final int itemCount;

  /// Builds the widget for the item at the given index.
  final Widget Function(BuildContext, int)? itemBuilder;

  /// Optional padding around the entire sliver.
  ///
  /// When non-null the sliver is wrapped in a [SliverPadding].
  final EdgeInsetsGeometry? padding;

  /// Whether to insert a default separator between items.
  ///
  /// The default separator is a 1 px horizontal line coloured with
  /// `colors.borderSubtle`. Set [separatorBuilder] to override.
  final bool separated;

  /// Optional builder for a custom separator widget between items.
  ///
  /// When provided, [separated] is implicitly treated as `true`.
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  final bool addRepaintBoundaries;

  /// Whether to provide semantic indexes for each child.
  final bool addSemanticIndexes;

  /// An optional semantic label for the list.
  ///
  /// When non-null the sliver is wrapped in a [Semantics] widget.
  final String? semanticLabel;

  /// Explicit list of children for the [OiSliverList.children] constructor.
  final List<Widget>? children;

  /// Whether this list should show separators between items.
  bool get _hasSeparators => separated || separatorBuilder != null;

  @override
  Widget build(BuildContext context) {
    Widget sliver;

    if (children != null) {
      // Static children list.
      sliver = SliverList(
        delegate: SliverChildListDelegate(
          children!,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
      );
    } else if (_hasSeparators) {
      // Separated builder — interleave items with separators.
      final effectiveSeparatorBuilder = separatorBuilder ??
          (BuildContext ctx, int index) => _DefaultSeparator(
                color: ctx.colors.borderSubtle,
              );

      sliver = SliverList.separated(
        itemCount: itemCount,
        itemBuilder: itemBuilder!,
        separatorBuilder: effectiveSeparatorBuilder,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
    } else {
      // Standard builder.
      sliver = SliverList.builder(
        itemCount: itemCount,
        itemBuilder: itemBuilder!,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
    }

    // Wrap in padding when requested.
    if (padding != null) {
      sliver = SliverPadding(
        padding: padding!,
        sliver: sliver,
      );
    }

    // Wrap in semantics when a label is provided.
    if (semanticLabel != null) {
      sliver = Semantics(
        label: semanticLabel,
        child: sliver,
      );
    }

    return sliver;
  }
}

/// A 1 px horizontal divider used as the default separator.
class _DefaultSeparator extends StatelessWidget {
  const _DefaultSeparator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: color),
        ),
      ),
      child: const SizedBox(width: double.infinity, height: 1),
    );
  }
}
