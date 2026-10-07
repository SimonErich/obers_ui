part of '../oi_toast.dart';

class _OiToastGroups extends StatelessWidget {
  const _OiToastGroups({required this.entries, required this.onEntryDismissed});

  final List<_OiToastEntry> entries;
  final void Function(_OiToastEntry) onEntryDismissed;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final position in OiToastPosition.values)
          KeyedSubtree(
            key: ValueKey(position),
            child: _OiToastColumn(
              entries: entries
                  .where((entry) => entry.position == position)
                  .toList(),
              onEntryDismissed: onEntryDismissed,
            ),
          ),
      ],
    );
  }
}
