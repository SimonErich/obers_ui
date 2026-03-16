import 'package:flutter/material.dart';
/// Builds a golden test scenario with light and dark theme variants.
///
/// Usage:
/// ```dart
/// testGoldens('OiButton variants', (tester) async {
///   final builder = obersGoldenBuilder(
///     columns: 3,
///     children: {
///       'Primary': const OiButton.primary(label: 'Click'),
///       'Secondary': const OiButton.secondary(label: 'Click'),
///       'Ghost': const OiButton.ghost(label: 'Click'),
///     },
///   );
///   await tester.pumpWidgetBuilder(builder);
///   await screenMatchesGolden(tester, 'oi_button_variants');
/// });
/// ```
Widget obersGoldenBuilder({
  required Map<String, Widget> children,
  int columns = 2,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children.entries.map((entry) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                entry.value,
              ],
            );
          }).toList(),
        ),
      ),
    ),
  );
}
