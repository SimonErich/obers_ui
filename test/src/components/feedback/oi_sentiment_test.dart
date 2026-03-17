// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/feedback/oi_sentiment.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders default 5 emojis', (tester) async {
    await tester.pumpObers(const OiSentiment());
    for (final e in ['😡', '😕', '😐', '🙂', '😄']) {
      expect(find.text(e), findsOneWidget);
    }
  });

  testWidgets('renders custom emojis', (tester) async {
    await tester.pumpObers(const OiSentiment(emojis: ['🐶', '🐱']));
    expect(find.text('🐶'), findsOneWidget);
    expect(find.text('🐱'), findsOneWidget);
  });

  testWidgets('tapping an emoji fires onChanged with that emoji', (
    tester,
  ) async {
    String? received;
    await tester.pumpObers(OiSentiment(onChanged: (v) => received = v));
    await tester.tap(find.text('😄'));
    await tester.pump();
    expect(received, '😄');
  });

  testWidgets('enabled=false blocks onChanged', (tester) async {
    String? received;
    await tester.pumpObers(
      OiSentiment(enabled: false, onChanged: (v) => received = v),
    );
    await tester.tap(find.text('😡'), warnIfMissed: false);
    await tester.pump();
    expect(received, isNull);
  });

  testWidgets('selected emoji is highlighted (widget builds without error)', (
    tester,
  ) async {
    await tester.pumpObers(const OiSentiment(value: '🙂'));
    expect(find.text('🙂'), findsOneWidget);
  });
}
