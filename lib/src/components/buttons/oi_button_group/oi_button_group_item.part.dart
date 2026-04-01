part of '../oi_button_group.dart';

extension _OiButtonGroupItemBuilder on _OiButtonGroupState {
  Widget _buildItem(
    BuildContext context,
    int index,
    BorderRadius borderRadius,
  ) {
    final item = widget.items[index];

    final Widget button;
    if (widget.exclusive) {
      // Exclusive mode: group manages selection; item.onTap is ignored.
      final isSelected = widget.selectedIndex == index;
      if (isSelected) {
        button = OiButton.soft(
          label: item.label,
          icon: item.icon,
          size: widget.size,
          enabled: item.enabled,
          onTap: () => widget.onSelect?.call(index),
          semanticLabel: item.semanticLabel,
          borderRadius: borderRadius,
        );
      } else {
        button = OiButton.ghost(
          label: item.label,
          icon: item.icon,
          size: widget.size,
          enabled: item.enabled,
          onTap: () => widget.onSelect?.call(index),
          semanticLabel: item.semanticLabel,
          borderRadius: borderRadius,
        );
      }
      return Semantics(selected: isSelected, child: button);
    } else {
      // Non-exclusive mode: each item fires its own onTap.
      return OiButton.ghost(
        label: item.label,
        icon: item.icon,
        size: widget.size,
        enabled: item.enabled,
        onTap: item.onTap,
        semanticLabel: item.semanticLabel,
        borderRadius: borderRadius,
      );
    }
  }
}
