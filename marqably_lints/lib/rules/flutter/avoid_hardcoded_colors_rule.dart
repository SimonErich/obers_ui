import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show DiagnosticSeverity;
import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags hardcoded color values in library code.
///
/// Use design tokens instead of raw `Color(0x...)` or `Colors.*` references.
class AvoidHardcodedColorsRule extends DartLintRule {
  const AvoidHardcodedColorsRule() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_hardcoded_colors',
    problemMessage: 'Hardcoded colors are forbidden. '
        'Use design tokens instead.',
    correctionMessage: 'Replace with a design token.',
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
    final path = resolver.source.uri.toString();
    if (_isGenerated(path) || _isTest(path)) return;

    // Detect `Color(0xFF...)` constructor calls with hex literals.
    context.registry.addInstanceCreationExpression(
      (node) {
        final constructorName = node.constructorName.type.name.lexeme;
        if (constructorName != 'Color') return;

        final args = node.argumentList.arguments;
        if (args.isEmpty) return;

        final firstArg = args.first;
        if (firstArg is IntegerLiteral) {
          final lexeme = firstArg.literal.lexeme;
          if (lexeme.startsWith('0x') || lexeme.startsWith('0X')) {
            reporter.atNode(node, code);
          }
        }
      },
    );

    // Detect `Colors.red`, `Colors.blue`, etc.
    context.registry.addPrefixedIdentifier((node) {
      if (node.prefix.name == 'Colors') {
        reporter.atNode(node, code);
      }
    });
  }

  static bool _isGenerated(String path) =>
      path.contains('/generated/') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart');

  static bool _isTest(String path) =>
      path.contains('/test/') || path.contains('/test_driver/');
}
