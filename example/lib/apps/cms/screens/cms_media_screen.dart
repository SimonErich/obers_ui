import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_cms.dart';

/// Media library screen with a grid of media file cards.
class CmsMediaScreen extends StatefulWidget {
  const CmsMediaScreen({super.key});

  @override
  State<CmsMediaScreen> createState() => _CmsMediaScreenState();
}

class _CmsMediaScreenState extends State<CmsMediaScreen> {
  List<Map<String, String>> _items = List.of(kMediaItems);

  void _handleUpload() {
    // Simulate adding an uploaded file.
    setState(() {
      _items = [
        ..._items,
        {
          'name': 'upload-${_items.length + 1}.jpg',
          'type': 'image',
          'size': '1.2 MB',
          'date': '2026-03-22',
        },
      ];
    });
    OiToast.show(
      context,
      message: 'File uploaded successfully',
      level: OiToastLevel.success,
    );
  }

  void _handleDelete(int index) {
    final name = _items[index]['name'] ?? 'file';
    setState(() {
      _items = List.of(_items)..removeAt(index);
    });
    OiToast.show(
      context,
      message: '"$name" deleted',
      level: OiToastLevel.success,
    );
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'image':
        return OiIcons.photo;
      case 'video':
        return OiIcons.videoCamera;
      case 'document':
        return OiIcons.documentText;
      default:
        return OiIcons.document;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: Row(
            children: [
              const Expanded(child: OiLabel.h3('Media Library')),
              OiButton.primary(
                label: 'Upload',
                semanticLabel: 'Upload media file',
                icon: OiIcons.arrowUpTray,
                onTap: _handleUpload,
              ),
            ],
          ),
        ),

        // Grid or empty state
        Expanded(
          child: _items.isEmpty
              ? const OiEmptyState(
                  icon: OiIcons.photo,
                  title: 'No media files',
                  description:
                      'Upload images, videos, or documents to get started.',
                )
              : GridView.builder(
                  padding: EdgeInsets.all(spacing.md),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _MediaCard(
                      name: item['name'] ?? 'Untitled',
                      type: item['type'] ?? 'file',
                      size: item['size'] ?? '',
                      date: item['date'] ?? '',
                      icon: _iconForType(item['type']),
                      onDelete: () => _handleDelete(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MediaCard extends StatelessWidget {
  const _MediaCard({
    required this.name,
    required this.type,
    required this.size,
    required this.date,
    required this.icon,
    required this.onDelete,
  });

  final String name;
  final String type;
  final String size;
  final String date;
  final IconData icon;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Icon(icon, size: 36, color: colors.textMuted),
              ),
            ),
          ),

          // File info
          Padding(
            padding: EdgeInsets.all(spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OiLabel.body(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: OiLabel.caption(
                        '$size  \u2022  $date',
                        color: colors.textMuted,
                      ),
                    ),
                    OiTappable(
                      semanticLabel: 'Delete $name',
                      onTap: onDelete,
                      child: Icon(
                        OiIcons.trash,
                        size: 14,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
