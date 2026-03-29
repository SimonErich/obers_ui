import 'package:analyzer/error/error.dart' show DiagnosticSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags every `as` cast expression.
///
/// Use pattern matching or typed APIs instead of `as` casts.
class AvoidAsCastsRule extends DartLintRule {
  const AvoidAsCastsRule() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_as_casts',
    problemMessage:
        'Avoid `as` casts. Use pattern matching or typed APIs instead.',
    correctionMessage:
        'Use `if (value case final Type x)` or `switch` expressions '
        'for safe type narrowing.',
    errorSeverity: DiagnosticSeverity.ERROR,
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

    context.registry.addAsExpression((node) {
      reporter.atNode(node, code);
    });
  }

  static bool _isGeneratedFile(String path) =>
      path.endsWith('.g.dart') || path.endsWith('.freezed.dart');
}
