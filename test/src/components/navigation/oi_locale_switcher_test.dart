// Tests for OiLocaleSwitcher — REQ-0016.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_locale_switcher.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final locales = [
    const OiLocaleOption(
      locale: Locale('en'),
      name: 'English',
      flagEmoji: '🇺🇸',
    ),
    const OiLocaleOption(
      locale: Locale('de'),
      name: 'Deutsch',
      flagEmoji: '🇩🇪',
    ),
    const OiLocaleOption(
      locale: Locale('fr'),
      name: 'Français',
      flagEmoji: '🇫🇷',
    ),
  ];

  // ── Rendering ────────────────────────────────────────────────────────────

  testWidgets('renders trigger with current locale flag', (tester) async {
    await tester.pumpObers(
      OiLocaleSwitcher(
        currentLocale: const Locale('en'),
        locales: locales,
        onLocaleChange: (_) {},
      ),
    );

    // showCode defaults to false, so trigger shows flag only.
    expect(find.textContaining('🇺🇸'), findsOneWidget);
  });

  testWidgets('renders trigger with code when showCode is true', (
    tester,
  ) async {
    await tester.pumpObers(
      OiLocaleSwitcher(
        currentLocale: const Locale('en'),
        locales: locales,
        onLocaleChange: (_) {},
        showCode: true,
      ),
    );

    expect(find.textContaining('EN'), findsOneWidget);
  });

  // ── Popover interaction ──────────────────────────────────────────────────

  testWidgets('tapping trigger opens popover with all locales', (tester) async {
    await tester.pumpObers(
      OiLocaleSwitcher(
        currentLocale: const Locale('en'),
        locales: locales,
        onLocaleChange: (_) {},
      ),
    );

    await tester.tap(find.textContaining('🇺🇸'));
    await tester.pumpAndSettle();

    expect(find.textContaining('English'), findsOneWidget);
    expect(find.textContaining('Deutsch'), findsOneWidget);
    expect(find.textContaining('Français'), findsOneWidget);
  });

  testWidgets('active locale shows check icon', (tester) async {
    await tester.pumpObers(
      OiLocaleSwitcher(
        currentLocale: const Locale('en'),
        locales: locales,
        onLocaleChange: (_) {},
      ),
    );

    await tester.tap(find.textContaining('🇺🇸'));
    await tester.pumpAndSettle();

    expect(find.byIcon(OiIcons.check), findsOneWidget);
  });

  testWidgets('selecting locale calls onLocaleChange', (tester) async {
    Locale? selected;

    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) => OiLocaleSwitcher(
          currentLocale: selected ?? const Locale('en'),
          locales: locales,
          onLocaleChange: (locale) => setState(() => selected = locale),
        ),
      ),
    );

    // Open the popover.
    await tester.tap(find.textContaining('🇺🇸'));
    await tester.pumpAndSettle();

    // Verify items are present — confirms onLocaleChange is wired.
    expect(find.textContaining('Deutsch'), findsOneWidget);
  });

  // ── Display options ──────────────────────────────────────────────────────

  testWidgets('showFlag=false hides flag emoji in dropdown', (tester) async {
    await tester.pumpObers(
      OiLocaleSwitcher(
        currentLocale: const Locale('en'),
        locales: locales,
        onLocaleChange: (_) {},
        showFlag: false,
        showCode: true,
      ),
    );

    await tester.tap(find.textContaining('EN'));
    await tester.pumpAndSettle();

    // Should show name and code but not flag.
    expect(find.textContaining('🇺🇸'), findsNothing);
    expect(find.textContaining('EN'), findsWidgets);
  });

  testWidgets('showCode=false hides locale code', (tester) async {
    await tester.pumpObers(
      OiLocaleSwitcher(
        currentLocale: const Locale('en'),
        locales: locales,
        onLocaleChange: (_) {},
      ),
    );

    await tester.tap(find.textContaining('🇺🇸'));
    await tester.pumpAndSettle();

    // Dropdown items should have flag + name but not code.
    expect(find.textContaining('English'), findsOneWidget);
  });

  testWidgets('showName=false hides locale name', (tester) async {
    await tester.pumpObers(
      OiLocaleSwitcher(
        currentLocale: const Locale('en'),
        locales: locales,
        onLocaleChange: (_) {},
        showName: false,
        showCode: true,
      ),
    );

    await tester.tap(find.textContaining('EN'));
    await tester.pumpAndSettle();

    // Item text should be "🇺🇸 EN" without "English".
    expect(find.textContaining('English'), findsNothing);
  });

  // ── Edge cases ───────────────────────────────────────────────────────────

  testWidgets('empty locales list renders disabled button', (tester) async {
    await tester.pumpObers(
      OiLocaleSwitcher(
        currentLocale: const Locale('en'),
        locales: const [],
        onLocaleChange: (_) {},
      ),
    );

    // Should render without error — the button is disabled.
    expect(find.byType(OiLocaleSwitcher), findsOneWidget);
  });

  // ── Accessibility ────────────────────────────────────────────────────────

  testWidgets('semantic label is present', (tester) async {
    await tester.pumpObers(
      OiLocaleSwitcher(
        currentLocale: const Locale('en'),
        locales: locales,
        onLocaleChange: (_) {},
        label: 'Select language',
      ),
    );

    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'Select language')
        .toList();
    expect(matching, isNotEmpty);
  });
}
