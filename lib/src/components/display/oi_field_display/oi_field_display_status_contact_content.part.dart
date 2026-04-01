part of '../oi_field_display.dart';

extension _OiFieldDisplayStatusContactContent on OiFieldDisplay {
  Widget _buildBooleanDisplay(BuildContext context) {
    final colors = context.colors;
    if (value == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OiIcon.decorative(
            icon: OiIcons.circleMinus,
            color: colors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 4),
          OiLabel.small('Unknown', color: colors.textMuted),
        ],
      );
    }

    final bool boolValue = value is bool
        ? value as bool
        : value != 0 && value != '' && value != false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: boolValue ? OiIcons.check : OiIcons.undo2,
          color: boolValue ? colors.success.base : colors.error.base,
          size: 18,
        ),
        const SizedBox(width: 4),
        OiLabel.small(boolValue ? 'Yes' : 'No'),
      ],
    );
  }

  Widget _buildEmailDisplay(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: OiIcons.mail,
          color: colors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: OiLabel.small(
            _valueString,
            color: colors.primary.base,
            decoration: TextDecoration.underline,
            decorationColor: colors.primary.base,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUrlDisplay(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: OiIcons.link,
          color: colors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: OiLabel.small(
            _valueString,
            color: colors.primary.base,
            decoration: TextDecoration.underline,
            decorationColor: colors.primary.base,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneDisplay(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: OiIcons.phone,
          color: colors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        OiLabel.small(_valueString, color: colors.primary.base),
      ],
    );
  }

  Widget _buildSelectDisplay(BuildContext context) {
    final stringValue = _valueString;
    final displayLabel = choices?[stringValue] ?? stringValue;

    if (choiceColors != null || choices != null) {
      final badgeColor = choiceColors?[stringValue] ?? OiBadgeColor.neutral;
      return OiBadge.soft(label: displayLabel, color: badgeColor);
    }

    return OiLabel.small(displayLabel);
  }

  Widget _buildTagsDisplay(BuildContext context) {
    final List<String> tagList = value is List
        ? (value as List).map((e) => e.toString()).toList()
        : [_valueString];

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tagList
          .map((tag) => OiBadge.soft(label: tag, color: OiBadgeColor.neutral))
          .toList(),
    );
  }

  Widget _buildColorDisplay(BuildContext context) {
    final hex = _valueString.replaceFirst('#', '');
    final parsed = int.tryParse(hex, radix: 16);

    if (parsed == null) return _buildTextDisplay(context);

    final color = Color(parsed | 0xFF000000);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0x33000000)),
          ),
        ),
        const SizedBox(width: 8),
        OiLabel.small('#$hex'),
      ],
    );
  }
}
