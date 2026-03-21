import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/display/oi_reply_preview.dart';
import 'package:obers_ui/src/utils/color_utils.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiReplyPreview', () {
    const sender = 'Alice';
    const content = 'Hey, did you see the latest update?';

    testWidgets('renders sender name and content', (tester) async {
      await tester.pumpObers(
        const OiReplyPreview(senderName: sender, content: content),
      );

      expect(find.text(sender), findsOneWidget);
      expect(find.text(content), findsOneWidget);
    });

    testWidgets('accent bar is 3px wide', (tester) async {
      await tester.pumpObers(
        const OiReplyPreview(senderName: sender, content: content),
      );

      final containers = find.byType(Container);
      var found3pxBar = false;
      for (var i = 0; i < tester.widgetList(containers).length; i++) {
        final element = tester.elementList(containers).elementAt(i);
        final renderBox = element.renderObject as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          if (renderBox.size.width == 3.0) {
            found3pxBar = true;
            break;
          }
        }
      }
      expect(found3pxBar, isTrue, reason: 'Accent bar should be 3px wide');
    });

    testWidgets('uses provided accentColor', (tester) async {
      const customColor = Color(0xFFFF0000);
      await tester.pumpObers(
        const OiReplyPreview(
          senderName: sender,
          content: content,
          accentColor: customColor,
        ),
      );

      final containers = find.byType(Container);
      var foundColoredBar = false;
      for (final element in tester.elementList(containers)) {
        final widget = element.widget as Container;
        if (widget.decoration is BoxDecoration) {
          final deco = widget.decoration! as BoxDecoration;
          if (deco.color == customColor) {
            foundColoredBar = true;
            break;
          }
        }
      }
      expect(
        foundColoredBar,
        isTrue,
        reason: 'Accent bar should use the provided accentColor',
      );
    });

    testWidgets('auto-derives accent color from sender name hash', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiReplyPreview(senderName: sender, content: content),
      );

      final expectedColor = OiColorUtils.fromString(sender);
      final containers = find.byType(Container);
      var foundDerivedColor = false;
      for (final element in tester.elementList(containers)) {
        final widget = element.widget as Container;
        if (widget.decoration is BoxDecoration) {
          final deco = widget.decoration! as BoxDecoration;
          if (deco.color == expectedColor) {
            foundDerivedColor = true;
            break;
          }
        }
      }
      expect(
        foundDerivedColor,
        isTrue,
        reason: 'Accent bar should derive color from sender name hash',
      );
    });

    testWidgets('content uses ellipsis overflow', (tester) async {
      final longContent = 'A' * 500;
      await tester.pumpObers(
        OiReplyPreview(senderName: sender, content: longContent),
        surfaceSize: const Size(300, 100),
      );

      final textWidgets = tester.widgetList<Text>(find.text(longContent));
      expect(textWidgets, isNotEmpty);
      final text = textWidgets.first;
      expect(text.maxLines, equals(1));
      expect(text.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('sender name uses single-line ellipsis', (tester) async {
      await tester.pumpObers(
        const OiReplyPreview(senderName: sender, content: content),
      );

      final senderText = tester.widgetList<Text>(find.text(sender)).first;
      expect(senderText.maxLines, equals(1));
      expect(senderText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('does not show close button when dismissible is false', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiReplyPreview(senderName: sender, content: content),
      );

      expect(find.byType(OiIconButton), findsNothing);
    });

    testWidgets('shows close button when dismissible is true', (tester) async {
      await tester.pumpObers(
        const OiReplyPreview(
          senderName: sender,
          content: content,
          dismissible: true,
        ),
      );

      expect(find.byType(OiIconButton), findsOneWidget);
      final button = tester.widget<OiIconButton>(find.byType(OiIconButton));
      expect(button.semanticLabel, equals('Cancel reply'));
    });

    testWidgets('close button invokes onDismiss', (tester) async {
      var dismissed = false;
      await tester.pumpObers(
        OiReplyPreview(
          senderName: sender,
          content: content,
          dismissible: true,
          onDismiss: () => dismissed = true,
        ),
      );

      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('default semantic label includes sender name', (tester) async {
      await tester.pumpObers(
        const OiReplyPreview(senderName: sender, content: content),
      );

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Replying to $sender',
        ),
      );
      expect(semantics, isNotNull);
    });

    testWidgets('custom label overrides default semantic label', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiReplyPreview(
          senderName: sender,
          content: content,
          label: 'Custom label',
        ),
      );

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Custom label',
        ),
      );
      expect(semantics, isNotNull);
    });
  });
}
