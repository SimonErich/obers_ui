import 'package:marqably_lints/rules/core/dotenv_outside_config_rule.dart';
import 'package:test/test.dart';

void main() {
  group('DotenvOutsideConfigRule', () {
    test('code name is correct', () {
      const rule = DotenvOutsideConfigRule();
      expect(rule.code.name, 'dotenv_outside_config');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = DotenvOutsideConfigRule();
      expect(rule.filesToAnalyze, contains('**/lib/**.dart'));
    });
  });
}
