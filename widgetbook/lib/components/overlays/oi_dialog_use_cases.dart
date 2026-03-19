import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiDialogComponent = WidgetbookComponent(
  name: 'OiDialog',
  useCases: [
    WidgetbookUseCase(
      name: 'Standard',
      builder: (context) {
        final title = context.knobs.string(
          label: 'Title',
          initialValue: 'Dialog Title',
        );
        final dismissible = context.knobs.boolean(
          label: 'Dismissible',
          initialValue: true,
        );

        return useCaseWrapper(
          OiButton.primary(
            label: 'Open Standard Dialog',
            onTap: () {
              late OiOverlayHandle handle;
              handle = OiDialog.show(
                context,
                dialog: OiDialog.standard(
                  label: 'Standard dialog',
                  title: title,
                  dismissible: dismissible,
                  content: const Text('This is the dialog content.'),
                  actions: [
                    OiButton.ghost(
                      label: 'Cancel',
                      onTap: () => handle.dismiss(),
                    ),
                    OiButton.primary(
                      label: 'Confirm',
                      onTap: () => handle.dismiss(),
                    ),
                  ],
                  onClose: () => handle.dismiss(),
                ),
              );
            },
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Alert',
      builder: (context) {
        return useCaseWrapper(
          OiButton.primary(
            label: 'Open Alert Dialog',
            onTap: () {
              late OiOverlayHandle handle;
              handle = OiDialog.show(
                context,
                dialog: OiDialog.alert(
                  label: 'Alert dialog',
                  title: 'Alert',
                  content: const Text('Something important happened.'),
                  actions: [
                    OiButton.primary(
                      label: 'OK',
                      onTap: () => handle.dismiss(),
                    ),
                  ],
                  onClose: () => handle.dismiss(),
                ),
              );
            },
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Confirm',
      builder: (context) {
        return useCaseWrapper(
          OiButton.destructive(
            label: 'Open Confirm Dialog',
            onTap: () {
              late OiOverlayHandle handle;
              handle = OiDialog.show(
                context,
                dialog: OiDialog.confirm(
                  label: 'Confirm dialog',
                  title: 'Delete item?',
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    OiButton.ghost(
                      label: 'Cancel',
                      onTap: () => handle.dismiss(),
                    ),
                    OiButton.destructive(
                      label: 'Delete',
                      onTap: () => handle.dismiss(),
                    ),
                  ],
                  onClose: () => handle.dismiss(),
                ),
              );
            },
          ),
        );
      },
    ),
  ],
);
