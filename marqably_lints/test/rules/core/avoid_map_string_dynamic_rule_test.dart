import 'package:marqably_lints/rules/core/avoid_map_string_dynamic_rule.dart';
import 'package:test/test.dart';

void main() {
  group('AvoidMapStringDynamicRule', () {
    test('code name is correct', () {
      const rule = AvoidMapStringDynamicRule();
      expect(rule.code.name, 'avoid_map_string_dynamic');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = AvoidMapStringDynamicRule();
      expect(rule.filesToAnalyze, contains('**/lib/**.dart'));
    });
  });
}
