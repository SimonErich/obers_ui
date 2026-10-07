part of '../oi_toast.dart';

/// Renders the column of active toasts.
class _OiToastColumn extends StatelessWidget {
  const _OiToastColumn({required this.entries, required this.onEntryDismissed});

  final List<_OiToastEntry> entries;
  final void Function(_OiToastEntry) onEntryDismissed;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final position = entries.first.position;
    final isTop =
        position == OiToastPosition.topLeft ||
        position == OiToastPosition.topCenter ||
        position == OiToastPosition.topRight;

    final alignment = switch (position) {
      OiToastPosition.topLeft => Alignment.topLeft,
      OiToastPosition.topCenter => Alignment.topCenter,
      OiToastPosition.topRight => Alignment.topRight,
      OiToastPosition.bottomLeft => Alignment.bottomLeft,
      OiToastPosition.bottomCenter => Alignment.bottomCenter,
      OiToastPosition.bottomRight => Alignment.bottomRight,
    };

    final padding = isTop
        ? const EdgeInsets.only(top: 16, left: 16, right: 16)
        : const EdgeInsets.only(bottom: 16, left: 16, right: 16);

    final crossAlignment = switch (position) {
      OiToastPosition.topLeft ||
      OiToastPosition.bottomLeft => CrossAxisAlignment.start,
      OiToastPosition.topCenter ||
      OiToastPosition.bottomCenter => CrossAxisAlignment.center,
      OiToastPosition.topRight ||
      OiToastPosition.bottomRight => CrossAxisAlignment.end,
    };

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: SingleChildScrollView(
          primary: false,
          reverse: !isTop,
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAlignment,
            children: [
              for (final entry in entries) ...[
                OiToast(
                  key: ValueKey(entry),
                  label: entry.message,
                  message: entry.message,
                  level: entry.level,
                  position: entry.position,
                  duration: entry.duration,
                  pauseOnHover: entry.pauseOnHover,
                  dismissible: entry.dismissible,
                  dismissLabel: entry.dismissLabel,
                  action: entry.action,
                  onDismiss: () {
                    if (entry._isDismissed) return;
                    try {
                      entry.onDismiss?.call();
                    } finally {
                      onEntryDismissed(entry);
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
