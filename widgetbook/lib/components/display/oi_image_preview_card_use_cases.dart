import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiImagePreviewCardComponent = WidgetbookComponent(
  name: 'OiImagePreviewCard',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final isLoading = context.knobs.boolean(label: 'Is Loading');
        final isRegenerating = context.knobs.boolean(label: 'Is Regenerating');
        final showBadge = context.knobs.boolean(
          label: 'Show Status Badge',
          initialValue: true,
        );
        final versionLabel = context.knobs.stringOrNull(
          label: 'Version Label',
          initialValue: 'v3',
        );
        final enableZoom = context.knobs.boolean(label: 'Enable Zoom');
        final showEditOverlay = context.knobs.boolean(
          label: 'Show Edit Overlay on Hover',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 320,
            height: 240,
            child: OiImagePreviewCard(
              alt: 'Preview of the generated dashboard screen',
              imageUrl: isLoading
                  ? null
                  : 'https://picsum.photos/seed/obers/640/480',
              loading: isLoading,
              regenerating: isRegenerating,
              enableZoom: enableZoom,
              versionLabel: versionLabel,
              statusBadge: showBadge
                  ? const OiBadge.soft(
                      label: 'Approved',
                      color: OiBadgeColor.success,
                    )
                  : null,
              onTap: () {},
              onEdit: showEditOverlay ? () {} : null,
            ),
          ),
        );
      },
    ),
  ],
);
