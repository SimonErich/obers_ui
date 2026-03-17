// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

void main() {
  group('OiFileUtils', () {
    group('extension', () {
      test('extracts extension from filename', () {
        expect(OiFileUtils.extension('document.pdf'), 'pdf');
      });

      test('extracts extension from path', () {
        expect(OiFileUtils.extension('/path/to/image.png'), 'png');
      });

      test('returns lowercase extension', () {
        expect(OiFileUtils.extension('Photo.JPG'), 'jpg');
      });

      test('returns empty for no extension', () {
        expect(OiFileUtils.extension('Makefile'), '');
      });

      test('returns last extension for multiple dots', () {
        expect(OiFileUtils.extension('archive.tar.gz'), 'gz');
      });

      test('returns empty for trailing dot', () {
        expect(OiFileUtils.extension('file.'), '');
      });

      test('handles Windows-style paths', () {
        expect(OiFileUtils.extension(r'C:\Users\file.txt'), 'txt');
      });
    });

    group('nameWithoutExtension', () {
      test('removes extension from filename', () {
        expect(OiFileUtils.nameWithoutExtension('document.pdf'), 'document');
      });

      test('removes extension from path', () {
        expect(OiFileUtils.nameWithoutExtension('/path/to/image.png'), 'image');
      });

      test('returns filename if no extension', () {
        expect(OiFileUtils.nameWithoutExtension('Makefile'), 'Makefile');
      });

      test('removes only last extension', () {
        expect(
          OiFileUtils.nameWithoutExtension('archive.tar.gz'),
          'archive.tar',
        );
      });
    });

    group('fileTypeName', () {
      test('returns PDF Document for pdf', () {
        expect(OiFileUtils.fileTypeName('pdf'), 'PDF Document');
      });

      test('returns Word Document for docx', () {
        expect(OiFileUtils.fileTypeName('docx'), 'Word Document');
      });

      test('returns PNG Image for png', () {
        expect(OiFileUtils.fileTypeName('png'), 'PNG Image');
      });

      test('returns MP4 Video for mp4', () {
        expect(OiFileUtils.fileTypeName('mp4'), 'MP4 Video');
      });

      test('handles dot prefix', () {
        expect(OiFileUtils.fileTypeName('.pdf'), 'PDF Document');
      });

      test('handles uppercase', () {
        expect(OiFileUtils.fileTypeName('PDF'), 'PDF Document');
      });

      test('returns fallback for unknown extension', () {
        expect(OiFileUtils.fileTypeName('xyz'), 'XYZ File');
      });
    });

    group('mimeType', () {
      test('returns correct MIME for pdf', () {
        expect(OiFileUtils.mimeType('pdf'), 'application/pdf');
      });

      test('returns correct MIME for png', () {
        expect(OiFileUtils.mimeType('png'), 'image/png');
      });

      test('returns correct MIME for mp4', () {
        expect(OiFileUtils.mimeType('mp4'), 'video/mp4');
      });

      test('returns correct MIME for mp3', () {
        expect(OiFileUtils.mimeType('mp3'), 'audio/mpeg');
      });

      test('returns correct MIME for json', () {
        expect(OiFileUtils.mimeType('json'), 'application/json');
      });

      test('returns octet-stream for unknown', () {
        expect(OiFileUtils.mimeType('xyz'), 'application/octet-stream');
      });

      test('handles dot prefix', () {
        expect(OiFileUtils.mimeType('.pdf'), 'application/pdf');
      });
    });

    group('isImage', () {
      test('recognizes png as image', () {
        expect(OiFileUtils.isImage('png'), isTrue);
      });

      test('recognizes jpg as image', () {
        expect(OiFileUtils.isImage('jpg'), isTrue);
      });

      test('recognizes jpeg as image', () {
        expect(OiFileUtils.isImage('jpeg'), isTrue);
      });

      test('recognizes gif as image', () {
        expect(OiFileUtils.isImage('gif'), isTrue);
      });

      test('recognizes svg as image', () {
        expect(OiFileUtils.isImage('svg'), isTrue);
      });

      test('recognizes webp as image', () {
        expect(OiFileUtils.isImage('webp'), isTrue);
      });

      test('does not recognize mp4 as image', () {
        expect(OiFileUtils.isImage('mp4'), isFalse);
      });

      test('does not recognize pdf as image', () {
        expect(OiFileUtils.isImage('pdf'), isFalse);
      });

      test('handles dot prefix', () {
        expect(OiFileUtils.isImage('.png'), isTrue);
      });
    });

    group('isVideo', () {
      test('recognizes mp4 as video', () {
        expect(OiFileUtils.isVideo('mp4'), isTrue);
      });

      test('recognizes avi as video', () {
        expect(OiFileUtils.isVideo('avi'), isTrue);
      });

      test('recognizes mov as video', () {
        expect(OiFileUtils.isVideo('mov'), isTrue);
      });

      test('recognizes mkv as video', () {
        expect(OiFileUtils.isVideo('mkv'), isTrue);
      });

      test('does not recognize mp3 as video', () {
        expect(OiFileUtils.isVideo('mp3'), isFalse);
      });

      test('does not recognize png as video', () {
        expect(OiFileUtils.isVideo('png'), isFalse);
      });
    });

    group('isAudio', () {
      test('recognizes mp3 as audio', () {
        expect(OiFileUtils.isAudio('mp3'), isTrue);
      });

      test('recognizes wav as audio', () {
        expect(OiFileUtils.isAudio('wav'), isTrue);
      });

      test('recognizes flac as audio', () {
        expect(OiFileUtils.isAudio('flac'), isTrue);
      });

      test('recognizes ogg as audio', () {
        expect(OiFileUtils.isAudio('ogg'), isTrue);
      });

      test('does not recognize mp4 as audio', () {
        expect(OiFileUtils.isAudio('mp4'), isFalse);
      });

      test('does not recognize png as audio', () {
        expect(OiFileUtils.isAudio('png'), isFalse);
      });
    });

    group('isDocument', () {
      test('recognizes pdf as document', () {
        expect(OiFileUtils.isDocument('pdf'), isTrue);
      });

      test('recognizes docx as document', () {
        expect(OiFileUtils.isDocument('docx'), isTrue);
      });

      test('recognizes xlsx as document', () {
        expect(OiFileUtils.isDocument('xlsx'), isTrue);
      });

      test('recognizes txt as document', () {
        expect(OiFileUtils.isDocument('txt'), isTrue);
      });

      test('recognizes csv as document', () {
        expect(OiFileUtils.isDocument('csv'), isTrue);
      });

      test('does not recognize png as document', () {
        expect(OiFileUtils.isDocument('png'), isFalse);
      });

      test('does not recognize mp4 as document', () {
        expect(OiFileUtils.isDocument('mp4'), isFalse);
      });
    });

    group('iconForExtension', () {
      test('returns image icon for png', () {
        expect(OiFileUtils.iconForExtension('png'), Icons.image);
      });

      test('returns video icon for mp4', () {
        expect(OiFileUtils.iconForExtension('mp4'), Icons.video_file);
      });

      test('returns audio icon for mp3', () {
        expect(OiFileUtils.iconForExtension('mp3'), Icons.audio_file);
      });

      test('returns pdf icon for pdf', () {
        expect(OiFileUtils.iconForExtension('pdf'), Icons.picture_as_pdf);
      });

      test('returns description icon for docx', () {
        expect(OiFileUtils.iconForExtension('docx'), Icons.description);
      });

      test('returns table icon for xlsx', () {
        expect(OiFileUtils.iconForExtension('xlsx'), Icons.table_chart);
      });

      test('returns slideshow icon for pptx', () {
        expect(OiFileUtils.iconForExtension('pptx'), Icons.slideshow);
      });

      test('returns zip icon for zip', () {
        expect(OiFileUtils.iconForExtension('zip'), Icons.folder_zip);
      });

      test('returns code icon for dart', () {
        expect(OiFileUtils.iconForExtension('dart'), Icons.code);
      });

      test('returns data icon for json', () {
        expect(OiFileUtils.iconForExtension('json'), Icons.data_object);
      });

      test('returns text icon for txt', () {
        expect(OiFileUtils.iconForExtension('txt'), Icons.text_snippet);
      });

      test('returns generic icon for unknown extension', () {
        expect(OiFileUtils.iconForExtension('xyz'), Icons.insert_drive_file);
      });
    });

    group('formatSize', () {
      test('formats bytes', () {
        expect(OiFileUtils.formatSize(500), '500 B');
      });

      test('formats kilobytes', () {
        expect(OiFileUtils.formatSize(1024), '1.0 KB');
      });

      test('formats megabytes', () {
        expect(OiFileUtils.formatSize(1048576), '1.0 MB');
      });

      test('formats gigabytes', () {
        expect(OiFileUtils.formatSize(1073741824), '1.0 GB');
      });

      test('formats with custom decimals', () {
        expect(OiFileUtils.formatSize(1536, decimals: 2), '1.50 KB');
      });

      test('formats zero bytes', () {
        expect(OiFileUtils.formatSize(0), '0 B');
      });

      test('handles negative bytes', () {
        expect(OiFileUtils.formatSize(-1), '0 B');
      });
    });
  });
}
