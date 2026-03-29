import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags functions and methods whose body exceeds 20 lines.
///
/// Keep functions short and single-purpose.
class FunctionMaxLinesRule extends DartLintRule {
  const FunctionMaxLinesRule() : super(code: _code);

  static const _maxLines = 20;

  static const _code = LintCode(
    name: 'function_max_lines',
    problemMessage: 'Function body exceeds $_maxLines lines. '
        'Keep functions short and single-purpose.',
    correctionMessage:
        'Extract logic into smaller, well-named functions or methods.',
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

    context.registry.addFunctionDeclaration((node) {
      _checkBody(node.functionExpression.body, node, resolver, reporter);
    });

    context.registry.addMethodDeclaration((node) {
      _checkBody(node.body, node, resolver, reporter);
    });
  }

  void _checkBody(
    FunctionBody body,
    AstNode reportNode,
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
  ) {
    final lineInfo = resolver.lineInfo;
    final startLine = lineInfo.getLocation(body.offset).lineNumber;
    final endLine = lineInfo.getLocation(body.end).lineNumber;
    final actualLines = endLine - startLine;

    if (actualLines > _maxLines) {
      reporter.atNode(reportNode, code);
    }
  }

  static bool _isExcludedFile(String path) =>
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart') ||
      path.contains('/test/');
}
