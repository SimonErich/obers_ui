import 'package:marqably_lints/rules/flutter/avoid_hardcoded_colors_rule.dart';
import 'package:test/test.dart';

void main() {
  group('AvoidHardcodedColorsRule', () {
    test('code name is correct', () {
      const rule = AvoidHardcodedColorsRule();
      expect(rule.code.name, 'avoid_hardcoded_colors');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = AvoidHardcodedColorsRule();
      expect(rule.filesToAnalyze, contains(startsWith('**/')));
    });
  });
}
