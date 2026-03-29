import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags extension declarations whose name does not end with an approved
/// suffix.
///
/// Approved suffixes: Checks, Display, Formatting, Behavior, Properties,
/// Validation, QueryScopes.
class ExtensionNamingConventionRule extends DartLintRule {
  const ExtensionNamingConventionRule() : super(code: _code);

  static const _code = LintCode(
    name: 'extension_naming_convention',
    problemMessage: 'Extension name does not follow naming convention. '
        'Use an approved suffix.',
    correctionMessage:
        'Use one of: Checks, Display, Formatting, Behavior, Properties, '
        'Validation, QueryScopes.',
  );

  /// The set of allowed suffixes for extension names.
  static const allowedSuffixes = [
    'Checks',
    'Display',
    'Formatting',
    'Behavior',
    'Properties',
    'Validation',
    'QueryScopes',
  ];

  @override
  List<String> get filesToAnalyze => const ['**/lib/**.dart'];

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (_isGeneratedFile(resolver.source.uri.path)) return;

    context.registry.addExtensionDeclaration((node) {
      final name = node.name?.lexeme;

      // Skip unnamed extensions.
      if (name == null) return;

      final hasValidSuffix = allowedSuffixes.any(name.endsWith);

      if (!hasValidSuffix) {
        reporter.atToken(node.name!, code);
      }
    });
  }

  static bool _isGeneratedFile(String path) =>
      path.endsWith('.g.dart') || path.endsWith('.freezed.dart');
}
