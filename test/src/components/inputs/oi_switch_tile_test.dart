// Tests do not require documentation comments.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── OiSwitchTile ──────────────────────────────────────────────────────────

  group('OiSwitchTile', () {
    testWidgets('renders title and switch', (tester) async {
      await tester.pumpObers(
        OiSwitchTile(
          title: 'Dark Mode',
          value: false,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byType(OiSwitch), findsOneWidget);
    });

    testWidgets('tapping tile toggles value', (tester) async {
      bool? result;
      await tester.pumpObers(
        OiSwitchTile(
          title: 'Notifications',
          value: false,
          onChanged: (v) => result = v,
        ),
      );

      await tester.tap(find.text('Notifications'));
      await tester.pump();

      expect(result, isTrue);
    });

    testWidgets('disabled state prevents toggle', (tester) async {
      bool? result;
      await tester.pumpObers(
        OiSwitchTile(
          title: 'Locked',
          value: false,
          onChanged: (v) => result = v,
          enabled: false,
        ),
      );

      await tester.tap(find.text('Locked'), warnIfMissed: false);
      await tester.pump();

      expect(result, isNull);
    });
  });

  // ── OiCheckboxTile ────────────────────────────────────────────────────────

  group('OiCheckboxTile', () {
    testWidgets('renders title and checkbox', (tester) async {
      await tester.pumpObers(
        OiCheckboxTile(
          title: 'Accept Terms',
          value: false,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Accept Terms'), findsOneWidget);
      expect(find.byType(OiCheckbox), findsOneWidget);
    });

    testWidgets('tapping tile toggles checkbox', (tester) async {
      bool? result;
      await tester.pumpObers(
        OiCheckboxTile(
          title: 'Agree',
          value: false,
          onChanged: (v) => result = v,
        ),
      );

      await tester.tap(find.text('Agree'));
      await tester.pump();

      expect(result, isTrue);
    });

    testWidgets('disabled state prevents toggle', (tester) async {
      bool? result;
      await tester.pumpObers(
        OiCheckboxTile(
          title: 'Locked',
          value: false,
          onChanged: (v) => result = v,
          enabled: false,
        ),
      );

      await tester.tap(find.text('Locked'), warnIfMissed: false);
      await tester.pump();

      expect(result, isNull);
    });
  });

  // ── OiRadioTile ───────────────────────────────────────────────────────────

  group('OiRadioTile', () {
    testWidgets('compact cards keep the full title without indicator space', (
      tester,
    ) async {
      String? selected;
      await tester.pumpObers(
        Center(
          child: SizedBox(
            width: 121,
            child: OiRadioTile<String>.card(
              title: '12:00–12:30',
              titleWidget: const Text(
                '12:00–12:30',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14),
              ),
              value: 'noon',
              groupValue: 'noon',
              indicator: OiRadioTileIndicator.none,
              contentPadding: const EdgeInsets.all(12),
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      );
      final title = tester.renderObject<RenderParagraph>(
        find.text('12:00–12:30'),
      );
      expect(title.size.width, greaterThanOrEqualTo(95));
      expect(title.size.width, lessThanOrEqualTo(97));
      await tester.tap(find.text('12:00–12:30'));
      await tester.pump();
      expect(selected, 'noon');
      expect(tester.takeException(), isNull);
    });

    testWidgets('card body spans the content below the leading control', (
      tester,
    ) async {
      String? selected;
      await tester.pumpObers(
        SizedBox(
          width: 320,
          child: OiRadioTile<String>.card(
            title: 'Company profile',
            value: 'company',
            groupValue: null,
            controlLeading: true,
            bodyWidget: const Text(
              'Address and delivery instructions',
              key: Key('body'),
            ),
            onChanged: (value) => selected = value,
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('body'))).dx,
        lessThan(tester.getTopLeft(find.text('Company profile')).dx),
      );
      await tester.tap(find.byKey(const Key('body')));
      await tester.pump();
      expect(selected, 'company');
    });

    testWidgets('renders title and radio', (tester) async {
      await tester.pumpObers(
        OiRadioTile<String>(
          title: 'Option A',
          value: 'a',
          groupValue: null,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.byType(OiRadioIndicator), findsOneWidget);
    });

    testWidgets('tapping tile selects value', (tester) async {
      String? result;
      await tester.pumpObers(
        OiRadioTile<String>(
          title: 'Option B',
          value: 'b',
          groupValue: 'a',
          onChanged: (v) => result = v,
        ),
      );

      await tester.tap(find.text('Option B'));
      await tester.pump();

      expect(result, 'b');
    });

    testWidgets('disabled state prevents selection', (tester) async {
      String? result;
      await tester.pumpObers(
        OiRadioTile<String>(
          title: 'Disabled Option',
          value: 'c',
          groupValue: 'a',
          onChanged: (v) => result = v,
          enabled: false,
        ),
      );

      await tester.tap(find.text('Disabled Option'), warnIfMissed: false);
      await tester.pump();

      expect(result, isNull);
    });
  });
}
