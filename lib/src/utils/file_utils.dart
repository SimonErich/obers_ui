import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

/// Utility class for file-related operations.
///
/// Provides static methods for working with file names, extensions, MIME
/// types, and file type classification.
///
/// {@category Utils}
class OiFileUtils {
  const OiFileUtils._();

  /// Returns the file extension from a [filename] or path (without dot).
  ///
  /// Returns an empty string if no extension is found.
  static String extension(String filename) {
    final name = filename.split('/').last.split(r'\').last;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  /// Returns the [filename] without its extension.
  ///
  /// If there is no extension, returns the original filename.
  static String nameWithoutExtension(String filename) {
    final name = filename.split('/').last.split(r'\').last;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0) return name;
    return name.substring(0, dotIndex);
  }

  /// Returns a human-readable file type name from [ext].
  ///
  /// Falls back to the uppercase extension if not recognized.
  static String fileTypeName(String ext) {
    final normalized = ext.toLowerCase().replaceFirst('.', '');
    const names = {
      'pdf': 'PDF Document',
      'doc': 'Word Document',
      'docx': 'Word Document',
      'xls': 'Excel Spreadsheet',
      'xlsx': 'Excel Spreadsheet',
      'ppt': 'PowerPoint Presentation',
      'pptx': 'PowerPoint Presentation',
      'txt': 'Text File',
      'csv': 'CSV File',
      'json': 'JSON File',
      'xml': 'XML File',
      'html': 'HTML File',
      'css': 'CSS File',
      'js': 'JavaScript File',
      'ts': 'TypeScript File',
      'dart': 'Dart File',
      'py': 'Python File',
      'rb': 'Ruby File',
      'java': 'Java File',
      'kt': 'Kotlin File',
      'swift': 'Swift File',
      'go': 'Go File',
      'rs': 'Rust File',
      'c': 'C File',
      'cpp': 'C++ File',
      'h': 'Header File',
      'md': 'Markdown File',
      'yaml': 'YAML File',
      'yml': 'YAML File',
      'zip': 'ZIP Archive',
      'rar': 'RAR Archive',
      'tar': 'TAR Archive',
      'gz': 'GZip Archive',
      '7z': '7-Zip Archive',
      'png': 'PNG Image',
      'jpg': 'JPEG Image',
      'jpeg': 'JPEG Image',
      'gif': 'GIF Image',
      'svg': 'SVG Image',
      'webp': 'WebP Image',
      'bmp': 'Bitmap Image',
      'ico': 'Icon File',
      'mp4': 'MP4 Video',
      'avi': 'AVI Video',
      'mov': 'QuickTime Video',
      'wmv': 'WMV Video',
      'mkv': 'MKV Video',
      'webm': 'WebM Video',
      'mp3': 'MP3 Audio',
      'wav': 'WAV Audio',
      'flac': 'FLAC Audio',
      'aac': 'AAC Audio',
      'ogg': 'OGG Audio',
      'wma': 'WMA Audio',
    };
    return names[normalized] ?? '${normalized.toUpperCase()} File';
  }

  /// Returns the MIME type for a file [ext].
  ///
  /// Falls back to `'application/octet-stream'` if not recognized.
  static String mimeType(String ext) {
    final normalized = ext.toLowerCase().replaceFirst('.', '');
    const mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'json': 'application/json',
      'xml': 'application/xml',
      'html': 'text/html',
      'css': 'text/css',
      'js': 'application/javascript',
      'zip': 'application/zip',
      'rar': 'application/vnd.rar',
      'tar': 'application/x-tar',
      'gz': 'application/gzip',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'gif': 'image/gif',
      'svg': 'image/svg+xml',
      'webp': 'image/webp',
      'bmp': 'image/bmp',
      'ico': 'image/x-icon',
      'mp4': 'video/mp4',
      'avi': 'video/x-msvideo',
      'mov': 'video/quicktime',
      'wmv': 'video/x-ms-wmv',
      'mkv': 'video/x-matroska',
      'webm': 'video/webm',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'flac': 'audio/flac',
      'aac': 'audio/aac',
      'ogg': 'audio/ogg',
      'wma': 'audio/x-ms-wma',
    };
    return mimeTypes[normalized] ?? 'application/octet-stream';
  }

  /// Returns whether a file [ext] represents an image.
  static bool isImage(String ext) {
    final normalized = ext.toLowerCase().replaceFirst('.', '');
    return const {
      'png',
      'jpg',
      'jpeg',
      'gif',
      'svg',
      'webp',
      'bmp',
      'ico',
      'tiff',
      'tif',
    }.contains(normalized);
  }

  /// Returns whether a file [ext] represents a video.
  static bool isVideo(String ext) {
    final normalized = ext.toLowerCase().replaceFirst('.', '');
    return const {
      'mp4',
      'avi',
      'mov',
      'wmv',
      'mkv',
      'webm',
      'flv',
      'm4v',
    }.contains(normalized);
  }

  /// Returns whether a file [ext] represents an audio file.
  static bool isAudio(String ext) {
    final normalized = ext.toLowerCase().replaceFirst('.', '');
    return const {
      'mp3',
      'wav',
      'flac',
      'aac',
      'ogg',
      'wma',
      'm4a',
    }.contains(normalized);
  }

  /// Returns whether a file [ext] represents a document.
  static bool isDocument(String ext) {
    final normalized = ext.toLowerCase().replaceFirst('.', '');
    return const {
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
      'csv',
      'rtf',
      'odt',
      'ods',
      'odp',
    }.contains(normalized);
  }

  /// Returns an appropriate [IconData] for a file [ext].
  ///
  /// Uses Material Design icons. Falls back to a generic file icon.
  static IconData iconForExtension(String ext) {
    final normalized = ext.toLowerCase().replaceFirst('.', '');

    if (isImage(normalized)) return OiIcons.image;
    if (isVideo(normalized)) return OiIcons.video;
    if (isAudio(normalized)) return OiIcons.music;

    return switch (normalized) {
      'pdf' => OiIcons.fileText,
      'doc' || 'docx' || 'odt' || 'rtf' => OiIcons.fileText,
      'xls' || 'xlsx' || 'ods' || 'csv' => OiIcons.table,
      'ppt' || 'pptx' || 'odp' => OiIcons.presentation,
      'zip' || 'rar' || 'tar' || 'gz' || '7z' => OiIcons.archive,
      'html' ||
      'css' ||
      'js' ||
      'ts' ||
      'dart' ||
      'py' ||
      'java' ||
      'kt' ||
      'swift' ||
      'go' ||
      'rs' ||
      'c' ||
      'cpp' ||
      'rb' => OiIcons.code,
      'json' || 'xml' || 'yaml' || 'yml' => OiIcons.database,
      'txt' || 'md' => OiIcons.fileText,
      _ => OiIcons.file,
    };
  }

  /// Formats a file size in [bytes] to human-readable string.
  ///
  /// Uses binary prefixes (1 KB = 1024 bytes).
  /// [decimals] controls how many decimal places to show (default 1).
  static String formatSize(int bytes, {int decimals = 1}) {
    if (bytes < 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    var value = bytes.toDouble();
    var unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) return '$bytes B';
    return '${value.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }

  /// Characters that are illegal in file and folder names across platforms.
  ///
  /// Includes `/`, `\`, `:`, `*`, `?`, `"`, `<`, `>`, and `|`.
  static const illegalNameChars = <String>[
    '/',
    r'\',
    ':',
    '*',
    '?',
    '"',
    '<',
    '>',
    '|',
  ];
}
