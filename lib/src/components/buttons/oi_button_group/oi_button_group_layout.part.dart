part of '../oi_button_group.dart';

extension _OiButtonGroupLayout on _OiButtonGroupState {
  Widget _buildConnected(
    BuildContext context,
    int count,
    Axis direction,
    BorderRadius radius,
  ) {
    final dividerColor = context.colors.border;
    final children = <Widget>[];

    for (var i = 0; i < count; i++) {
      children.add(
        _buildItem(
          context,
          i,
          _connectedItemRadius(i, count, direction, radius),
        ),
      );
      if (i < count - 1) {
        // Divider between adjacent items.
        children.add(
          direction == Axis.horizontal
              ? Container(width: 1, color: dividerColor)
              : Container(height: 1, color: dividerColor),
        );
      }
    }

    final isWrapping = direction != widget.direction;
    final content = direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isWrapping
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.center,
            children: children,
          );

    return Focus(
      onKeyEvent: _onKeyEvent,
      child: OiSurface(
        color: const Color(0x00000000),
        border: OiBorderStyle.solid(
          context.colors.border,
          1,
          borderRadius: radius,
        ),
        borderRadius: radius,
        child: ClipRRect(borderRadius: radius, child: content),
      ),
    );
  }

  Widget _buildGapped(
    BuildContext context,
    int count,
    Axis direction,
    BorderRadius radius,
  ) {
    final gap = widget.spacing;
    final separated = <Widget>[];
    for (var i = 0; i < count; i++) {
      separated.add(_buildItem(context, i, radius));
      if (i < count - 1) {
        separated.add(
          direction == Axis.horizontal
              ? SizedBox(width: gap)
              : SizedBox(height: gap),
        );
      }
    }

    final isWrapping = direction != widget.direction;
    final Widget layout = direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: separated)
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isWrapping
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.center,
            children: separated,
          );

    return Focus(onKeyEvent: _onKeyEvent, child: layout);
  }
}
