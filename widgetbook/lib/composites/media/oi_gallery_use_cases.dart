import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

const _sampleItems = [
  OiGalleryItem(
    key: 'img1',
    src: 'https://placehold.co/300x200/EBF5FF/2563EB?text=Image+1',
    alt: 'Placeholder image 1',
  ),
  OiGalleryItem(
    key: 'img2',
    src: 'https://placehold.co/300x200/FEF2F2/DC2626?text=Image+2',
    alt: 'Placeholder image 2',
  ),
  OiGalleryItem(
    key: 'img3',
    src: 'https://placehold.co/300x200/F0FDF4/16A34A?text=Image+3',
    alt: 'Placeholder image 3',
  ),
  OiGalleryItem(
    key: 'img4',
    src: 'https://placehold.co/300x200/FFF7ED/EA580C?text=Image+4',
    alt: 'Placeholder image 4',
  ),
];

final oiGalleryComponent = WidgetbookComponent(
  name: 'OiGallery',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return const SizedBox(
          height: 400,
          child: OiGallery(
            label: 'Image gallery',
            items: _sampleItems,
            columns: 2,
          ),
        );
      },
    ),
  ],
);
