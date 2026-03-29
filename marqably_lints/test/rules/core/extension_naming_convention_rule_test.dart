import 'package:marqably_lints/rules/core/extension_naming_convention_rule.dart';
import 'package:test/test.dart';

void main() {
  group('ExtensionNamingConventionRule', () {
    test('code name is correct', () {
      const rule = ExtensionNamingConventionRule();
      expect(rule.code.name, 'extension_naming_convention');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = ExtensionNamingConventionRule();
      expect(rule.filesToAnalyze, contains('**/lib/**.dart'));
    });

    test('allowedSuffixes contains all expected suffixes', () {
      expect(
        ExtensionNamingConventionRule.allowedSuffixes,
        containsAll([
          'Checks',
          'Display',
          'Formatting',
          'Behavior',
          'Properties',
          'Validation',
          'QueryScopes',
        ]),
      );
    });
  });
}
