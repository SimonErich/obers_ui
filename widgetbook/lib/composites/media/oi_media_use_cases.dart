import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiMediaComponent = WidgetbookComponent(
  name: 'Media',
  useCases: [
    WidgetbookUseCase(
      name: 'OiLightbox',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 600,
            height: 500,
            child: OiLightbox(
              label: 'Image lightbox',
              items: const [
                OiLightboxItem(
                  src:
                      'https://placehold.co/800x600/EBF5FF/2563EB?text=Photo+1',
                  alt: 'Photo 1',
                  caption: 'A scenic view',
                ),
                OiLightboxItem(
                  src:
                      'https://placehold.co/800x600/FEF2F2/DC2626?text=Photo+2',
                  alt: 'Photo 2',
                  caption: 'Mountain landscape',
                ),
              ],
              initialIndex: 0,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiVideoPlayer',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 400,
            height: 260,
            child: OiVideoPlayer(
              src: 'https://example.com/sample.mp4',
              label: 'Sample video',
              posterUrl:
                  'https://placehold.co/400x225/1F2937/FFFFFF?text=Video',
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiImageCropper',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 400,
            height: 400,
            child: OiImageCropper(
              image: const NetworkImage(
                'https://placehold.co/400x400/EBF5FF/2563EB?text=Crop+Me',
              ),
              label: 'Image cropper',
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiImageAnnotator',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 400,
            height: 400,
            child: OiImageAnnotator(
              image: const NetworkImage(
                'https://placehold.co/400x400/F0FDF4/16A34A?text=Annotate',
              ),
              label: 'Image annotator',
            ),
          ),
        );
      },
    ),
  ],
);
