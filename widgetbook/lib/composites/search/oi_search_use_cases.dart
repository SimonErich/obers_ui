import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleSources = [
  OiSearchSource(
    category: 'Files',
    icon: Icons.description,
    search: (query) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final items = ['README.md', 'main.dart', 'pubspec.yaml', 'index.html'];
      return items
          .where((f) => f.toLowerCase().contains(query.toLowerCase()))
          .map((f) => OiSearchResult(id: f, title: f, subtitle: 'File'))
          .toList();
    },
  ),
  OiSearchSource(
    category: 'Commands',
    icon: Icons.terminal,
    search: (query) async {
      final cmds = ['Open File', 'Save', 'Undo', 'Redo', 'Find'];
      return cmds
          .where((c) => c.toLowerCase().contains(query.toLowerCase()))
          .map((c) => OiSearchResult(id: c, title: c, subtitle: 'Command'))
          .toList();
    },
  ),
];

final oiSearchComponent = WidgetbookComponent(
  name: 'OiSearch',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 500,
            height: 400,
            child: OiSearch(label: 'Global search', sources: _sampleSources),
          ),
        );
      },
    ),
  ],
);
