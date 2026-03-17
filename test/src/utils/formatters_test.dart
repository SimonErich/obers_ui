// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/utils/formatters.dart';

void main() {
  group('OiFormatters', () {
    group('number', () {
      test('formats integer with grouping separators', () {
        expect(OiFormatters.number(1234567), '1,234,567');
      });

      test('formats zero', () {
        expect(OiFormatters.number(0), '0');
      });

      test('formats negative number', () {
        expect(OiFormatters.number(-1234), '-1,234');
      });

      test('formats with decimal places', () {
        expect(OiFormatters.number(1234.5678, decimals: 2), '1,234.57');
      });

      test('formats small number without separators', () {
        expect(OiFormatters.number(999), '999');
      });

      test('formats with zero decimals by default', () {
        expect(OiFormatters.number(1234.99), '1,235');
      });
    });

    group('compact', () {
      test('formats thousands as K', () {
        expect(OiFormatters.compact(1200), contains('K'));
      });

      test('formats millions as M', () {
        expect(OiFormatters.compact(3400000), contains('M'));
      });

      test('formats small numbers without suffix', () {
        final result = OiFormatters.compact(42);
        expect(result, '42');
      });

      test('formats zero', () {
        expect(OiFormatters.compact(0), '0');
      });
    });

    group('currency', () {
      test('formats with dollar sign by default', () {
        final result = OiFormatters.currency(1234.56);
        expect(result, contains(r'$'));
        expect(result, contains('1,234.56'));
      });

      test('formats with custom symbol', () {
        final result = OiFormatters.currency(1234.56, symbol: '\u20AC');
        expect(result, contains('\u20AC'));
      });

      test('formats with custom decimal places', () {
        final result = OiFormatters.currency(1234, decimals: 0);
        expect(result, contains('1,234'));
      });

      test('formats zero', () {
        final result = OiFormatters.currency(0);
        expect(result, contains(r'$'));
        expect(result, contains('0.00'));
      });
    });

    group('percent', () {
      test('formats percentage with one decimal by default', () {
        expect(OiFormatters.percent(42.5), '42.5%');
      });

      test('formats with zero decimals', () {
        expect(OiFormatters.percent(42.5, decimals: 0), '43%');
      });

      test('formats with two decimals', () {
        expect(OiFormatters.percent(42.567, decimals: 2), '42.57%');
      });

      test('formats zero', () {
        expect(OiFormatters.percent(0), '0.0%');
      });

      test('formats 100%', () {
        expect(OiFormatters.percent(100), '100.0%');
      });
    });

    group('fileSize', () {
      test('formats bytes', () {
        expect(OiFormatters.fileSize(500), '500 B');
      });

      test('formats kilobytes', () {
        expect(OiFormatters.fileSize(1024), '1.0 KB');
      });

      test('formats megabytes', () {
        expect(OiFormatters.fileSize(1048576), '1.0 MB');
      });

      test('formats gigabytes', () {
        expect(OiFormatters.fileSize(1073741824), '1.0 GB');
      });

      test('formats with custom decimals', () {
        expect(OiFormatters.fileSize(1536, decimals: 2), '1.50 KB');
      });

      test('formats zero bytes', () {
        expect(OiFormatters.fileSize(0), '0 B');
      });

      test('handles negative bytes', () {
        expect(OiFormatters.fileSize(-1), '0 B');
      });

      test('formats large file sizes', () {
        // 1.5 TB
        expect(
          OiFormatters.fileSize(1649267441664),
          '1.5 TB',
        );
      });
    });

    group('duration', () {
      test('formats compact hours and minutes', () {
        expect(
          OiFormatters.duration(
            const Duration(hours: 2, minutes: 30),
            compact: true,
          ),
          '2h 30m',
        );
      });

      test('formats compact seconds', () {
        expect(
          OiFormatters.duration(
            const Duration(seconds: 45),
            compact: true,
          ),
          '45s',
        );
      });

      test('formats verbose hours', () {
        expect(
          OiFormatters.duration(const Duration(hours: 1)),
          '1 hour',
        );
      });

      test('formats verbose plural hours and minutes', () {
        expect(
          OiFormatters.duration(const Duration(hours: 2, minutes: 30)),
          '2 hours 30 minutes',
        );
      });

      test('formats verbose single minute', () {
        expect(
          OiFormatters.duration(const Duration(minutes: 1)),
          '1 minute',
        );
      });

      test('formats verbose single second', () {
        expect(
          OiFormatters.duration(const Duration(seconds: 1)),
          '1 second',
        );
      });

      test('formats zero duration compact', () {
        expect(
          OiFormatters.duration(Duration.zero, compact: true),
          '0s',
        );
      });

      test('formats zero duration verbose', () {
        expect(
          OiFormatters.duration(Duration.zero),
          '0 seconds',
        );
      });

      test('omits seconds when hours are present', () {
        final result = OiFormatters.duration(
          const Duration(hours: 1, seconds: 30),
          compact: true,
        );
        expect(result, '1h');
      });
    });

    group('relativeTime', () {
      test('returns just now for recent times', () {
        final now = DateTime(2025, 6, 15, 12);
        final recent = DateTime(2025, 6, 15, 11, 59, 30);
        expect(OiFormatters.relativeTime(recent, now: now), 'just now');
      });

      test('returns minutes ago', () {
        final now = DateTime(2025, 6, 15, 12);
        final past = DateTime(2025, 6, 15, 11, 55);
        expect(OiFormatters.relativeTime(past, now: now), '5 minutes ago');
      });

      test('returns singular minute', () {
        final now = DateTime(2025, 6, 15, 12);
        final past = DateTime(2025, 6, 15, 11, 59);
        expect(OiFormatters.relativeTime(past, now: now), '1 minute ago');
      });

      test('returns hours ago', () {
        final now = DateTime(2025, 6, 15, 12);
        final past = DateTime(2025, 6, 15, 9);
        expect(OiFormatters.relativeTime(past, now: now), '3 hours ago');
      });

      test('returns yesterday', () {
        final now = DateTime(2025, 6, 15, 12);
        final past = DateTime(2025, 6, 14, 12);
        expect(OiFormatters.relativeTime(past, now: now), 'yesterday');
      });

      test('returns days ago', () {
        final now = DateTime(2025, 6, 15, 12);
        final past = DateTime(2025, 6, 12, 12);
        expect(OiFormatters.relativeTime(past, now: now), '3 days ago');
      });

      test('returns weeks ago', () {
        final now = DateTime(2025, 6, 15, 12);
        final past = DateTime(2025, 5, 25, 12);
        expect(OiFormatters.relativeTime(past, now: now), '3 weeks ago');
      });

      test('returns months ago', () {
        final now = DateTime(2025, 6, 15, 12);
        final past = DateTime(2025, 3, 15, 12);
        expect(OiFormatters.relativeTime(past, now: now), '3 months ago');
      });

      test('returns years ago', () {
        final now = DateTime(2025, 6, 15, 12);
        final past = DateTime(2023, 6, 15, 12);
        expect(OiFormatters.relativeTime(past, now: now), '2 years ago');
      });

      test('returns tomorrow for future', () {
        final now = DateTime(2025, 6, 15, 12);
        final future = DateTime(2025, 6, 16, 12);
        expect(OiFormatters.relativeTime(future, now: now), 'tomorrow');
      });

      test('returns minutes from now for future', () {
        final now = DateTime(2025, 6, 15, 12);
        final future = DateTime(2025, 6, 15, 12, 5);
        expect(
          OiFormatters.relativeTime(future, now: now),
          '5 minutes from now',
        );
      });
    });

    group('dateTime', () {
      test('formats with default pattern', () {
        final date = DateTime(2025, 6, 15);
        expect(OiFormatters.dateTime(date), '2025-06-15');
      });

      test('formats with custom pattern', () {
        final date = DateTime(2025, 6, 15, 14, 30);
        expect(
          OiFormatters.dateTime(date, pattern: 'dd/MM/yyyy HH:mm'),
          '15/06/2025 14:30',
        );
      });

      test('formats month name', () {
        final date = DateTime(2025, 6, 15);
        expect(
          OiFormatters.dateTime(date, pattern: 'MMMM d, yyyy'),
          'June 15, 2025',
        );
      });
    });

    group('truncate', () {
      test('returns short string unchanged', () {
        expect(OiFormatters.truncate('hello', 10), 'hello');
      });

      test('truncates long string with ellipsis', () {
        expect(OiFormatters.truncate('hello world', 8), 'hello w\u2026');
      });

      test('uses custom ellipsis', () {
        expect(
          OiFormatters.truncate('hello world', 8, ellipsis: '...'),
          'hello...',
        );
      });

      test('handles maxLength equal to string length', () {
        expect(OiFormatters.truncate('hello', 5), 'hello');
      });

      test('handles very short maxLength', () {
        expect(OiFormatters.truncate('hello', 1), '\u2026');
      });

      test('handles empty string', () {
        expect(OiFormatters.truncate('', 10), '');
      });
    });

    group('ordinal', () {
      test('formats 1st', () {
        expect(OiFormatters.ordinal(1), '1st');
      });

      test('formats 2nd', () {
        expect(OiFormatters.ordinal(2), '2nd');
      });

      test('formats 3rd', () {
        expect(OiFormatters.ordinal(3), '3rd');
      });

      test('formats 4th', () {
        expect(OiFormatters.ordinal(4), '4th');
      });

      test('formats 11th (special case)', () {
        expect(OiFormatters.ordinal(11), '11th');
      });

      test('formats 12th (special case)', () {
        expect(OiFormatters.ordinal(12), '12th');
      });

      test('formats 13th (special case)', () {
        expect(OiFormatters.ordinal(13), '13th');
      });

      test('formats 21st', () {
        expect(OiFormatters.ordinal(21), '21st');
      });

      test('formats 22nd', () {
        expect(OiFormatters.ordinal(22), '22nd');
      });

      test('formats 23rd', () {
        expect(OiFormatters.ordinal(23), '23rd');
      });

      test('formats 100th', () {
        expect(OiFormatters.ordinal(100), '100th');
      });

      test('formats 111th', () {
        expect(OiFormatters.ordinal(111), '111th');
      });

      test('formats 112th', () {
        expect(OiFormatters.ordinal(112), '112th');
      });

      test('formats 113th', () {
        expect(OiFormatters.ordinal(113), '113th');
      });

      test('formats 0th', () {
        expect(OiFormatters.ordinal(0), '0th');
      });
    });
  });
}
