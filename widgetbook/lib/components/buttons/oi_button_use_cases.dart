import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiButtonComponent = WidgetbookComponent(
  name: 'OiButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Button',
        );
        final variant = context.knobs.enumKnob<OiButtonVariant>(
          label: 'Variant',
          values: OiButtonVariant.values,
        );
        final size = context.knobs.enumKnob<OiButtonSize>(
          label: 'Size',
          values: OiButtonSize.values,
          initialValue: OiButtonSize.medium,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final loading = context.knobs.boolean(label: 'Loading');
        final fullWidth = context.knobs.boolean(label: 'Full Width');
        final showIcon = context.knobs.boolean(label: 'Show Icon');
        final icon = showIcon ? context.knobs.iconKnob() : null;

        Widget button;
        switch (variant) {
          case OiButtonVariant.primary:
            button = OiButton.primary(
              label: label,
              size: size,
              enabled: enabled,
              loading: loading,
              fullWidth: fullWidth,
              icon: icon,
              onTap: () {},
            );
          case OiButtonVariant.secondary:
            button = OiButton.secondary(
              label: label,
              size: size,
              enabled: enabled,
              loading: loading,
              fullWidth: fullWidth,
              icon: icon,
              onTap: () {},
            );
          case OiButtonVariant.outline:
            button = OiButton.outline(
              label: label,
              size: size,
              enabled: enabled,
              loading: loading,
              fullWidth: fullWidth,
              icon: icon,
              onTap: () {},
            );
          case OiButtonVariant.ghost:
            button = OiButton.ghost(
              label: label,
              size: size,
              enabled: enabled,
              loading: loading,
              fullWidth: fullWidth,
              icon: icon,
              onTap: () {},
            );
          case OiButtonVariant.destructive:
            button = OiButton.destructive(
              label: label,
              size: size,
              enabled: enabled,
              loading: loading,
              fullWidth: fullWidth,
              icon: icon,
              onTap: () {},
            );
          case OiButtonVariant.soft:
            button = OiButton.soft(
              label: label,
              size: size,
              enabled: enabled,
              loading: loading,
              fullWidth: fullWidth,
              icon: icon,
              onTap: () {},
            );
        }

        return useCaseWrapper(button);
      },
    ),
    WidgetbookUseCase(
      name: 'Primary',
      builder: (context) {
        return useCaseWrapper(OiButton.primary(label: 'Primary', onTap: () {}));
      },
    ),
    WidgetbookUseCase(
      name: 'Secondary',
      builder: (context) {
        return useCaseWrapper(
          OiButton.secondary(label: 'Secondary', onTap: () {}),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Outline',
      builder: (context) {
        return useCaseWrapper(OiButton.outline(label: 'Outline', onTap: () {}));
      },
    ),
    WidgetbookUseCase(
      name: 'Ghost',
      builder: (context) {
        return useCaseWrapper(OiButton.ghost(label: 'Ghost', onTap: () {}));
      },
    ),
    WidgetbookUseCase(
      name: 'Destructive',
      builder: (context) {
        return useCaseWrapper(
          OiButton.destructive(label: 'Destructive', onTap: () {}),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Soft',
      builder: (context) {
        return useCaseWrapper(OiButton.soft(label: 'Soft', onTap: () {}));
      },
    ),
    WidgetbookUseCase(
      name: 'Icon Button',
      builder: (context) {
        final icon = context.knobs.iconKnob();
        final variant = context.knobs.enumKnob<OiButtonVariant>(
          label: 'Variant',
          values: OiButtonVariant.values,
          initialValue: OiButtonVariant.ghost,
        );
        final size = context.knobs.enumKnob<OiButtonSize>(
          label: 'Size',
          values: OiButtonSize.values,
          initialValue: OiButtonSize.medium,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          OiButton.icon(
            icon: icon,
            label: 'Icon button',
            variant: variant,
            size: size,
            enabled: enabled,
            onTap: () {},
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Split Button',
      builder: (context) {
        final variant = context.knobs.enumKnob<OiButtonVariant>(
          label: 'Variant',
          values: OiButtonVariant.values,
        );
        final size = context.knobs.enumKnob<OiButtonSize>(
          label: 'Size',
          values: OiButtonSize.values,
          initialValue: OiButtonSize.medium,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          OiButton.split(
            label: 'Save',
            variant: variant,
            size: size,
            enabled: enabled,
            onTap: () {},
            dropdown: Container(
              padding: const EdgeInsets.all(8),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Save as Draft'),
                  SizedBox(height: 8),
                  Text('Save & Close'),
                  SizedBox(height: 8),
                  Text('Save & New'),
                ],
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Countdown',
      builder: (context) {
        final seconds = context.knobs.int.slider(
          label: 'Seconds',
          initialValue: 5,
          min: 1,
          max: 30,
        );
        final variant = context.knobs.enumKnob<OiButtonVariant>(
          label: 'Variant',
          values: OiButtonVariant.values,
        );

        return useCaseWrapper(
          OiButton.countdown(
            label: 'Confirm',
            seconds: seconds,
            variant: variant,
            onTap: () {},
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Confirm',
      builder: (context) {
        final variant = context.knobs.enumKnob<OiButtonVariant>(
          label: 'Variant',
          values: OiButtonVariant.values,
          initialValue: OiButtonVariant.destructive,
        );

        return useCaseWrapper(
          OiButton.confirm(
            label: 'Delete',
            confirmLabel: 'Are you sure?',
            variant: variant,
            onConfirm: () {},
          ),
        );
      },
    ),
  ],
);
