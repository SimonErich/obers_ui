import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show DiagnosticSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags access to `dotenv.env[...]` or `dotenv.get(...)` outside of
/// `lib/config/`.
///
/// Environment variables must be accessed only from typed config classes.
class DotenvOutsideConfigRule extends DartLintRule {
  const DotenvOutsideConfigRule() : super(code: _code);

  static const _code = LintCode(
    name: 'dotenv_outside_config',
    problemMessage:
        'Environment variables must be accessed only from `lib/config/`. '
        'Use typed config classes.',
    correctionMessage:
        'Create a config class in `lib/config/` and access the value '
        'through it.',
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
    final path = resolver.source.uri.path;

    // Access inside /config/ is allowed.
    if (path.contains('/config/')) return;

    // dotenv.env['KEY'] — IndexExpression whose target is dotenv.env
    context.registry.addIndexExpression((node) {
      if (_isDotenvEnvAccess(node.target)) {
        reporter.atNode(node, code);
      }
    });

    // dotenv.get('KEY') — MethodInvocation on dotenv
    context.registry.addMethodInvocation((node) {
      final target = node.target;
      if (target is SimpleIdentifier && target.name == 'dotenv') {
        reporter.atNode(node, code);
      }
    });
  }

  static bool _isDotenvEnvAccess(Expression? target) {
    if (target is PrefixedIdentifier) {
      return target.prefix.name == 'dotenv' && target.identifier.name == 'env';
    }
    return false;
  }
}
