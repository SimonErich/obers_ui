// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/editors/oi_smart_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiSmartInput', () {
    testWidgets('renders text input and label', (tester) async {
      await tester.pumpObers(const Center(child: OiSmartInput(label: 'Name')));

      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('onChange fires when text changes', (tester) async {
      String? changed;
      await tester.pumpObers(
        Center(
          child: OiSmartInput(label: 'Name', onChange: (v) => changed = v),
        ),
      );

      // Find the EditableText and enter text.
      await tester.enterText(find.byType(EditableText).first, 'hello');
      await tester.pump();

      expect(changed, 'hello');
    });

    testWidgets('recognizers apply styles to matched text', (tester) async {
      const mentionStyle = TextStyle(color: Color(0xFF2563EB));
      final recognizers = [
        OiPatternRecognizer(
          trigger: '@',
          pattern: RegExp(r'@\w+'),
          style: mentionStyle,
        ),
      ];

      final controller = TextEditingController(text: 'hello @alice');
      await tester.pumpObers(
        Center(
          child: OiSmartInput(
            label: 'Message',
            recognizers: recognizers,
            controller: controller,
          ),
        ),
      );
      await tester.pump();

      // The matched span should appear as a styled Text widget.
      expect(find.text('@alice'), findsOneWidget);
    });

    testWidgets('multiple recognizers coexist', (tester) async {
      final recognizers = [
        OiPatternRecognizer(
          trigger: '@',
          pattern: RegExp(r'@\w+'),
          style: const TextStyle(color: Color(0xFF2563EB)),
        ),
        OiPatternRecognizer(
          trigger: '#',
          pattern: RegExp(r'#\w+'),
          style: const TextStyle(color: Color(0xFF16A34A)),
        ),
      ];

      final controller = TextEditingController(text: '@alice #flutter');
      await tester.pumpObers(
        Center(
          child: OiSmartInput(
            label: 'Message',
            recognizers: recognizers,
            controller: controller,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('@alice'), findsOneWidget);
      expect(find.text('#flutter'), findsOneWidget);
    });

    testWidgets('onSpanTap fires when recognized span is tapped', (
      tester,
    ) async {
      OiRecognizedSpan? tappedSpan;
      final recognizers = [
        OiPatternRecognizer(
          trigger: '@',
          pattern: RegExp(r'@\w+'),
          style: const TextStyle(color: Color(0xFF2563EB)),
        ),
      ];

      final controller = TextEditingController(text: 'hello @bob');
      await tester.pumpObers(
        Center(
          child: OiSmartInput(
            label: 'Msg',
            recognizers: recognizers,
            controller: controller,
            onSpanTap: (span) => tappedSpan = span,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('@bob'));
      await tester.pump();

      expect(tappedSpan, isNotNull);
      expect(tappedSpan!.trigger, '@');
      expect(tappedSpan!.value, '@bob');
    });

    testWidgets('placeholder shows when empty', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiSmartInput(
            label: 'Search',
            placeholder: 'Type to search...',
          ),
        ),
      );

      expect(find.text('Type to search...'), findsOneWidget);
    });

    testWidgets('placeholder hides when text is entered', (tester) async {
      final controller = TextEditingController();
      await tester.pumpObers(
        Center(
          child: OiSmartInput(
            label: 'Search',
            placeholder: 'Type to search...',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Type to search...'), findsOneWidget);

      await tester.enterText(find.byType(EditableText).first, 'hello');
      await tester.pump();

      expect(find.text('Type to search...'), findsNothing);
    });

    testWidgets('disabled blocks input', (tester) async {
      String? changed;
      await tester.pumpObers(
        Center(
          child: OiSmartInput(
            label: 'Name',
            enabled: false,
            onChange: (v) => changed = v,
          ),
        ),
      );

      // The EditableText should be readOnly when disabled.
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(editableText.readOnly, isTrue);
      expect(changed, isNull);
    });

    testWidgets('error message shows', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiSmartInput(label: 'Email', error: 'Invalid email'),
        ),
      );

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('hint text shows', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiSmartInput(label: 'Name', hint: 'Enter your full name'),
        ),
      );

      expect(find.text('Enter your full name'), findsOneWidget);
    });

    testWidgets('focus node can be provided externally', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpObers(
        Center(
          child: OiSmartInput(label: 'Name', focusNode: focusNode),
        ),
      );

      expect(focusNode.hasFocus, isFalse);

      focusNode.requestFocus();
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('empty recognizers list renders plain input', (tester) async {
      final controller = TextEditingController(text: 'hello @world');
      await tester.pumpObers(
        Center(
          child: OiSmartInput(label: 'Plain', controller: controller),
        ),
      );

      // No recognizer-styled spans should be rendered.
      // The text should appear in a plain EditableText.
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(editableText.controller.text, 'hello @world');
    });

    testWidgets('has correct semantics', (tester) async {
      await tester.pumpObers(
        const Center(child: OiSmartInput(label: 'Username')),
      );

      // The Semantics widget wrapping the input should be present
      // and marked as a text field.
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Username' &&
              w.properties.textField == true,
        ),
      );
      expect(semanticsWidgets, isNotEmpty);
    });

    testWidgets('initial value is set from value parameter', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiSmartInput(label: 'Name', value: 'initial text'),
        ),
      );

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(editableText.controller.text, 'initial text');
    });

    testWidgets('suggestion popup appears with results', (tester) async {
      final recognizers = [
        OiPatternRecognizer(
          trigger: '@',
          pattern: RegExp(r'@\w+'),
          style: const TextStyle(color: Color(0xFF2563EB)),
          showSuggestions: true,
        ),
      ];

      Future<List<OiSuggestion>> querySuggestions(
        String trigger,
        String query,
      ) async {
        return [
          OiSuggestion(value: '@alice', label: 'Alice'),
          OiSuggestion(value: '@bob', label: 'Bob'),
        ];
      }

      await tester.pumpObers(
        Center(
          child: OiSmartInput(
            label: 'Message',
            recognizers: recognizers,
            onSuggestionQuery: querySuggestions,
          ),
        ),
      );

      // Type trigger character to start suggestion query.
      await tester.enterText(find.byType(EditableText).first, '@a');
      await tester.pump(); // starts async
      await tester.pump(); // async completes

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('selecting suggestion inserts text', (tester) async {
      String? lastChanged;
      final recognizers = [
        OiPatternRecognizer(
          trigger: '@',
          pattern: RegExp(r'@\w+'),
          style: const TextStyle(color: Color(0xFF2563EB)),
          showSuggestions: true,
        ),
      ];

      Future<List<OiSuggestion>> querySuggestions(
        String trigger,
        String query,
      ) async {
        return [OiSuggestion(value: '@alice', label: 'Alice')];
      }

      await tester.pumpObers(
        Center(
          child: OiSmartInput(
            label: 'Message',
            recognizers: recognizers,
            onSuggestionQuery: querySuggestions,
            onChange: (v) => lastChanged = v,
          ),
        ),
      );

      await tester.enterText(find.byType(EditableText).first, '@a');
      await tester.pump();
      await tester.pump();

      // Tap the suggestion.
      await tester.tap(find.text('Alice'));
      await tester.pump();

      expect(lastChanged, '@alice');
    });

    testWidgets('suggestion popup hides when trigger is deleted', (
      tester,
    ) async {
      final recognizers = [
        OiPatternRecognizer(
          trigger: '@',
          pattern: RegExp(r'@\w+'),
          style: const TextStyle(color: Color(0xFF2563EB)),
          showSuggestions: true,
        ),
      ];

      Future<List<OiSuggestion>> querySuggestions(
        String trigger,
        String query,
      ) async {
        return [OiSuggestion(value: '@alice', label: 'Alice')];
      }

      await tester.pumpObers(
        Center(
          child: OiSmartInput(
            label: 'Message',
            recognizers: recognizers,
            onSuggestionQuery: querySuggestions,
          ),
        ),
      );

      // Type trigger to show popup.
      await tester.enterText(find.byType(EditableText).first, '@a');
      await tester.pump();
      await tester.pump();
      expect(find.text('Alice'), findsOneWidget);

      // Clear text — popup should hide.
      await tester.enterText(find.byType(EditableText).first, '');
      await tester.pump();

      expect(find.text('Alice'), findsNothing);
    });
  });
}
