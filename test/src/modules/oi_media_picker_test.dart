// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/modules/oi_media_picker.dart';

import '../../helpers/pump_app.dart';

List<OiMediaItem> _sampleItems({int count = 6}) {
  return List.generate(
    count,
    (i) => OiMediaItem(
      key: 'item-$i',
      name: 'Photo $i.jpg',
      sizeBytes: (i + 1) * 1024 * 512,
    ),
  );
}

Widget _wrap(Widget child) {
  return SizedBox(width: 800, height: 600, child: child);
}

void main() {
  testWidgets('renders gallery items', (tester) async {
    final items = _sampleItems(count: 3);

    await tester.pumpObers(
      _wrap(OiMediaPicker(label: 'Media Picker', galleryItems: items)),
      surfaceSize: const Size(800, 600),
    );

    // Each item renders its name in the placeholder.
    expect(find.text('Photo 0.jpg'), findsOneWidget);
    expect(find.text('Photo 1.jpg'), findsOneWidget);
    expect(find.text('Photo 2.jpg'), findsOneWidget);
  });

  testWidgets('tapping gallery item selects it', (tester) async {
    final items = _sampleItems(count: 3);
    List<OiMediaItem>? selected;

    await tester.pumpObers(
      _wrap(
        OiMediaPicker(
          label: 'Media Picker',
          galleryItems: items,
          onSelect: (s) => selected = s,
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    // Tap the first gallery item.
    await tester.tap(find.text('Photo 0.jpg'));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.length, 1);
    expect(selected!.first.key, 'item-0');
  });

  testWidgets('selection strip shows selected items', (tester) async {
    final items = _sampleItems(count: 3);

    await tester.pumpObers(
      _wrap(
        OiMediaPicker(
          label: 'Media Picker',
          galleryItems: items,
          selected: [items[0], items[1]],
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    // Selection count label shows.
    expect(find.text('2/10 selected'), findsOneWidget);
  });

  testWidgets('remove button deselects item', (tester) async {
    final items = _sampleItems(count: 3);

    await tester.pumpObers(
      _wrap(
        OiMediaPicker(
          label: 'Media Picker',
          galleryItems: items,
          onSelect: (_) {},
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    // Select the first item by tapping it in the gallery.
    await tester.tap(find.text('Photo 0.jpg'));
    await tester.pumpAndSettle();

    // The selection strip should be visible with the selected item count.
    expect(find.text('1/10 selected'), findsOneWidget);

    // Tap the gallery item again to toggle-deselect it.
    await tester.tap(find.text('Photo 0.jpg'));
    await tester.pumpAndSettle();

    // The selection strip should disappear since nothing is selected.
    expect(find.text('1/10 selected'), findsNothing);
  });

  testWidgets('max items limit prevents over-selection', (tester) async {
    final items = _sampleItems(count: 4);
    List<OiMediaItem>? lastSelected;

    await tester.pumpObers(
      _wrap(
        OiMediaPicker(
          label: 'Media Picker',
          galleryItems: items,
          maxItems: 2,
          onSelect: (s) => lastSelected = s,
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    // Select first two items.
    await tester.tap(find.text('Photo 0.jpg'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Photo 1.jpg'));
    await tester.pumpAndSettle();

    expect(lastSelected!.length, 2);

    // Try to select a third -- should be at max and disabled.
    await tester.tap(find.text('Photo 2.jpg'));
    await tester.pumpAndSettle();

    // Still only 2 selected.
    expect(lastSelected!.length, 2);
  });

  testWidgets('onSelect callback fires with correct items', (tester) async {
    final items = _sampleItems(count: 3);
    final selections = <List<OiMediaItem>>[];

    await tester.pumpObers(
      _wrap(
        OiMediaPicker(
          label: 'Media Picker',
          galleryItems: items,
          onSelect: selections.add,
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Photo 0.jpg'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Photo 2.jpg'));
    await tester.pumpAndSettle();

    expect(selections.length, 2);
    expect(selections[0].map((i) => i.key).toList(), ['item-0']);
    expect(
      selections[1].map((i) => i.key).toList(),
      containsAll(['item-0', 'item-2']),
    );
  });

  testWidgets('files tab renders when source includes files', (tester) async {
    await tester.pumpObers(
      _wrap(
        const OiMediaPicker(
          label: 'Media Picker',
          sources: [OiMediaSource.files],
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Browse Files'), findsOneWidget);
    expect(find.text('or drag and drop files here'), findsOneWidget);
  });

  testWidgets('source tabs render when multiple sources', (tester) async {
    await tester.pumpObers(
      _wrap(const OiMediaPicker(label: 'Media Picker')),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Files'), findsOneWidget);
  });

  testWidgets('upload progress shows on items', (tester) async {
    final items = _sampleItems(count: 2);

    await tester.pumpObers(
      _wrap(
        OiMediaPicker(
          label: 'Media Picker',
          galleryItems: items,
          selected: [items[0]],
          uploadProgress: const [
            OiMediaUploadProgress(itemKey: 'item-0', progress: 0.5),
          ],
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    // An OiProgress widget should be rendered for the upload indicator.
    expect(find.byType(OiProgress), findsOneWidget);
  });

  testWidgets('empty gallery shows empty state', (tester) async {
    await tester.pumpObers(
      _wrap(
        const OiMediaPicker(
          label: 'Media Picker',
          sources: [OiMediaSource.gallery],
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.byType(OiEmptyState), findsOneWidget);
    expect(find.text('No media available'), findsOneWidget);
  });

  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(
      _wrap(
        const OiMediaPicker(
          label: 'Photo Picker',
          sources: [OiMediaSource.gallery],
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    // Verify the Semantics widget with the correct label exists.
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Photo Picker',
      ),
      findsOneWidget,
    );
  });

  testWidgets('load more button renders when moreGalleryAvailable', (
    tester,
  ) async {
    final items = _sampleItems(count: 3);

    await tester.pumpObers(
      _wrap(
        OiMediaPicker(
          label: 'Media Picker',
          galleryItems: items,
          moreGalleryAvailable: true,
          onLoadMoreGallery: () async {},
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Load more'), findsOneWidget);
  });
}
