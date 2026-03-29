import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags files that contain more than one public widget class.
///
/// Each public widget class should live in its own file.
///
/// Exceptions:
/// - Files containing `sealed` or `abstract` class declarations are skipped
///   (they may define a widget hierarchy).
/// - `StatefulWidget` files are skipped — the Widget + State pair counts as
///   one logical widget.
class OnePublicWidgetPerFileRule extends DartLintRule {
  const OnePublicWidgetPerFileRule() : super(code: _code);

  static const _code = LintCode(
    name: 'one_public_widget_per_file',
    problemMessage: 'Only one public widget class per file. '
        'Found multiple public widget classes.',
    correctionMessage:
        'Move additional public widget classes to their own files.',
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

    context.registry.addCompilationUnit((node) {
      // Skip files that contain sealed or abstract class declarations —
      // they may define a widget hierarchy.
      for (final declaration in node.declarations) {
        if (declaration is ClassDeclaration) {
          if (declaration.sealedKeyword != null ||
              declaration.abstractKeyword != null) {
            return;
          }
        }
      }

      final publicWidgetClasses = <ClassDeclaration>[];
      var hasStatefulWidget = false;

      for (final declaration in node.declarations) {
        if (declaration is! ClassDeclaration) continue;
        // Skip private classes.
        if (declaration.name.lexeme.startsWith('_')) continue;

        final superclass = declaration.extendsClause?.superclass.name.lexeme;
        if (superclass == null) continue;

        if (_isWidgetSuperclass(superclass)) {
          publicWidgetClasses.add(declaration);
        }

        if (superclass == 'StatefulWidget') {
          hasStatefulWidget = true;
        }
      }

      // Skip StatefulWidget files — the Widget + State pair counts as one
      // logical widget.
      if (hasStatefulWidget) return;

      if (publicWidgetClasses.length > 1) {
        // Flag the second and subsequent public widget classes.
        for (var i = 1; i < publicWidgetClasses.length; i++) {
          reporter.atToken(publicWidgetClasses[i].name, code);
        }
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
      'ConsumerWidget',
      'State',
    };
    return widgetSuperclasses.contains(name) || name.endsWith('Widget');
  }

  static bool _isGenerated(String path) =>
      path.contains('/generated/') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart');
}
