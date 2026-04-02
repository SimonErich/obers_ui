import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
// OiFileData is hidden from the barrel; import directly for onUpload callback.
// ignore: implementation_imports
import 'package:obers_ui/src/modules/oi_chat.dart' show OiFileData;

import 'package:obers_ui_example/data/mock_cms.dart';

/// Media library screen with a grid of media file cards.
class CmsMediaScreen extends StatefulWidget {
  const CmsMediaScreen({super.key});

  @override
  State<CmsMediaScreen> createState() => _CmsMediaScreenState();
}

class _CmsMediaScreenState extends State<CmsMediaScreen> {
  List<Map<String, String>> _items = List.of(kMediaItems);
  OiOverlayHandle? _dialogHandle;

  @override
  void dispose() {
    _dialogHandle?.dismiss();
    super.dispose();
  }

  void _showUploadDialog() {
    _dialogHandle?.dismiss();
    _dialogHandle = OiDialog.show(
      context,
      label: 'Upload dialog',
      dialog: OiDialog.form(
        label: 'Upload dialog',
        content: OiUploadDialog(
          destinationPath: 'Media Library',
          onUpload: (files, _) {
            _dialogHandle?.dismiss();
            _dialogHandle = null;
            _addUploadedFiles(files);
          },
          onCancel: () {
            _dialogHandle?.dismiss();
            _dialogHandle = null;
          },
        ),
        onClose: () {
          _dialogHandle?.dismiss();
          _dialogHandle = null;
        },
      ),
    );
  }

  void _addUploadedFiles(List<OiFileData> files) {
    setState(() {
      for (final file in files) {
        final ext = OiFileUtils.extension(file.name).toLowerCase();
        String type;
        if (OiFileUtils.isImage(ext)) {
          type = 'image';
        } else if (OiFileUtils.isVideo(ext)) {
          type = 'video';
        } else {
          type = 'document';
        }
        _items = [
          ..._items,
          {
            'name': file.name,
            'type': type,
            'size': OiFileUtils.formatSize(file.size),
            'date':
                '${DateTime.now().year}-'
                '${DateTime.now().month.toString().padLeft(2, '0')}-'
                '${DateTime.now().day.toString().padLeft(2, '0')}',
          },
        ];
      }
    });
    OiToast.show(
      context,
      message: '${files.length} file${files.length == 1 ? '' : 's'} uploaded',
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
        return OiIcons.image;
      case 'video':
        return OiIcons.video;
      case 'document':
        return OiIcons.fileText;
      default:
        return OiIcons.file;
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
              OiTooltip(
                label: 'Upload files',
                message: 'Upload files',
                child: OiIconButton(
                  icon: OiIcons.cloudUpload,
                  semanticLabel: 'Upload media files',
                  size: OiButtonSize.large,
                  onTap: _showUploadDialog,
                ),
              ),
            ],
          ),
        ),

        // Grid or empty state
        Expanded(
          child: _items.isEmpty
              ? const OiEmptyState(
                  icon: OiIcons.image,
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
                        OiIcons.trash2,
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
