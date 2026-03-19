import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../helpers/knob_helpers.dart';

const _sampleFields = [
  OiMetadataField(key: 'Title', value: 'Project Alpha', type: OiMetadataType.text),
  OiMetadataField(key: 'Version', value: 2, type: OiMetadataType.number),
  OiMetadataField(key: 'Release Date', value: '2025-06-15', type: OiMetadataType.date),
  OiMetadataField(key: 'Published', value: true, type: OiMetadataType.boolean),
  OiMetadataField(key: 'Status', value: 'Active', type: OiMetadataType.select),
];

final oiMetadataEditorComponent = WidgetbookComponent(
  name: 'OiMetadataEditor',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final allowAdd = context.knobs.boolean(
          label: 'Allow Add',
          initialValue: true,
        );
        final allowRemove = context.knobs.boolean(
          label: 'Allow Remove',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 500,
            child: OiMetadataEditor(
              fields: _sampleFields,
              onChange: (_) {},
              label: 'Metadata editor',
              enabled: enabled,
              allowAdd: allowAdd,
              allowRemove: allowRemove,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Read Only',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 500,
            child: OiMetadataEditor(
              fields: _sampleFields,
              onChange: (_) {},
              label: 'Read-only metadata',
              enabled: false,
            ),
          ),
        );
      },
    ),
  ],
);
