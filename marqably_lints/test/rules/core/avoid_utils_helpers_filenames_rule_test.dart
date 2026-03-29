import 'package:marqably_lints/rules/core/avoid_utils_helpers_filenames_rule.dart';
import 'package:test/test.dart';

void main() {
  group('AvoidUtilsHelpersFilenamesRule', () {
    test('code name is correct', () {
      const rule = AvoidUtilsHelpersFilenamesRule();
      expect(rule.code.name, 'avoid_utils_helpers_filenames');
    });

    test('filesToAnalyze targets correct scope', () {
      const rule = AvoidUtilsHelpersFilenamesRule();
      expect(rule.filesToAnalyze, contains('**/lib/**.dart'));
    });

    test('forbiddenFilenames contains expected names', () {
      expect(
        AvoidUtilsHelpersFilenamesRule.forbiddenFilenames,
        containsAll(['utils.dart', 'helpers.dart', 'helper.dart']),
      );
    });
  });
}
