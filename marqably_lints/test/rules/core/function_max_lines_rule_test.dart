import 'package:marqably_lints/rules/core/function_max_lines_rule.dart';
import 'package:test/test.dart';

void main() {
  group('FunctionMaxLinesRule', () {
    test('code name is correct', () {
      const rule = FunctionMaxLinesRule();
      expect(rule.code.name, 'function_max_lines');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = FunctionMaxLinesRule();
      expect(rule.filesToAnalyze, contains('**/lib/**.dart'));
    });
  });
}
