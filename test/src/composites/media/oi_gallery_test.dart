// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/media/oi_gallery.dart';

import '../../../helpers/pump_app.dart';

// ── Image error suppression ──────────────────────────────────────────────────

FlutterExceptionHandler? _originalOnError;

void _ignoreImageErrors() {
  _originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('NetworkImageLoadException') ||
        details.exception.toString().contains('Unable to load asset') ||
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

// ── Helpers ───────────────────────────────────────────────────────────────────

final _items = [
  const OiGalleryItem(key: 'a', src: 'https://example.com/a.png', alt: 'Image A'),
  const OiGalleryItem(key: 'b', src: 'https://example.com/b.png', alt: 'Image B'),
  const OiGalleryItem(
    key: 'c',
    src: 'https://example.com/c.png',
    alt: 'Image C',
    thumbnailUrl: 'https://example.com/c_thumb.png',
  ),
  const OiGalleryItem(key: 'd', src: 'https://example.com/d.png', alt: 'Image D'),
];

Widget _gallery({
  List<OiGalleryItem>? items,
  int columns = 4,
  OiSelectionMode selectionMode = OiSelectionMode.none,
  Set<Object> selectedKeys = const {},
  ValueChanged<Set<Object>>? onSelectionChange,
  ValueChanged<OiGalleryItem>? onItemTap,
  bool showUpload = false,
  ValueChanged<List<Object>>? onUpload,
  double gap = 8,
}) {
  return SizedBox(
    width: 800,
    height: 600,
    child: OiGallery(
      items: items ?? _items,
      label: 'Test gallery',
      columns: columns,
      selectionMode: selectionMode,
      selectedKeys: selectedKeys,
      onSelectionChange: onSelectionChange,
      onItemTap: onItemTap,
      showUpload: showUpload,
      onUpload: onUpload,
      gap: gap,
    ),
  );
}

void main() {
  group('OiGallery', () {
    setUp(_ignoreImageErrors);
    tearDown(_restoreOnError);

    testWidgets('renders the gallery grid', (tester) async {
      await tester.pumpObers(
        _gallery(),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_gallery')), findsOneWidget);
    });

    testWidgets('renders correct number of items', (tester) async {
      await tester.pumpObers(
        _gallery(),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      for (final item in _items) {
        expect(
          find.byKey(ValueKey('oi_gallery_item_${item.key}')),
          findsOneWidget,
        );
      }
    });

    testWidgets('uses specified number of columns', (tester) async {
      await tester.pumpObers(
        _gallery(columns: 2),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // The GridView should be rendered using the delegate's crossAxisCount.
      final gridView = tester.widget<GridView>(find.byKey(const Key('oi_gallery')));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
    });

    testWidgets('onItemTap fires when item is tapped', (tester) async {
      OiGalleryItem? tappedItem;
      await tester.pumpObers(
        _gallery(onItemTap: (item) => tappedItem = item),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('oi_gallery_item_a')));
      await tester.pump();

      expect(tappedItem, isNotNull);
      expect(tappedItem!.key, 'a');
    });

    testWidgets('single selection mode toggles selection', (tester) async {
      Set<Object>? selection;
      await tester.pumpObers(
        _gallery(
          selectionMode: OiSelectionMode.single,
          onSelectionChange: (s) => selection = s,
          onItemTap: (_) {},
        ),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // Tap first item to select.
      await tester.tap(find.byKey(const ValueKey('oi_gallery_item_a')));
      await tester.pump();

      expect(selection, equals({'a'}));
    });

    testWidgets('single selection replaces previous selection', (tester) async {
      Set<Object>? selection;
      await tester.pumpObers(
        _gallery(
          selectionMode: OiSelectionMode.single,
          selectedKeys: const {'a'},
          onSelectionChange: (s) => selection = s,
          onItemTap: (_) {},
        ),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // Tap second item — should replace 'a' with 'b'.
      await tester.tap(find.byKey(const ValueKey('oi_gallery_item_b')));
      await tester.pump();

      expect(selection, equals({'b'}));
    });

    testWidgets('multi selection adds items', (tester) async {
      Set<Object>? selection;
      await tester.pumpObers(
        _gallery(
          selectionMode: OiSelectionMode.multi,
          selectedKeys: const {'a'},
          onSelectionChange: (s) => selection = s,
          onItemTap: (_) {},
        ),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // Tap second item — should add 'b' to selection.
      await tester.tap(find.byKey(const ValueKey('oi_gallery_item_b')));
      await tester.pump();

      expect(selection, equals({'a', 'b'}));
    });

    testWidgets('multi selection removes already-selected items',
        (tester) async {
      Set<Object>? selection;
      await tester.pumpObers(
        _gallery(
          selectionMode: OiSelectionMode.multi,
          selectedKeys: const {'a', 'b'},
          onSelectionChange: (s) => selection = s,
          onItemTap: (_) {},
        ),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // Tap already-selected item 'a' to deselect.
      await tester.tap(find.byKey(const ValueKey('oi_gallery_item_a')));
      await tester.pump();

      expect(selection, equals({'b'}));
    });

    testWidgets('empty gallery renders gracefully', (tester) async {
      await tester.pumpObers(
        _gallery(items: const []),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_gallery_empty')), findsOneWidget);
      expect(find.byKey(const Key('oi_gallery')), findsNothing);
    });

    testWidgets('upload tile is shown when showUpload is true',
        (tester) async {
      await tester.pumpObers(
        _gallery(showUpload: true),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_gallery_upload')), findsOneWidget);
    });

    testWidgets('upload tile calls onUpload when tapped', (tester) async {
      var uploadCalled = false;
      await tester.pumpObers(
        _gallery(
          showUpload: true,
          onUpload: (_) => uploadCalled = true,
        ),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_gallery_upload')));
      await tester.pump();

      expect(uploadCalled, isTrue);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        _gallery(),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(find.bySemanticsLabel('Test gallery'), findsOneWidget);
    });

    testWidgets('empty gallery with showUpload still renders grid',
        (tester) async {
      await tester.pumpObers(
        _gallery(items: const [], showUpload: true),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_gallery')), findsOneWidget);
      expect(find.byKey(const Key('oi_gallery_upload')), findsOneWidget);
    });
  });

  group('OiSelectionMode', () {
    test('has expected values', () {
      expect(OiSelectionMode.values.length, 3);
      expect(OiSelectionMode.none, isNotNull);
      expect(OiSelectionMode.single, isNotNull);
      expect(OiSelectionMode.multi, isNotNull);
    });
  });
}
