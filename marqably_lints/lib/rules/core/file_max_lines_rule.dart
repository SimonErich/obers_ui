import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags files that exceed 500 lines.
///
/// Consider splitting large files into smaller, focused modules.
class FileMaxLinesRule extends DartLintRule {
  const FileMaxLinesRule() : super(code: _code);

  static const _maxLines = 500;

  static const _code = LintCode(
    name: 'file_max_lines',
    problemMessage: 'File exceeds $_maxLines lines. '
        'Consider splitting into smaller files.',
    correctionMessage:
        'Extract related classes or functions into separate files.',
  );

  @override
  List<String> get filesToAnalyze => const ['**/lib/**.dart'];

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.source.uri.path;
    if (_isExcludedFile(path)) return;

    context.registry.addCompilationUnit((node) {
      final lineInfo = resolver.lineInfo;
      final actualLines = lineInfo.getLocation(node.end).lineNumber;

      if (actualLines > _maxLines) {
        reporter.atNode(node, code);
      }
    });
  }

  static bool _isExcludedFile(String path) =>
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart') ||
      path.contains('/test/');
}
