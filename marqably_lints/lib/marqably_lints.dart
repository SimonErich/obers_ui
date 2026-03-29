import 'package:custom_lint_builder/custom_lint_builder.dart';

// Core Dart rules
import 'package:marqably_lints/rules/core/avoid_as_casts_rule.dart';
import 'package:marqably_lints/rules/core/avoid_bang_operator_rule.dart';
import 'package:marqably_lints/rules/core/avoid_explicit_dynamic_rule.dart';
import 'package:marqably_lints/rules/core/avoid_map_string_dynamic_rule.dart';
import 'package:marqably_lints/rules/core/avoid_utils_helpers_filenames_rule.dart';
import 'package:marqably_lints/rules/core/dotenv_outside_config_rule.dart';
import 'package:marqably_lints/rules/core/extension_naming_convention_rule.dart';
import 'package:marqably_lints/rules/core/file_max_lines_rule.dart';
import 'package:marqably_lints/rules/core/function_max_lines_rule.dart';

// Flutter rules
import 'package:marqably_lints/rules/flutter/avoid_hardcoded_colors_rule.dart';
import 'package:marqably_lints/rules/flutter/build_method_max_lines_rule.dart';
import 'package:marqably_lints/rules/flutter/one_public_widget_per_file_rule.dart';
import 'package:marqably_lints/rules/flutter/widget_file_max_lines_rule.dart';

PluginBase createPlugin() => _MarqablyLints();

class _MarqablyLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
    // Core Dart
    AvoidAsCastsRule(),
    AvoidBangOperatorRule(),
    AvoidExplicitDynamicRule(),
    AvoidMapStringDynamicRule(),
    AvoidUtilsHelpersFilenamesRule(),
    DotenvOutsideConfigRule(),
    ExtensionNamingConventionRule(),
    FileMaxLinesRule(),
    FunctionMaxLinesRule(),

    // Flutter
    AvoidHardcodedColorsRule(),
    BuildMethodMaxLinesRule(),
    OnePublicWidgetPerFileRule(),
    WidgetFileMaxLinesRule(),
  ];
}
