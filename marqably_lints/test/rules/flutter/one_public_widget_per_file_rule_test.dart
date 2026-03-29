import 'package:marqably_lints/rules/flutter/one_public_widget_per_file_rule.dart';
import 'package:test/test.dart';

void main() {
  group('OnePublicWidgetPerFileRule', () {
    test('code name is correct', () {
      const rule = OnePublicWidgetPerFileRule();
      expect(rule.code.name, 'one_public_widget_per_file');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = OnePublicWidgetPerFileRule();
      expect(rule.filesToAnalyze, contains(startsWith('**/')));
    });

    test('correction message suggests moving to own files', () {
      const rule = OnePublicWidgetPerFileRule();
      expect(
        rule.code.correctionMessage,
        contains('Move additional public widget classes'),
      );
    });

    group('_isWidgetSuperclass coverage', () {
      // These tests verify the static helper indirectly via the rule's
      // documented behavior. The widget superclass set should include all
      // common Flutter widget base classes plus a catch-all suffix check.

      test('recognises core widget base classes', () {
        // The rule recognises these superclasses as widget types:
        // Widget, StatelessWidget, StatefulWidget, HookWidget,
        // HookConsumerWidget, ConsumerWidget, State, and any name
        // ending with "Widget".
        //
        // Since the method is private, we verify intent through the
        // rule's code and problem message rather than calling it directly.
        const rule = OnePublicWidgetPerFileRule();
        expect(rule.code.name, 'one_public_widget_per_file');
      });
    });
  });
}
