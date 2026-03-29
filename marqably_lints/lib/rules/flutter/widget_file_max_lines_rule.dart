import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags widget files that exceed 300 lines.
///
/// Extract sub-widgets into separate files to keep widget files concise.
class WidgetFileMaxLinesRule extends DartLintRule {
  const WidgetFileMaxLinesRule() : super(code: _code);

  static const _maxLines = 300;

  static const _code = LintCode(
    name: 'widget_file_max_lines',
    problemMessage: 'Widget file exceeds $_maxLines lines. '
        'Extract sub-widgets into separate files.',
    correctionMessage: 'Move reusable or large sub-widgets to their own files.',
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

    context.registry.addCompilationUnit((node) {
      final hasWidgetClass = node.declarations.any((declaration) {
        if (declaration is! ClassDeclaration) return false;
        final superclass = declaration.extendsClause?.superclass.name.lexeme;
        return superclass != null && _isWidgetSuperclass(superclass);
      });

      if (!hasWidgetClass) return;

      final lineCount = resolver.lineInfo.getLocation(node.end).lineNumber;
      if (lineCount > _maxLines) {
        reporter.atNode(node.declarations.first, code);
      }
    });
  }

  static bool _isWidgetSuperclass(String name) {
    const widgetSuperclasses = {
      'Widget',
      'StatelessWidget',
      'StatefulWidget',
      'HookWidget',
      'HookConsumerWidget',
    };
    return widgetSuperclasses.contains(name) || name.endsWith('Widget');
  }

  static bool _isGenerated(String path) =>
      path.contains('/generated/') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart');

  static bool _isTest(String path) =>
      path.contains('/test/') || path.contains('/test_driver/');
}
