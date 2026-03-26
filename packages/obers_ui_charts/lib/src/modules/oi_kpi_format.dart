/// Status classification for a KPI metric.
///
/// Used to drive color coding and visual emphasis on [OiKpiCard] widgets.
///
/// {@category Modules}
enum OiKpiStatus {
  /// The metric is on track toward its target.
  onTrack,

  /// The metric requires attention but is not yet critical.
  needsAttention,

  /// The metric is in a critical state and requires immediate action.
  critical,

  /// No status classification — neutral presentation.
  neutral,
}

/// Visual layout style for a [OiKpiCard].
///
/// {@category Modules}
enum OiKpiCardStyle {
  /// Standard card with title, value, delta, sparkline, and target.
  standard,

  /// Compact card showing only the value and delta — for dense dashboards.
  compact,

  /// Detailed card that additionally shows trend description and
  /// min/max/avg derived from sparkline data.
  detailed,
}

// ─────────────────────────────────────────────────────────────────────────────
// OiKpiFormat
// ─────────────────────────────────────────────────────────────────────────────

/// A value formatter for KPI metric display.
///
/// Use the named factory constructors to create common format types:
/// - [OiKpiFormat.currency] — prefixed currency symbol with optional decimals.
/// - [OiKpiFormat.number] — plain number with optional decimals.
/// - [OiKpiFormat.percentage] — value multiplied by 100 with a `%` suffix.
/// - [OiKpiFormat.custom] — arbitrary [String Function(num)] formatter.
///
/// ```dart
/// OiKpiFormat.currency(symbol: '\$')      // → '$1,234,567'
/// OiKpiFormat.number(decimals: 1)        // → '45,231.0'
/// OiKpiFormat.percentage(decimals: 1)    // → '3.4%'
/// OiKpiFormat.custom((v) => '${v}x')    // → '2x'
/// ```
///
/// {@category Modules}
class OiKpiFormat {
  const OiKpiFormat._({required this.formatter});

  /// Creates a currency formatter with a leading [symbol] and optional [decimals].
  ///
  /// Large numbers are formatted with thousands separators using simple grouping.
  /// For example, `1234567` with the default settings produces `$1,234,567`.
  factory OiKpiFormat.currency({String symbol = r'$', int decimals = 0}) {
    return OiKpiFormat._(
      formatter: (value) {
        final formatted = _formatNumber(value.toDouble(), decimals);
        return '$symbol$formatted';
      },
    );
  }

  /// Creates a plain number formatter with optional [decimals].
  ///
  /// For example, `45231` with `decimals: 0` produces `45,231`.
  factory OiKpiFormat.number({int decimals = 0}) {
    return OiKpiFormat._(
      formatter: (value) => _formatNumber(value.toDouble(), decimals),
    );
  }

  /// Creates a percentage formatter.
  ///
  /// The raw [value] is treated as a fractional percentage when it is less than
  /// or equal to 1.0, and is multiplied by 100 automatically. Values greater
  /// than 1.0 are displayed as-is.
  ///
  /// For example, `0.0342` with `decimals: 1` produces `3.4%`.
  factory OiKpiFormat.percentage({int decimals = 1}) {
    return OiKpiFormat._(
      formatter: (value) {
        final pct = value.abs() <= 1.0
            ? value.toDouble() * 100
            : value.toDouble();
        return '${_formatNumber(pct, decimals)}%';
      },
    );
  }

  /// Creates a fully custom formatter backed by the given [formatter] callback.
  ///
  /// Use this when none of the built-in formats meet your needs.
  factory OiKpiFormat.custom(String Function(num value) formatter) {
    return OiKpiFormat._(formatter: formatter);
  }

  /// The underlying formatting function.
  final String Function(num value) formatter;

  /// Formats [value] into a display string.
  String format(num value) => formatter(value);

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Formats a [double] with [decimals] decimal places and thousands separators.
  static String _formatNumber(double value, int decimals) {
    final fixed = value.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');

    // Insert thousands separators into the integer part.
    final intPart = _insertThousandsSeparators(parts[0]);
    final prefix = value < 0 ? '-' : '';

    if (decimals == 0 || parts.length == 1) {
      return '$prefix$intPart';
    }
    return '$prefix$intPart.${parts[1]}';
  }

  static String _insertThousandsSeparators(String intPart) {
    if (intPart.length <= 3) return intPart;
    final buffer = StringBuffer();
    final startOffset = intPart.length % 3;
    if (startOffset > 0) {
      buffer.write(intPart.substring(0, startOffset));
    }
    for (var i = startOffset; i < intPart.length; i += 3) {
      if (i > 0) buffer.write(',');
      buffer.write(intPart.substring(i, i + 3));
    }
    return buffer.toString();
  }
}
