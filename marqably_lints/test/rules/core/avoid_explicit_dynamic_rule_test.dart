import 'package:marqably_lints/rules/core/avoid_explicit_dynamic_rule.dart';
import 'package:test/test.dart';

void main() {
  group('AvoidExplicitDynamicRule', () {
    test('code name is correct', () {
      const rule = AvoidExplicitDynamicRule();
      expect(rule.code.name, 'avoid_explicit_dynamic');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = AvoidExplicitDynamicRule();
      expect(rule.filesToAnalyze, contains('**/lib/**.dart'));
    });
  });
}
