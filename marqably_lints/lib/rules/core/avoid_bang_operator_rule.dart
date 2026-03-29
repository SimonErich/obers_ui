import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags uses of the `!` null assertion operator.
///
/// Prefer null-aware operators, pattern matching, or explicit null checks.
class AvoidBangOperatorRule extends DartLintRule {
  const AvoidBangOperatorRule() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_bang_operator',
    problemMessage: 'Avoid the `!` null assertion operator unless the value is '
        'guaranteed non-null.',
    correctionMessage:
        'Use null-aware operators, pattern matching, or add a null check.',
  );

  @override
  List<String> get filesToAnalyze => const ['**/lib/**.dart'];

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (_isGeneratedFile(resolver.source.uri.path)) return;

    context.registry.addPostfixExpression((node) {
      if (node.operator.lexeme == '!') {
        reporter.atNode(node, code);
      }
    });
  }

  static bool _isGeneratedFile(String path) =>
      path.endsWith('.g.dart') || path.endsWith('.freezed.dart');
}
