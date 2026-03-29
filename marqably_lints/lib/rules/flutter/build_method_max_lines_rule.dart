import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags `build()` methods that exceed 50 lines.
///
/// Break large build methods into smaller private widget classes.
class BuildMethodMaxLinesRule extends DartLintRule {
  const BuildMethodMaxLinesRule() : super(code: _code);

  static const _maxLines = 50;

  static const _code = LintCode(
    name: 'build_method_max_lines',
    problemMessage:
        'The `build()` method exceeds $_maxLines lines. Extract sub-widgets.',
    correctionMessage:
        'Break large build methods into smaller private widget classes.',
  );

  @override
  List<String> get filesToAnalyze => const ['**/lib/**.dart'];

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.source.uri.toString();
    if (_isGenerated(path)) return;

    context.registry.addMethodDeclaration((node) {
      if (node.name.lexeme != 'build') return;
      if (node.parent is! ClassDeclaration) return;

      final body = node.body;
      if (body is! BlockFunctionBody) return;

      final startLine = resolver.lineInfo
          .getLocation(body.block.leftBracket.offset)
          .lineNumber;
      final endLine = resolver.lineInfo
          .getLocation(body.block.rightBracket.offset)
          .lineNumber;
      final lineCount = endLine - startLine + 1;

      if (lineCount > _maxLines) {
        reporter.atToken(node.name, code);
      }
    });
  }

  static bool _isGenerated(String path) =>
      path.contains('/generated/') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart');
}
