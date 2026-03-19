import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiFileDisplayComponent = WidgetbookComponent(
  name: 'File Display Widgets',
  useCases: [
    WidgetbookUseCase(
      name: 'OiFileIcon',
      builder: (context) {
        final fileName = context.knobs.string(
          label: 'File Name',
          initialValue: 'report.pdf',
        );
        final size = context.knobs.enumKnob<OiFileIconSize>(
          label: 'Size',
          values: OiFileIconSize.values,
          initialValue: OiFileIconSize.md,
        );

        return useCaseWrapper(
          OiFileIcon(fileName: fileName, size: size),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiFolderIcon',
      builder: (context) {
        final state = context.knobs.enumKnob<OiFolderIconState>(
          label: 'State',
          values: OiFolderIconState.values,
        );
        final variant = context.knobs.enumKnob<OiFolderIconVariant>(
          label: 'Variant',
          values: OiFolderIconVariant.values,
        );
        final size = context.knobs.enumKnob<OiFolderIconSize>(
          label: 'Size',
          values: OiFolderIconSize.values,
          initialValue: OiFolderIconSize.md,
        );

        return useCaseWrapper(
          OiFolderIcon(state: state, variant: variant, size: size),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiStorageIndicator',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 260,
            child: OiStorageIndicator(
              usedBytes: 6500000000,
              totalBytes: 10000000000,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiPathBar',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 400,
            child: OiPathBar(
              segments: const [
                OiPathSegment(id: 'home', label: 'Home'),
                OiPathSegment(id: 'docs', label: 'Documents'),
                OiPathSegment(id: 'proj', label: 'Projects'),
              ],
              onNavigate: (_) {},
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiDropHighlight',
      builder: (context) {
        final style = context.knobs.enumKnob<OiDropHighlightStyle>(
          label: 'Style',
          values: OiDropHighlightStyle.values,
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            height: 200,
            child: OiDropHighlight(
              active: true,
              style: style,
              message: 'Drop files here',
              icon: Icons.cloud_upload,
              child: const Center(child: Text('Content area')),
            ),
          ),
        );
      },
    ),
  ],
);
