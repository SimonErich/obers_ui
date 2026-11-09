part of '../oi_button.dart';

class _OiButtonLabel extends StatelessWidget {
  const _OiButtonLabel({
    required this.state,
    required this.label,
    required this.foreground,
    this.singleLine = true,
  });
  final _OiButtonState state;
  final String label;
  final Color foreground;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    return OiLabel.body(
      label,
      style: state._labelStyle(context, foreground),
      maxLines: singleLine ? state.widget.labelMaxLines : null,
      overflow: singleLine ? TextOverflow.ellipsis : null,
    );
  }
}
