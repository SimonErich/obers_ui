import 'package:flutter/foundation.dart';
import 'package:obers_ui/obers_ui.dart' show OiFileNode;
import 'package:obers_ui/src/modules/oi_file_manager.dart' show OiFileNode;

/// A file or folder node with rich metadata for the file explorer.
///
/// This is the primary data model used by all file explorer components.
/// It replaces the simpler [OiFileNode] with full metadata support.
///
/// {@category Models}
@immutable
class OiFileNodeData {
  /// Creates an [OiFileNodeData].
  const OiFileNodeData({
    required this.id,
    required this.name,
    required this.folder,
    this.parentId,
    this.size,
    this.mimeType,
    this.extension,
    this.created,
    this.modified,
    this.thumbnailUrl,
    this.url,
    this.itemCount,
    this.metadata,
    this.favorite = false,
    this.shared = false,
    this.locked = false,
    this.trashed = false,
  });

  /// Unique identifier.
  final Object id;

  /// File or folder name including extension.
  final String name;

  /// Whether this node is a folder.
  final bool folder;

  /// Parent folder ID. Null for root.
  final String? parentId;

  /// File size in bytes. Null for folders (use [itemCount] instead).
  final int? size;

  /// MIME type (e.g., `"application/pdf"`). Null for folders.
  final String? mimeType;

  /// File extension without dot (e.g., `"pdf"`).
  /// Extracted from [name] if not provided.
  final String? extension;

  /// When this file was created.
  final DateTime? created;

  /// When this file was last modified.
  final DateTime? modified;

  /// URL to a thumbnail image (for image/video/document previews).
  final String? thumbnailUrl;

  /// URL to the actual file (for download or inline viewing).
  final String? url;

  /// Number of items inside (folders only).
  final int? itemCount;

  /// Arbitrary metadata (tags, owner, etc.).
  final Map<String, dynamic>? metadata;

  /// Whether this item is in the user's favorites.
  final bool favorite;

  /// Whether this item is shared with others.
  final bool shared;

  /// Whether this item is locked (read-only).
  final bool locked;

  /// Whether this item is in the trash.
  final bool trashed;

  /// Extracts the file extension from the name.
  String get resolvedExtension =>
      extension ??
      (folder
          ? ''
          : name.split('.').length > 1
          ? name.split('.').last
          : '');

  /// Extracts the name without extension.
  String get nameWithoutExtension {
    if (folder) return name;
    final parts = name.split('.');
    return parts.length > 1
        ? parts.sublist(0, parts.length - 1).join('.')
        : name;
  }

  /// Formatted size string.
  String get formattedSize {
    if (size == null) return '—';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) {
      return '${(size! / 1024).toStringAsFixed(1)} KB';
    }
    if (size! < 1024 * 1024 * 1024) {
      return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiFileNodeData copyWith({
    Object? id,
    String? name,
    bool? folder,
    String? parentId,
    int? size,
    String? mimeType,
    String? extension,
    DateTime? created,
    DateTime? modified,
    String? thumbnailUrl,
    String? url,
    int? itemCount,
    Map<String, dynamic>? metadata,
    bool? favorite,
    bool? shared,
    bool? locked,
    bool? trashed,
  }) {
    return OiFileNodeData(
      id: id ?? this.id,
      name: name ?? this.name,
      folder: folder ?? this.folder,
      parentId: parentId ?? this.parentId,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      extension: extension ?? this.extension,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      url: url ?? this.url,
      itemCount: itemCount ?? this.itemCount,
      metadata: metadata ?? this.metadata,
      favorite: favorite ?? this.favorite,
      shared: shared ?? this.shared,
      locked: locked ?? this.locked,
      trashed: trashed ?? this.trashed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiFileNodeData) return false;
    return id == other.id && name == other.name && folder == other.folder;
  }

  @override
  int get hashCode => Object.hash(id, name, folder);
}
