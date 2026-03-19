import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiEmojiPickerComponent = WidgetbookComponent(
  name: 'OiEmojiPicker',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showSearch = context.knobs.boolean(
          label: 'Show Search',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 320,
            height: 400,
            child: OiEmojiPicker(
              showSearch: showSearch,
              onSelected: (_) {},
            ),
          ),
        );
      },
    ),
  ],
);
