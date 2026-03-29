import 'package:analyzer/error/error.dart' show DiagnosticSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags explicit `dynamic` type annotations.
///
/// Use a specific type or `Object?` as a last resort.
class AvoidExplicitDynamicRule extends DartLintRule {
  const AvoidExplicitDynamicRule() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_explicit_dynamic',
    problemMessage: 'Explicit `dynamic` type annotation is forbidden. '
        'Use a specific type.',
    correctionMessage:
        'Replace `dynamic` with the most specific type possible, '
        'or `Object?` as last resort.',
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

    context.registry.addNamedType((node) {
      if (node.name.lexeme == 'dynamic') {
        reporter.atNode(node, code);
      }
    });
  }

  static bool _isGeneratedFile(String path) =>
      path.endsWith('.g.dart') || path.endsWith('.freezed.dart');
}
