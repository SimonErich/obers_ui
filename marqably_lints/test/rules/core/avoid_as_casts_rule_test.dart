import 'package:marqably_lints/rules/core/avoid_as_casts_rule.dart';
import 'package:test/test.dart';

void main() {
  group('AvoidAsCastsRule', () {
    test('code name is correct', () {
      const rule = AvoidAsCastsRule();
      expect(rule.code.name, 'avoid_as_casts');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = AvoidAsCastsRule();
      expect(rule.filesToAnalyze, contains('**/lib/**.dart'));
    });
  });
}
