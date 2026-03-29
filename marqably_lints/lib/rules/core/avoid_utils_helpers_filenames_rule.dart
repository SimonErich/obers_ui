import 'package:analyzer/error/error.dart' show DiagnosticSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags files named `utils.dart`, `helpers.dart`, or `helper.dart`.
///
/// These names become dumping grounds. Use descriptive filenames instead.
class AvoidUtilsHelpersFilenamesRule extends DartLintRule {
  const AvoidUtilsHelpersFilenamesRule() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_utils_helpers_filenames',
    problemMessage:
        'Files named `utils.dart` or `helpers.dart` become dumping grounds. '
        'Use descriptive names.',
    correctionMessage: 'Rename to describe the actual purpose, e.g., '
        '`date_formatting.dart`, `price_calculations.dart`.',
    errorSeverity: DiagnosticSeverity.ERROR,
  );

  /// Filenames that are not allowed.
  static const forbiddenFilenames = {
    'utils.dart',
    'helpers.dart',
    'helper.dart',
  };

  @override
  List<String> get filesToAnalyze => const ['**/lib/**.dart'];

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.source.uri.path;
    final filename = Uri.parse(path).pathSegments.lastOrNull ?? '';

    if (!forbiddenFilenames.contains(filename)) return;

    context.registry.addCompilationUnit((node) {
      // Report at the first declaration if available, otherwise at the
      // compilation unit itself.
      if (node.declarations.isNotEmpty) {
        reporter.atNode(node.declarations.first, code);
      } else {
        reporter.atNode(node, code);
      }
    });
  }
}
