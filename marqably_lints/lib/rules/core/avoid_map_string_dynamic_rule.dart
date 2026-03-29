import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show DiagnosticSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags `Map<String, dynamic>` type annotations in domain and presentation
/// code.
///
/// Use typed DTOs instead.
class AvoidMapStringDynamicRule extends DartLintRule {
  const AvoidMapStringDynamicRule() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_map_string_dynamic',
    problemMessage:
        'Avoid `Map<String, dynamic>` in domain and presentation code. '
        'Use typed DTOs.',
    correctionMessage:
        'Create a typed class or DTO instead of using Map<String, dynamic>.',
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
      if (node.name.lexeme != 'Map') return;

      final typeArgs = node.typeArguments?.arguments;
      if (typeArgs == null || typeArgs.length != 2) return;

      final firstArg = typeArgs[0];
      final secondArg = typeArgs[1];

      if (firstArg is NamedType &&
          firstArg.name.lexeme == 'String' &&
          secondArg is NamedType &&
          secondArg.name.lexeme == 'dynamic') {
        reporter.atNode(node, code);
      }
    });
  }

  static bool _isGeneratedFile(String path) =>
      path.endsWith('.g.dart') || path.endsWith('.freezed.dart');
}
