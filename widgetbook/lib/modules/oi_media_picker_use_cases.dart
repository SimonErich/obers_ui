import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleItems = List.generate(
  8,
  (i) => OiMediaItem(
    key: 'img-$i',
    name: 'Photo ${i + 1}.jpg',
    sizeBytes: (i + 1) * 512 * 1024,
    thumbnail: Container(
      color: Color.lerp(
        const Color(0xFF5BA4CF),
        const Color(0xFFE8C84A),
        i / 7,
      ),
      child: const Center(
        child: Icon(OiIcons.image, size: 32, color: Color(0xFFFFFFFF)),
      ),
    ),
  ),
);

final oiMediaPickerComponent = WidgetbookComponent(
  name: 'OiMediaPicker',
  useCases: [
    WidgetbookUseCase(
      name: 'Gallery',
      builder: (context) {
        final maxItems = context.knobs.int.slider(
          label: 'Max Items',
          initialValue: 5,
          min: 1,
          max: 8,
        );

        return useCaseWrapper(
          SizedBox(
            width: 500,
            height: 500,
            child: OiMediaPicker(
              label: 'Media Picker',
              galleryItems: _sampleItems,
              maxItems: maxItems,
              moreGalleryAvailable: true,
              onSelect: (_) {},
              onRemove: (_) {},
              onLoadMoreGallery: () async {},
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'With Upload Progress',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 500,
            height: 500,
            child: OiMediaPicker(
              label: 'Media Picker with Upload',
              galleryItems: _sampleItems,
              selected: [_sampleItems[0], _sampleItems[2], _sampleItems[4]],
              uploadProgress: const [
                OiMediaUploadProgress(itemKey: 'img-0', progress: 0.75),
                OiMediaUploadProgress(itemKey: 'img-2', progress: 0.3),
                OiMediaUploadProgress(
                  itemKey: 'img-4',
                  progress: 0,
                  error: 'Upload failed',
                ),
              ],
              onSelect: (_) {},
              onRemove: (_) {},
            ),
          ),
        );
      },
    ),
  ],
);
