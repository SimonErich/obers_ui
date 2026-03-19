import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiListTileComponent = WidgetbookComponent(
  name: 'OiListTile',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final title = context.knobs.string(
          label: 'Title',
          initialValue: 'List Tile Title',
        );
        final subtitle = context.knobs.string(
          label: 'Subtitle',
          initialValue: 'Supporting text',
        );
        final selected = context.knobs.boolean(label: 'Selected');
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final dense = context.knobs.boolean(label: 'Dense');

        return useCaseWrapper(
          SizedBox(
            width: 360,
            child: OiListTile(
              title: title,
              subtitle: subtitle.isEmpty ? null : subtitle,
              selected: selected,
              enabled: enabled,
              dense: dense,
              leading: const Icon(Icons.folder, size: 20),
              onTap: () {},
            ),
          ),
        );
      },
    ),
  ],
);
