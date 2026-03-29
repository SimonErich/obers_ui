import 'package:marqably_lints/rules/flutter/widget_file_max_lines_rule.dart';
import 'package:test/test.dart';

void main() {
  group('WidgetFileMaxLinesRule', () {
    test('code name is correct', () {
      const rule = WidgetFileMaxLinesRule();
      expect(rule.code.name, 'widget_file_max_lines');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = WidgetFileMaxLinesRule();
      expect(rule.filesToAnalyze, contains(startsWith('**/')));
    });
  });
}
