import 'package:marqably_lints/rules/flutter/build_method_max_lines_rule.dart';
import 'package:test/test.dart';

void main() {
  group('BuildMethodMaxLinesRule', () {
    test('code name is correct', () {
      const rule = BuildMethodMaxLinesRule();
      expect(rule.code.name, 'build_method_max_lines');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = BuildMethodMaxLinesRule();
      expect(rule.filesToAnalyze, contains(startsWith('**/')));
    });
  });
}
