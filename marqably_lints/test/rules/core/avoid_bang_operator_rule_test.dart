import 'package:marqably_lints/rules/core/avoid_bang_operator_rule.dart';
import 'package:test/test.dart';

void main() {
  group('AvoidBangOperatorRule', () {
    test('code name is correct', () {
      const rule = AvoidBangOperatorRule();
      expect(rule.code.name, 'avoid_bang_operator');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = AvoidBangOperatorRule();
      expect(rule.filesToAnalyze, contains('**/lib/**.dart'));
    });
  });
}
