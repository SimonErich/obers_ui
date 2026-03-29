import 'package:marqably_lints/rules/core/file_max_lines_rule.dart';
import 'package:test/test.dart';

void main() {
  group('FileMaxLinesRule', () {
    test('code name is correct', () {
      const rule = FileMaxLinesRule();
      expect(rule.code.name, 'file_max_lines');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = FileMaxLinesRule();
      expect(rule.filesToAnalyze, contains('**/lib/**.dart'));
    });
  });
}
