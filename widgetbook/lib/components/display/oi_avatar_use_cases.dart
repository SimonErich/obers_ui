import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiAvatarComponent = WidgetbookComponent(
  name: 'OiAvatar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final initials = context.knobs.string(
          label: 'Initials',
          initialValue: 'AB',
        );
        final size = context.knobs.enumKnob<OiAvatarSize>(
          label: 'Size',
          values: OiAvatarSize.values,
          initialValue: OiAvatarSize.md,
        );
        final presence = context.knobs.enumKnob<OiPresenceStatus>(
          label: 'Presence',
          values: OiPresenceStatus.values,
          initialValue: OiPresenceStatus.online,
        );
        final skeleton = context.knobs.boolean(label: 'Skeleton');

        return useCaseWrapper(
          OiAvatar(
            semanticLabel: 'User avatar',
            initials: initials,
            size: size,
            presence: presence,
            skeleton: skeleton,
          ),
        );
      },
    ),
  ],
);
