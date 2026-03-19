import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final _sampleNodes = <OiTreeNode<void>>[
  OiTreeNode(
    id: 'root1',
    label: 'Documents',
    children: [
      const OiTreeNode(id: 'doc1', label: 'Resume.pdf'),
      const OiTreeNode(id: 'doc2', label: 'Cover Letter.docx'),
    ],
  ),
  OiTreeNode(
    id: 'root2',
    label: 'Photos',
    children: [
      const OiTreeNode(id: 'photo1', label: 'Vacation.jpg'),
      OiTreeNode(
        id: 'album1',
        label: 'Album 2024',
        children: const [
          OiTreeNode(id: 'photo2', label: 'Beach.png'),
        ],
      ),
    ],
  ),
  const OiTreeNode(id: 'root3', label: 'Notes.txt'),
];

final oiTreeComponent = WidgetbookComponent(
  name: 'OiTree',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final selectable = context.knobs.boolean(
          label: 'Selectable',
          initialValue: true,
        );
        final multiSelect = context.knobs.boolean(
          label: 'Multi Select',
          initialValue: false,
        );
        final showLines = context.knobs.boolean(
          label: 'Show Lines',
          initialValue: false,
        );

        return SizedBox(
          height: 400,
          child: OiTree<void>(
            label: 'File tree',
            nodes: _sampleNodes,
            selectable: selectable,
            multiSelect: multiSelect,
            showLines: showLines,
          ),
        );
      },
    ),
  ],
);
