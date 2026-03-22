import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/components/inputs/oi_slider.dart';
import 'package:obers_ui/src/components/inputs/oi_switch.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// Immutable data class holding the current filter state for product listings.
///
/// Coverage: REQ-0071
///
/// {@category Composites}
@immutable
class OiProductFilterData {
  /// Creates an [OiProductFilterData].
  const OiProductFilterData({
    this.minPrice,
    this.maxPrice,
    this.categories = const [],
    this.minRating,
    this.inStockOnly = false,
  });

  /// Minimum price filter.
  final double? minPrice;

  /// Maximum price filter.
  final double? maxPrice;

  /// Selected category keys.
  final List<String> categories;

  /// Minimum rating filter (1–5).
  final double? minRating;

  /// When `true`, only in-stock items are shown.
  final bool inStockOnly;

  /// Returns a copy with the specified fields replaced.
  OiProductFilterData copyWith({
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    List<String>? categories,
    Object? minRating = _sentinel,
    bool? inStockOnly,
  }) {
    return OiProductFilterData(
      minPrice: identical(minPrice, _sentinel)
          ? this.minPrice
          : minPrice as double?,
      maxPrice: identical(maxPrice, _sentinel)
          ? this.maxPrice
          : maxPrice as double?,
      categories: categories ?? this.categories,
      minRating: identical(minRating, _sentinel)
          ? this.minRating
          : minRating as double?,
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiProductFilterData) return false;
    return minPrice == other.minPrice &&
        maxPrice == other.maxPrice &&
        listEquals(categories, other.categories) &&
        minRating == other.minRating &&
        inStockOnly == other.inStockOnly;
  }

  @override
  int get hashCode => Object.hash(
    minPrice,
    maxPrice,
    Object.hashAll(categories),
    minRating,
    inStockOnly,
  );

  @override
  String toString() =>
      'OiProductFilterData(minPrice: $minPrice, maxPrice: $maxPrice, '
      'categories: $categories, minRating: $minRating, '
      'inStockOnly: $inStockOnly)';
}

const Object _sentinel = Object();

/// Currency placement relative to the amount.
enum _CurrencyPosition { before, after }

/// Known currency symbols and their placement conventions.
const Map<String, ({String symbol, _CurrencyPosition position})> _currencyMap =
    {
      'USD': (symbol: r'$', position: _CurrencyPosition.before),
      'EUR': (symbol: '€', position: _CurrencyPosition.after),
      'GBP': (symbol: '£', position: _CurrencyPosition.before),
      'CHF': (symbol: 'CHF', position: _CurrencyPosition.before),
    };

/// A filter panel for product listings with price range, category checkboxes,
/// rating filter, and in-stock toggle.
///
/// Coverage: REQ-0071
///
/// Each filter section fires [onChanged] with the updated
/// [OiProductFilterData]. Sections are hidden when not applicable (e.g. no
/// [availableCategories] hides the category filter).
///
/// {@category Composites}
class OiProductFilters extends StatefulWidget {
  /// Creates an [OiProductFilters].
  const OiProductFilters({
    required this.label,
    this.value,
    this.onChanged,
    this.availableCategories = const [],
    this.currencyCode = 'EUR',
    this.priceRangeMin = 0,
    this.priceRangeMax = 1000,
    super.key,
  });

  /// Accessibility label announced by screen readers.
  final String label;

  /// The current filter state. Defaults to an empty [OiProductFilterData].
  final OiProductFilterData? value;

  /// Called when any filter value changes.
  final ValueChanged<OiProductFilterData>? onChanged;

  /// Available category labels for the category filter checkboxes.
  final List<String> availableCategories;

  /// ISO 4217 currency code for price labels. Defaults to `'EUR'`.
  final String currencyCode;

  /// Minimum value for the price range slider.
  final double priceRangeMin;

  /// Maximum value for the price range slider.
  final double priceRangeMax;

  @override
  State<OiProductFilters> createState() => _OiProductFiltersState();
}

class _OiProductFiltersState extends State<OiProductFilters> {
  OiProductFilterData get _data => widget.value ?? const OiProductFilterData();

  void _emit(OiProductFilterData updated) {
    widget.onChanged?.call(updated);
  }

  String _formatCurrency(double value) {
    final currency = _currencyMap[widget.currencyCode.toUpperCase()];
    final formatted = value.toStringAsFixed(0);
    if (currency != null) {
      return currency.position == _CurrencyPosition.before
          ? '${currency.symbol}$formatted'
          : '$formatted ${currency.symbol}';
    }
    return '$formatted ${widget.currencyCode}';
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.xs),
      child: OiLabel.smallStrong(text),
    );
  }

  Widget _buildPriceRange(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    final minVal = _data.minPrice ?? widget.priceRangeMin;
    final maxVal = _data.maxPrice ?? widget.priceRangeMax;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.xs),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(context, 'Price Range'),
        OiRow(
          breakpoint: breakpoint,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OiLabel.small(_formatCurrency(minVal)),
            OiLabel.small(_formatCurrency(maxVal)),
          ],
        ),
        OiSlider(
          value: minVal,
          secondaryValue: maxVal,
          min: widget.priceRangeMin,
          max: widget.priceRangeMax,
          onRangeChanged: (start, end) {
            _emit(_data.copyWith(minPrice: start, maxPrice: end));
          },
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    if (widget.availableCategories.isEmpty) return const SizedBox.shrink();

    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.xs),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(context, 'Category'),
        ...widget.availableCategories.map((category) {
          final selected = _data.categories.contains(category);
          return OiCheckbox(
            value: selected,
            label: category,
            onChanged: (checked) {
              final updated = List<String>.from(_data.categories);
              if (checked) {
                updated.add(category);
              } else {
                updated.remove(category);
              }
              _emit(_data.copyWith(categories: updated));
            },
          );
        }),
      ],
    );
  }

  Widget _buildRatingFilter(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    final currentRating = _data.minRating ?? 0;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.xs),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(context, 'Minimum Rating'),
        OiRow(
          breakpoint: breakpoint,
          gap: OiResponsive(sp.xs),
          children: [
            Expanded(
              child: OiSlider(
                value: currentRating,
                min: 0,
                max: 5,
                divisions: 5,
                onChanged: (value) {
                  _emit(_data.copyWith(minRating: value > 0 ? value : null));
                },
              ),
            ),
            SizedBox(
              width: 32,
              child: OiLabel.small(
                currentRating > 0
                    ? '${currentRating.toStringAsFixed(0)}+'
                    : 'Any',
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockFilter(BuildContext context) {
    return OiRow(
      breakpoint: context.breakpoint,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OiLabel.body('In Stock Only'),
        OiSwitch(
          value: _data.inStockOnly,
          label: 'In stock only',
          onChanged: (value) {
            _emit(_data.copyWith(inStockOnly: value));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return Semantics(
      label: widget.label,
      child: ExcludeSemantics(
        child: OiColumn(
          breakpoint: breakpoint,
          gap: OiResponsive(sp.lg),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceRange(context),
            _buildCategoryFilter(context),
            _buildRatingFilter(context),
            _buildStockFilter(context),
          ],
        ),
      ),
    );
  }
}
