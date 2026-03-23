import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture test that enforces the 5-tier composition hierarchy.
///
/// Each tier may only import from the tier below (or the same tier).
/// No file may import `package:flutter/material.dart` or
/// `package:flutter/cupertino.dart`.
///
/// Tier 0: Foundation  — lib/src/foundation/
/// Tier 1: Primitives  — lib/src/primitives/
/// Tier 2: Components  — lib/src/components/
/// Tier 3: Composites  — lib/src/composites/
/// Tier 4: Modules     — lib/src/modules/
void main() {
  /// Resolve the package lib/src directory relative to the test file.
  final packageRoot = _findPackageRoot();
  final srcDir = Directory('$packageRoot/lib/src');

  /// Map tier directory names to their numeric tier level.
  const tierMap = <String, int>{
    'foundation': 0,
    'primitives': 1,
    'components': 2,
    'composites': 3,
    'modules': 4,
  };

  /// Reverse map: given a package-internal path segment, return its tier.
  int? tierForImport(String importPath) {
    // Match imports like:
    //   package:obers_ui_charts/src/<tier>/...
    final match = RegExp(
      r'package:obers_ui_charts/src/(\w+)/',
    ).firstMatch(importPath);
    if (match == null) return null;
    return tierMap[match.group(1)];
  }

  /// Determine which tier a source file belongs to based on its path.
  int? tierForFile(String filePath) {
    for (final entry in tierMap.entries) {
      if (filePath.contains('/src/${entry.key}/')) {
        return entry.value;
      }
    }
    return null;
  }

  /// Collect all .dart files under [dir] recursively.
  List<File> dartFiles(Directory dir) {
    if (!dir.existsSync()) return [];
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
  }

  /// Extract import URIs from a Dart source file.
  List<String> extractImports(File file) {
    final contents = file.readAsStringSync();
    final importRegex = RegExp(r"^\s*import\s+'([^']+)'\s*;", multiLine: true);
    return importRegex.allMatches(contents).map((m) => m.group(1)!).toList();
  }

  // ──────────────────────────────────────────────────────────
  // Test: No file imports package:flutter/material.dart
  // ──────────────────────────────────────────────────────────
  test('no file imports package:flutter/material.dart', () {
    final violations = <String>[];

    for (final file in dartFiles(srcDir)) {
      for (final imp in extractImports(file)) {
        if (imp == 'package:flutter/material.dart') {
          violations.add(
            '${_relative(file.path, packageRoot)} imports $imp',
          );
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Material imports are forbidden.\n${violations.join('\n')}',
    );
  });

  // ──────────────────────────────────────────────────────────
  // Test: No file imports package:flutter/cupertino.dart
  // ──────────────────────────────────────────────────────────
  test('no file imports package:flutter/cupertino.dart', () {
    final violations = <String>[];

    for (final file in dartFiles(srcDir)) {
      for (final imp in extractImports(file)) {
        if (imp == 'package:flutter/cupertino.dart') {
          violations.add(
            '${_relative(file.path, packageRoot)} imports $imp',
          );
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Cupertino imports are forbidden.\n${violations.join('\n')}',
    );
  });

  // ──────────────────────────────────────────────────────────
  // Per-tier tests: each tier only imports from the tier below
  // ──────────────────────────────────────────────────────────
  for (final entry in tierMap.entries) {
    final tierName = entry.key;
    final tierLevel = entry.value;
    final tierDir = Directory('${srcDir.path}/$tierName');

    test('Tier $tierLevel ($tierName) only imports from lower tiers', () {
      final violations = <String>[];

      for (final file in dartFiles(tierDir)) {
        for (final imp in extractImports(file)) {
          final importedTier = tierForImport(imp);
          if (importedTier == null) continue; // external or dart: import
          if (importedTier > tierLevel) {
            violations.add(
              '${_relative(file.path, packageRoot)} '
              '(tier $tierLevel) imports from tier $importedTier: $imp',
            );
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Tier $tierLevel ($tierName) must not import from higher tiers.\n'
            '${violations.join('\n')}',
      );
    });
  }

  // ──────────────────────────────────────────────────────────
  // Test: All 5 tier directories exist
  // ──────────────────────────────────────────────────────────
  test('all 5 tier directories exist', () {
    for (final tier in tierMap.keys) {
      final dir = Directory('${srcDir.path}/$tier');
      expect(
        dir.existsSync(),
        isTrue,
        reason: 'Tier directory lib/src/$tier/ must exist',
      );
    }
  });

  // ──────────────────────────────────────────────────────────
  // Test: Each chart family directory exists under composites
  // ──────────────────────────────────────────────────────────
  test('all 5 chart family directories exist under composites', () {
    const families = ['cartesian', 'polar', 'matrix', 'hierarchical', 'flow'];
    final compositesDir = Directory('${srcDir.path}/composites');

    for (final family in families) {
      final dir = Directory('${compositesDir.path}/$family');
      expect(
        dir.existsSync(),
        isTrue,
        reason: 'Chart family directory composites/$family/ must exist',
      );
    }
  });

  // ──────────────────────────────────────────────────────────
  // Test: Foundation tier contains required subsystems
  // ──────────────────────────────────────────────────────────
  test('foundation tier contains required subsystems', () {
    final foundationDir = Directory('${srcDir.path}/foundation');
    final expectedPaths = [
      'theme', // theme subsystem
      'scales', // scales subsystem
      'data', // data contracts
    ];

    for (final sub in expectedPaths) {
      final dir = Directory('${foundationDir.path}/$sub');
      expect(
        dir.existsSync(),
        isTrue,
        reason: 'Foundation subsystem $sub/ must exist',
      );
    }

    // Behavior and accessibility files at foundation root
    final behaviorFile = File('${foundationDir.path}/chart_behavior.dart');
    final a11yFile = File('${foundationDir.path}/chart_accessibility.dart');
    expect(behaviorFile.existsSync(), isTrue,
        reason: 'chart_behavior.dart must exist in foundation');
    expect(a11yFile.existsSync(), isTrue,
        reason: 'chart_accessibility.dart must exist in foundation');
  });

  // ──────────────────────────────────────────────────────────
  // Test: Primitives tier contains required subsystems
  // ──────────────────────────────────────────────────────────
  test('primitives tier contains required subsystems', () {
    final primitivesDir = Directory('${srcDir.path}/primitives');
    const expectedDirs = ['painters', 'markers', 'layers', 'hit_testing'];

    for (final sub in expectedDirs) {
      final dir = Directory('${primitivesDir.path}/$sub');
      expect(
        dir.existsSync(),
        isTrue,
        reason: 'Primitives subsystem $sub/ must exist',
      );
    }
  });

  // ──────────────────────────────────────────────────────────
  // Test: Components tier contains required subsystems
  // ──────────────────────────────────────────────────────────
  test('components tier contains required subsystems', () {
    final componentsDir = Directory('${srcDir.path}/components');
    const expectedDirs = [
      'axes',
      'legend',
      'tooltip',
      'crosshair',
      'annotations',
      'threshold',
    ];

    for (final sub in expectedDirs) {
      final dir = Directory('${componentsDir.path}/$sub');
      expect(
        dir.existsSync(),
        isTrue,
        reason: 'Components subsystem $sub/ must exist',
      );
    }
  });

  // ──────────────────────────────────────────────────────────
  // Test: Barrel file exports from all tiers
  // ──────────────────────────────────────────────────────────
  test('barrel file exports from all active tiers', () {
    final barrelFile = File('$packageRoot/lib/obers_ui_charts.dart');
    expect(barrelFile.existsSync(), isTrue);

    final contents = barrelFile.readAsStringSync();

    // Tier 0
    expect(contents, contains("src/foundation/"),
        reason: 'Barrel must export foundation (Tier 0)');
    // Tier 1
    expect(contents, contains("src/primitives/"),
        reason: 'Barrel must export primitives (Tier 1)');
    // Tier 2
    expect(contents, contains("src/components/"),
        reason: 'Barrel must export components (Tier 2)');
    // Tier 3
    expect(contents, contains("src/composites/"),
        reason: 'Barrel must export composites (Tier 3)');
  });
}

/// Returns a path relative to [base].
String _relative(String path, String base) {
  if (path.startsWith(base)) {
    return path.substring(base.length + 1);
  }
  return path;
}

/// Finds the package root by walking up from the test file location.
String _findPackageRoot() {
  // When running via `flutter test` the CWD is the package root.
  var dir = Directory.current;

  // Verify we're in the right package by checking for pubspec.yaml
  // with the obers_ui_charts name.
  final pubspec = File('${dir.path}/pubspec.yaml');
  if (pubspec.existsSync() &&
      pubspec.readAsStringSync().contains('name: obers_ui_charts')) {
    return dir.path;
  }

  // Fallback: search upward
  while (dir.parent.path != dir.path) {
    final candidate = File('${dir.path}/pubspec.yaml');
    if (candidate.existsSync() &&
        candidate.readAsStringSync().contains('name: obers_ui_charts')) {
      return dir.path;
    }
    dir = dir.parent;
  }

  // Last resort
  return Directory.current.path;
}
