import 'package:intl/intl.dart';

/// Utility class for formatting values for display.
///
/// Provides static methods for formatting numbers, dates, durations,
/// file sizes, and strings in human-readable ways.
///
/// {@category Utils}
class OiFormatters {
  const OiFormatters._();

  /// Formats a number with grouping separators (e.g., 1,234,567).
  ///
  /// [value] is the number to format.
  /// [decimals] controls how many decimal places to show (default 0).
  /// [locale] determines the grouping and decimal separator style.
  static String number(num value, {int decimals = 0, String locale = 'en'}) {
    final formatter = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimals,
    );
    return formatter.format(value);
  }

  /// Formats a number as compact (e.g., 1.2K, 3.4M).
  ///
  /// [value] is the number to format.
  /// [locale] determines the compact abbreviation style.
  static String compact(num value, {String locale = 'en'}) {
    final formatter = NumberFormat.compact(locale: locale);
    return formatter.format(value);
  }

  /// Formats a number as currency (e.g., $1,234.56).
  ///
  /// [value] is the number to format.
  /// [symbol] is the currency symbol (default '\$').
  /// [decimals] controls decimal places (default 2).
  /// [locale] determines the grouping and decimal separator style.
  static String currency(
    num value, {
    String symbol = r'$',
    int decimals = 2,
    String locale = 'en',
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimals,
    );
    return formatter.format(value);
  }

  /// Formats a number as percentage (e.g., 42.5%).
  ///
  /// [value] is the percentage value (e.g., 42.5 produces "42.5%").
  /// [decimals] controls how many decimal places to show (default 1).
  static String percent(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Formats bytes as human-readable file size (e.g., 1.2 MB).
  ///
  /// Uses binary prefixes (1 KB = 1024 bytes).
  /// [bytes] is the raw byte count.
  /// [decimals] controls how many decimal places to show (default 1).
  static String fileSize(int bytes, {int decimals = 1}) {
    if (bytes < 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    var value = bytes.toDouble();
    var unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) return '$bytes B';
    return '${value.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }

  /// Formats a [Duration] as human-readable (e.g., "2h 30m", "45s").
  ///
  /// When [compact] is true, uses abbreviated units (h, m, s).
  /// When [compact] is false, uses full words (hours, minutes, seconds).
  static String duration(Duration duration, {bool compact = false}) {
    final totalSeconds = duration.inSeconds.abs();

    if (totalSeconds == 0) return compact ? '0s' : '0 seconds';

    final hours = duration.inHours.abs();
    final minutes = duration.inMinutes.abs() % 60;
    final seconds = totalSeconds % 60;

    final parts = <String>[];

    if (hours > 0) {
      parts.add(
        compact ? '${hours}h' : '$hours ${hours == 1 ? 'hour' : 'hours'}',
      );
    }
    if (minutes > 0) {
      parts.add(
        compact
            ? '${minutes}m'
            : '$minutes ${minutes == 1 ? 'minute' : 'minutes'}',
      );
    }
    if (seconds > 0 && hours == 0) {
      parts.add(
        compact
            ? '${seconds}s'
            : '$seconds ${seconds == 1 ? 'second' : 'seconds'}',
      );
    }

    return parts.join(' ');
  }

  /// Formats a [DateTime] as relative time (e.g., "2 minutes ago",
  /// "yesterday").
  ///
  /// [dateTime] is the date/time to describe relative to [now].
  /// [now] defaults to [DateTime.now] if not provided.
  static String relativeTime(DateTime dateTime, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(dateTime);
    final absDiff = diff.abs();

    final isFuture = diff.isNegative;
    final suffix = isFuture ? 'from now' : 'ago';

    if (absDiff.inSeconds < 60) return 'just now';
    if (absDiff.inMinutes < 60) {
      final m = absDiff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} $suffix';
    }
    if (absDiff.inHours < 24) {
      final h = absDiff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} $suffix';
    }
    if (absDiff.inDays == 1) return isFuture ? 'tomorrow' : 'yesterday';
    if (absDiff.inDays < 7) {
      final d = absDiff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} $suffix';
    }
    if (absDiff.inDays < 30) {
      final w = absDiff.inDays ~/ 7;
      return '$w ${w == 1 ? 'week' : 'weeks'} $suffix';
    }
    if (absDiff.inDays < 365) {
      final m = absDiff.inDays ~/ 30;
      return '$m ${m == 1 ? 'month' : 'months'} $suffix';
    }

    final y = absDiff.inDays ~/ 365;
    return '$y ${y == 1 ? 'year' : 'years'} $suffix';
  }

  /// Formats a [DateTime] with a pattern.
  ///
  /// Uses the `intl` package's [DateFormat] patterns.
  /// [pattern] defaults to `'yyyy-MM-dd'`.
  static String dateTime(DateTime dateTime, {String pattern = 'yyyy-MM-dd'}) {
    final formatter = DateFormat(pattern);
    return formatter.format(dateTime);
  }

  /// Truncates a string to [maxLength] with an ellipsis.
  ///
  /// If [text] is shorter than or equal to [maxLength], returns it unchanged.
  /// Otherwise, truncates and appends [ellipsis] (default '...').
  /// The total length including the ellipsis will not exceed [maxLength].
  static String truncate(String text, int maxLength, {String ellipsis = '\u2026'}) {
    if (text.length <= maxLength) return text;
    if (maxLength <= ellipsis.length) return ellipsis.substring(0, maxLength);
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Formats a number with ordinal suffix (1st, 2nd, 3rd, 4th...).
  ///
  /// Handles special cases for 11th, 12th, 13th, etc.
  static String ordinal(int number) {
    final abs = number.abs();
    final lastTwo = abs % 100;
    final lastOne = abs % 10;

    String suffix;
    if (lastTwo >= 11 && lastTwo <= 13) {
      suffix = 'th';
    } else {
      switch (lastOne) {
        case 1:
          suffix = 'st';
        case 2:
          suffix = 'nd';
        case 3:
          suffix = 'rd';
        default:
          suffix = 'th';
      }
    }
    return '$number$suffix';
  }
}
