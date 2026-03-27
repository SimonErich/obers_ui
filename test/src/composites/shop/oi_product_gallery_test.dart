// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/composites/shop/oi_product_gallery.dart';

import '../../../helpers/pump_app.dart';

const _images = [
  'https://example.com/img1.jpg',
  'https://example.com/img2.jpg',
  'https://example.com/img3.jpg',
];

/// Suppresses [FlutterErrorDetails] whose exception is an image-load error.
FlutterExceptionHandler? _originalOnError;

void _ignoreImageErrors() {
  _originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('NetworkImageLoadException') ||
        details.library == 'image resource service') {
      return; // swallow image errors
    }
    _originalOnError?.call(details);
  };
}

void _restoreOnError() {
  FlutterError.onError = _originalOnError;
  _originalOnError = null;
}

/// Helper to pump a gallery in a small surface to avoid layout overflow
/// from the AspectRatio(1) main image.
Future<void> _pumpGallery(WidgetTester tester, Widget gallery) async {
  await tester.pumpObers(gallery, surfaceSize: const Size(400, 600));
}

void main() {
  group('OiProductGallery', () {
    testWidgets('renders main image from first URL', (tester) async {
      _ignoreImageErrors();
      addTearDown(_restoreOnError);
      await _pumpGallery(
        tester,
        const OiProductGallery(imageUrls: _images, label: 'Product gallery'),
      );

      // Should find OiImage widgets (main + thumbnails).
      expect(find.byType(OiImage), findsWidgets);
    });

    testWidgets('renders placeholder when image list is empty', (tester) async {
      await _pumpGallery(
        tester,
        const OiProductGallery(imageUrls: [], label: 'Product gallery'),
      );

      // No OiImage rendered, placeholder icon shown instead.
      expect(find.byType(OiImage), findsNothing);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('tapping thumbnail changes selected index', (tester) async {
      _ignoreImageErrors();
      addTearDown(_restoreOnError);
      int? changedIndex;
      await _pumpGallery(
        tester,
        OiProductGallery(
          imageUrls: _images,
          label: 'Product gallery',
          onIndexChanged: (i) => changedIndex = i,
        ),
      );

      // Find all OiImage widgets. The first is the main image,
      // the rest are thumbnails.
      final images = find.byType(OiImage);
      // Tap the third thumbnail (index 2 in the thumbnail strip).
      // Main image is first, then thumbnails follow.
      await tester.tap(images.at(3));
      await tester.pump();
      expect(changedIndex, 2);
    });

    testWidgets('hides thumbnails when showThumbnails is false', (
      tester,
    ) async {
      _ignoreImageErrors();
      addTearDown(_restoreOnError);
      await _pumpGallery(
        tester,
        const OiProductGallery(
          imageUrls: _images,
          label: 'Product gallery',
          showThumbnails: false,
        ),
      );

      // Only the main image, no thumbnails.
      expect(find.byType(OiImage), findsOneWidget);
    });

    testWidgets('hides thumbnails when single image', (tester) async {
      _ignoreImageErrors();
      addTearDown(_restoreOnError);
      await _pumpGallery(
        tester,
        const OiProductGallery(
          imageUrls: ['https://example.com/solo.jpg'],
          label: 'Product gallery',
        ),
      );

      // Only the main image, no thumbnail strip.
      expect(find.byType(OiImage), findsOneWidget);
    });

    testWidgets('respects initialIndex', (tester) async {
      _ignoreImageErrors();
      addTearDown(_restoreOnError);
      await _pumpGallery(
        tester,
        const OiProductGallery(
          imageUrls: _images,
          label: 'Product gallery',
          initialIndex: 2,
        ),
      );

      // Gallery renders without error at index 2.
      expect(find.byType(OiProductGallery), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      _ignoreImageErrors();
      addTearDown(_restoreOnError);
      await _pumpGallery(
        tester,
        const OiProductGallery(
          imageUrls: _images,
          label: 'Gallery for Widget X',
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Gallery for Widget X',
        ),
        findsOneWidget,
      );
    });
  });
}
