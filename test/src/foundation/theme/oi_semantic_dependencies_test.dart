import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new semantic color modules have no circular imports', () {
    final files = <String>[
      ...Directory(
        'lib/src/foundation/theme/color',
      ).listSync().whereType<File>().map((file) => file.path),
      ...[
        'chart_colors',
        'color_ramp',
        'ink_colors',
        'legacy_semantic_colors',
        'rail_colors',
        'role_colors',
        'semantic_colors',
        'surface_colors',
      ].map((name) => 'lib/src/foundation/theme/oi_$name.dart'),
    ];
    final imports = RegExp("import 'package:obers_ui/([^']+)'");
    final graph = <String, List<String>>{
      for (final path in files)
        path: imports
            .allMatches(File(path).readAsStringSync())
            .map((match) => 'lib/${match[1]}')
            .where(files.contains)
            .toList(),
    };
    final visited = <String>{};
    final stack = <String>[];
    final cycles = <String>[];
    void visit(String path) {
      if (stack.contains(path)) {
        cycles.add([...stack.skip(stack.indexOf(path)), path].join(' → '));
        return;
      }
      if (!visited.add(path)) return;
      stack.add(path);
      graph[path]!.forEach(visit);
      stack.removeLast();
    }

    files.forEach(visit);
    expect(cycles, isEmpty, reason: 'CLAUDE.md forbids circular dependencies');
  });
}
