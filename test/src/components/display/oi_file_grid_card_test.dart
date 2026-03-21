// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_file_grid_card.dart';
import 'package:obers_ui/src/modules/oi_file_manager.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

OiFileNode _file({
  Object key = 'f1',
  String name = 'readme.txt',
  int? size = 1024,
}) {
  return OiFileNode(key: key, name: name, folder: false, size: size);
}

OiFileNode _folder({Object key = 'd1', String name = 'Documents'}) {
  return OiFileNode(key: key, name: name, folder: true);
}

Widget _card({
  OiFileNode? file,
  bool selected = false,
  VoidCallback? onTap,
  VoidCallback? onDoubleTap,
  String? searchQuery,
}) {
  return SizedBox(
    width: 140,
    height: 160,
    child: OiFileGridCard(
      file: file ?? _file(),
      selected: selected,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      searchQuery: searchQuery,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── Core rendering ──────────────────────────────────────────────────────

  group('Core rendering', () {
    testWidgets('renders file name', (tester) async {
      await tester.pumpObers(_card(file: _file(name: 'image.png')));
      expect(find.text('image.png'), findsOneWidget);
    });

    testWidgets('renders folder name', (tester) async {
      await tester.pumpObers(_card(file: _folder(name: 'Photos')));
      expect(find.text('Photos'), findsOneWidget);
    });

    testWidgets('renders folder icon for folders', (tester) async {
      await tester.pumpObers(_card(file: _folder()));
      expect(
        find.byIcon(const IconData(0xe2c7, fontFamily: 'MaterialIcons')),
        findsOneWidget,
      );
    });

    testWidgets('renders file icon for files', (tester) async {
      await tester.pumpObers(_card(file: _file()));
      expect(
        find.byIcon(const IconData(0xe24d, fontFamily: 'MaterialIcons')),
        findsOneWidget,
      );
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpObers(_card(file: _file(name: 'data.csv')));
      expect(find.bySemanticsLabel('data.csv'), findsOneWidget);
    });
  });

  // ── Interaction ─────────────────────────────────────────────────────────

  group('Interaction', () {
    testWidgets('onTap fires when tapped', (tester) async {
      var tapped = false;
      await tester.pumpObers(_card(onTap: () => tapped = true));

      await tester.tap(find.byType(OiFileGridCard));
      expect(tapped, isTrue);
    });

    testWidgets('onDoubleTap fires on double-tap', (tester) async {
      var doubleTapped = false;
      await tester.pumpObers(_card(onDoubleTap: () => doubleTapped = true));

      await tester.tap(find.byType(OiFileGridCard));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(OiFileGridCard));
      await tester.pumpAndSettle();

      expect(doubleTapped, isTrue);
    });
  });

  // ── Search highlight (REQ-0991) ─────────────────────────────────────────

  group('Search highlight (REQ-0991)', () {
    testWidgets('no highlight when searchQuery is null', (tester) async {
      await tester.pumpObers(_card(file: _file(name: 'photo.jpg')));

      expect(find.text('photo.jpg'), findsOneWidget);
    });

    testWidgets('highlights matching portion of file name', (tester) async {
      await tester.pumpObers(
        _card(
          file: _file(name: 'photo.jpg'),
          searchQuery: 'hot',
        ),
      );

      final richText = tester.widget<RichText>(find.byType(RichText).at(1));
      final span = richText.text as TextSpan;

      // "p", "hot", "o.jpg"
      expect(span.children, hasLength(3));

      final before = span.children![0] as TextSpan;
      final match = span.children![1] as TextSpan;
      final after = span.children![2] as TextSpan;

      expect(before.text, 'p');
      expect(match.text, 'hot');
      expect(after.text, 'o.jpg');
      expect(match.style!.fontWeight, FontWeight.w700);
    });

    testWidgets('highlight is case-insensitive', (tester) async {
      await tester.pumpObers(
        _card(
          file: _file(name: 'Photo.JPG'),
          searchQuery: 'PHOTO',
        ),
      );

      final richText = tester.widget<RichText>(find.byType(RichText).at(1));
      final span = richText.text as TextSpan;

      expect(span.children, hasLength(2));
      final match = span.children![0] as TextSpan;
      expect(match.text, 'Photo');
      expect(match.style!.fontWeight, FontWeight.w700);
    });

    testWidgets('no highlight when query does not match', (tester) async {
      await tester.pumpObers(
        _card(
          file: _file(name: 'photo.jpg'),
          searchQuery: 'xyz',
        ),
      );

      final richText = tester.widget<RichText>(find.byType(RichText).at(1));
      final span = richText.text as TextSpan;

      expect(span.children, hasLength(1));
      expect((span.children![0] as TextSpan).text, 'photo.jpg');
    });

    testWidgets('empty searchQuery renders plain text', (tester) async {
      await tester.pumpObers(
        _card(
          file: _file(name: 'photo.jpg'),
          searchQuery: '',
        ),
      );

      expect(find.text('photo.jpg'), findsOneWidget);
    });
  });
}
