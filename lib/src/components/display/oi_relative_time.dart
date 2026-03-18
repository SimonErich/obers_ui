import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// The display style for [OiRelativeTime] text output.
///
/// {@category Components}
enum OiRelativeTimeStyle {
  /// Compact form: "2m", "3h", "1d".
  narrow,

  /// Short form with "ago": "2m ago", "3h ago", "yesterday".
  short,

  /// Full form: "2 minutes ago", "3 hours ago", "yesterday at 14:32".
  long,
}

/// A text widget that displays a [DateTime] as a human-readable relative
/// string ("just now", "2m ago", "3h ago", "Yesterday at 14:32",
/// "Mar 3, 2026").
///
/// When [live] is `true` (the default), the widget auto-refreshes on an
/// internal timer so "just now" transitions to "1m ago" without external
/// rebuilds. The refresh interval adapts automatically:
/// - Every 10 seconds for the first minute.
/// - Every 30 seconds up to 1 hour.
/// - Every 5 minutes up to 24 hours.
/// - Stops after 24 hours (the displayed date won't change).
///
/// This is a pure display primitive — no interactivity.
///
/// **Composes:** [OiLabel] (text output).
///
/// ```dart
/// OiRelativeTime(dateTime: message.sentAt)
/// OiRelativeTime(dateTime: event.time, style: OiRelativeTimeStyle.long)
/// OiRelativeTime(dateTime: event.time, live: false)
/// ```
///
/// {@category Components}
class OiRelativeTime extends StatefulWidget {
  /// Creates a relative time display for the given [dateTime].
  const OiRelativeTime({
    required this.dateTime,
    this.style = OiRelativeTimeStyle.short,
    this.capitalize = false,
    this.live = true,
    this.formatAbsolute,
    this.semanticsLabel,
    super.key,
  });

  /// The point in time to display relative to now.
  final DateTime dateTime;

  /// The display style for the relative string.
  final OiRelativeTimeStyle style;

  /// Whether to capitalize the first letter of the output.
  final bool capitalize;

  /// Whether to auto-refresh the display on a timer.
  ///
  /// When `false`, computes once and never updates.
  final bool live;

  /// Optional override for absolute date formatting (dates older than 7 days).
  ///
  /// When provided, this callback is used instead of the default formatting
  /// for dates that fall outside the relative range.
  final String Function(DateTime)? formatAbsolute;

  /// An optional override for the accessibility label announced by screen
  /// readers.
  ///
  /// When `null`, the full [OiRelativeTimeStyle.long]-style string is used
  /// for semantics regardless of visual style. This ensures screen readers
  /// always say "5 minutes ago" even when the visual shows "5m".
  final String? semanticsLabel;

  // ---------------------------------------------------------------------------
  // Formatting logic (static for testability)
  // ---------------------------------------------------------------------------

  /// Formats [dateTime] as a relative string using [style].
  ///
  /// [now] can be injected for testing; defaults to [DateTime.now].
  static String format(
    DateTime dateTime, {
    OiRelativeTimeStyle style = OiRelativeTimeStyle.short,
    bool capitalize = false,
    String Function(DateTime)? formatAbsolute,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final elapsed = ref.difference(dateTime);
    final seconds = elapsed.inSeconds;
    final minutes = elapsed.inMinutes;
    final hours = elapsed.inHours;
    final days = elapsed.inDays;

    String result;

    if (seconds < 10) {
      result = _lessThan10s(style);
    } else if (seconds < 60) {
      result = _lessThan60s(seconds, style);
    } else if (minutes < 60) {
      result = _lessThan60m(minutes, style);
    } else if (hours < 24) {
      result = _lessThan24h(hours, style);
    } else if (hours < 48) {
      result = _lessThan48h(dateTime, style);
    } else if (days < 7) {
      result = _lessThan7d(days, style);
    } else if (formatAbsolute != null) {
      result = formatAbsolute(dateTime);
    } else if (dateTime.year == ref.year) {
      result = _sameYear(dateTime, style);
    } else {
      result = _otherYear(dateTime, style);
    }

    if (capitalize && result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1);
    }

    return result;
  }

  /// Computes the adaptive refresh interval based on elapsed time.
  ///
  /// - < 1 minute: every 10 seconds
  /// - < 1 hour: every 30 seconds
  /// - < 24 hours: every 5 minutes
  /// - >= 24 hours: `null` (stop refreshing)
  static Duration? adaptiveInterval(DateTime dateTime, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final elapsed = ref.difference(dateTime);

    if (elapsed.inMinutes < 1) return const Duration(seconds: 10);
    if (elapsed.inHours < 1) return const Duration(seconds: 30);
    if (elapsed.inHours < 24) return const Duration(minutes: 5);
    return null; // Stop — date won't change.
  }

  // ---------------------------------------------------------------------------
  // Private formatting helpers
  // ---------------------------------------------------------------------------

  static String _lessThan10s(OiRelativeTimeStyle style) {
    switch (style) {
      case OiRelativeTimeStyle.narrow:
        return 'now';
      case OiRelativeTimeStyle.short:
      case OiRelativeTimeStyle.long:
        return 'just now';
    }
  }

  static String _lessThan60s(int seconds, OiRelativeTimeStyle style) {
    switch (style) {
      case OiRelativeTimeStyle.narrow:
        return '${seconds}s';
      case OiRelativeTimeStyle.short:
        return '${seconds}s ago';
      case OiRelativeTimeStyle.long:
        return '$seconds ${seconds == 1 ? 'second' : 'seconds'} ago';
    }
  }

  static String _lessThan60m(int minutes, OiRelativeTimeStyle style) {
    switch (style) {
      case OiRelativeTimeStyle.narrow:
        return '${minutes}m';
      case OiRelativeTimeStyle.short:
        return '${minutes}m ago';
      case OiRelativeTimeStyle.long:
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
  }

  static String _lessThan24h(int hours, OiRelativeTimeStyle style) {
    switch (style) {
      case OiRelativeTimeStyle.narrow:
        return '${hours}h';
      case OiRelativeTimeStyle.short:
        return '${hours}h ago';
      case OiRelativeTimeStyle.long:
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
  }

  static String _lessThan48h(DateTime dateTime, OiRelativeTimeStyle style) {
    switch (style) {
      case OiRelativeTimeStyle.narrow:
        return '1d';
      case OiRelativeTimeStyle.short:
        return 'yesterday';
      case OiRelativeTimeStyle.long:
        final h = dateTime.hour.toString().padLeft(2, '0');
        final m = dateTime.minute.toString().padLeft(2, '0');
        return 'yesterday at $h:$m';
    }
  }

  static String _lessThan7d(int days, OiRelativeTimeStyle style) {
    switch (style) {
      case OiRelativeTimeStyle.narrow:
        return '${days}d';
      case OiRelativeTimeStyle.short:
        return '${days}d ago';
      case OiRelativeTimeStyle.long:
        return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
  }

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _sameYear(DateTime dt, OiRelativeTimeStyle style) {
    final mon = _monthsShort[dt.month - 1];
    switch (style) {
      case OiRelativeTimeStyle.narrow:
      case OiRelativeTimeStyle.short:
        return '$mon ${dt.day}';
      case OiRelativeTimeStyle.long:
        final full = _months[dt.month - 1];
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$full ${dt.day} at $h:$m';
    }
  }

  static String _otherYear(DateTime dt, OiRelativeTimeStyle style) {
    final mon = _monthsShort[dt.month - 1];
    switch (style) {
      case OiRelativeTimeStyle.narrow:
        final yr = (dt.year % 100).toString().padLeft(2, '0');
        return "$mon ${dt.day} '$yr";
      case OiRelativeTimeStyle.short:
        return '$mon ${dt.day}, ${dt.year}';
      case OiRelativeTimeStyle.long:
        final full = _months[dt.month - 1];
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$full ${dt.day}, ${dt.year} at $h:$m';
    }
  }

  @override
  State<OiRelativeTime> createState() => _OiRelativeTimeState();
}

class _OiRelativeTimeState extends State<OiRelativeTime> {
  Timer? _timer;
  late String _text;

  @override
  void initState() {
    super.initState();
    _text = _computeText();
    if (widget.live) _scheduleTimer();
  }

  @override
  void didUpdateWidget(OiRelativeTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateTime != widget.dateTime ||
        oldWidget.style != widget.style ||
        oldWidget.capitalize != widget.capitalize ||
        oldWidget.live != widget.live) {
      _text = _computeText();
      _timer?.cancel();
      _timer = null;
      if (widget.live) _scheduleTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  String _computeText() => OiRelativeTime.format(
    widget.dateTime,
    style: widget.style,
    capitalize: widget.capitalize,
    formatAbsolute: widget.formatAbsolute,
  );

  void _scheduleTimer() {
    final interval = OiRelativeTime.adaptiveInterval(widget.dateTime);
    if (interval == null) return; // No more updates needed.
    _timer = Timer(interval, _onTick);
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {
      _text = _computeText();
    });
    _scheduleTimer();
  }

  String _semanticsText() {
    if (widget.semanticsLabel != null) return widget.semanticsLabel!;
    // Always use long form for semantics regardless of visual style.
    return OiRelativeTime.format(
      widget.dateTime,
      style: OiRelativeTimeStyle.long,
      formatAbsolute: widget.formatAbsolute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _semanticsText(),
      child: ExcludeSemantics(child: OiLabel.small(_text)),
    );
  }
}
