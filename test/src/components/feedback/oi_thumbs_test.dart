// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/feedback/oi_thumbs.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders two thumb buttons', (tester) async {
    await tester.pumpObers(const OiThumbs());
    expect(find.text('👍'), findsNWidgets(2));
  });

  testWidgets('tapping thumbs up fires onChanged with up', (tester) async {
    OiThumbsValue? received;
    await tester.pumpObers(OiThumbs(onChanged: (v) => received = v));
    await tester.tap(find.text('👍').first);
    await tester.pump();
    expect(received, OiThumbsValue.up);
  });

  testWidgets('tapping thumbs down fires onChanged with down', (tester) async {
    OiThumbsValue? received;
    await tester.pumpObers(OiThumbs(onChanged: (v) => received = v));
    await tester.tap(find.text('👍').last);
    await tester.pump();
    expect(received, OiThumbsValue.down);
  });

  testWidgets('tapping active thumb again returns none', (tester) async {
    OiThumbsValue? received;
    await tester.pumpObers(
      OiThumbs(value: OiThumbsValue.up, onChanged: (v) => received = v),
    );
    await tester.tap(find.text('👍').first);
    await tester.pump();
    expect(received, OiThumbsValue.none);
  });

  testWidgets('enabled=false blocks onChanged', (tester) async {
    OiThumbsValue? received;
    await tester.pumpObers(
      OiThumbs(enabled: false, onChanged: (v) => received = v),
    );
    await tester.tap(find.text('👍').first, warnIfMissed: false);
    await tester.pump();
    expect(received, isNull);
  });
}
