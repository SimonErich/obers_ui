// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

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

void main() {
  group('OiProductGallery', () {
    testWidgets('renders main image from first URL', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 400,
          height: 600,
          child: OiProductGallery(imageUrls: _images, label: 'Product gallery'),
        ),
      );

      // Should find OiImage widgets (main + thumbnails).
      expect(find.byType(OiImage), findsWidgets);
    });

    testWidgets('renders placeholder when image list is empty', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 400,
          height: 600,
          child: OiProductGallery(imageUrls: [], label: 'Product gallery'),
        ),
      );

      // No OiImage rendered, placeholder icon shown instead.
      expect(find.byType(OiImage), findsNothing);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('tapping thumbnail changes selected index', (tester) async {
      int? changedIndex;
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiProductGallery(
            imageUrls: _images,
            label: 'Product gallery',
            onIndexChanged: (i) => changedIndex = i,
          ),
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
      await tester.pumpObers(
        const SizedBox(
          width: 400,
          height: 600,
          child: OiProductGallery(
            imageUrls: _images,
            label: 'Product gallery',
            showThumbnails: false,
          ),
        ),
      );

      // Only the main image, no thumbnails.
      expect(find.byType(OiImage), findsOneWidget);
    });

    testWidgets('hides thumbnails when single image', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 400,
          height: 600,
          child: OiProductGallery(
            imageUrls: ['https://example.com/solo.jpg'],
            label: 'Product gallery',
          ),
        ),
      );

      // Only the main image, no thumbnail strip.
      expect(find.byType(OiImage), findsOneWidget);
    });

    testWidgets('respects initialIndex', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 400,
          height: 600,
          child: OiProductGallery(
            imageUrls: _images,
            label: 'Product gallery',
            initialIndex: 2,
          ),
        ),
      );

      // Gallery renders without error at index 2.
      expect(find.byType(OiProductGallery), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 400,
          height: 600,
          child: OiProductGallery(
            imageUrls: _images,
            label: 'Gallery for Widget X',
          ),
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
