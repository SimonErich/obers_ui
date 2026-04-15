// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_emoji_picker.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders category labels', (tester) async {
    await tester.pumpObers(OiEmojiPicker(onSelected: (_) {}));
    expect(find.text('Smileys'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
  });

  testWidgets('renders emoji characters', (tester) async {
    await tester.pumpObers(OiEmojiPicker(onSelected: (_) {}));
    expect(find.text('😀'), findsOneWidget);
  });

  testWidgets('showSearch=true renders EditableText', (tester) async {
    await tester.pumpObers(OiEmojiPicker(onSelected: (_) {}));
    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets('showSearch=false hides search field', (tester) async {
    await tester.pumpObers(
      OiEmojiPicker(onSelected: (_) {}, showSearch: false),
    );
    expect(find.byType(EditableText), findsNothing);
  });

  // ── Selection ──────────────────────────────────────────────────────────────

  testWidgets('tapping emoji fires onSelected with that emoji', (tester) async {
    String? selected;
    await tester.pumpObers(OiEmojiPicker(onSelected: (e) => selected = e));
    await tester.tap(find.text('😀'));
    await tester.pump();
    expect(selected, '😀');
  });

  // ── Search ─────────────────────────────────────────────────────────────────

  testWidgets('search input matches category names', (tester) async {
    await tester.pumpObers(OiEmojiPicker(onSelected: (_) {}));
    await tester.enterText(find.byType(EditableText), 'smile');
    await tester.pump();
    expect(find.text('Smileys'), findsOneWidget);
    expect(find.text('No emoji found'), findsNothing);
  });

  testWidgets('search input matches category keywords', (tester) async {
    await tester.pumpObers(OiEmojiPicker(onSelected: (_) {}));
    await tester.enterText(find.byType(EditableText), 'fist');
    await tester.pump();
    expect(find.text('People'), findsOneWidget);
    expect(find.text('👊'), findsOneWidget);
    expect(find.text('👃'), findsNothing);
    expect(find.text('No emoji found'), findsNothing);
  });

  testWidgets('search input matches heart keyword', (tester) async {
    await tester.pumpObers(OiEmojiPicker(onSelected: (_) {}));
    await tester.enterText(find.byType(EditableText), 'heart');
    await tester.pump();
    expect(find.text('Symbols'), findsOneWidget);
    expect(find.text('❤️'), findsOneWidget);
    expect(find.text('💙'), findsOneWidget);
    expect(find.text('No emoji found'), findsNothing);
  });

  testWidgets('search input matches color keywords', (tester) async {
    await tester.pumpObers(OiEmojiPicker(onSelected: (_) {}));
    await tester.enterText(find.byType(EditableText), 'blue');
    await tester.pump();
    expect(find.text('Symbols'), findsOneWidget);
    expect(find.text('💙'), findsOneWidget);
    expect(find.text('🔵'), findsOneWidget);
    expect(find.text('No emoji found'), findsNothing);
  });

  testWidgets('search input filters emoji — no results shows message', (
    tester,
  ) async {
    await tester.pumpObers(OiEmojiPicker(onSelected: (_) {}));
    await tester.enterText(find.byType(EditableText), 'zzzznotanemoji');
    await tester.pump();
    expect(find.text('No emoji found'), findsOneWidget);
  });
}
