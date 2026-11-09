import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  test(
    'CSS hue arcs retain half-circle ties and longer full-circle semantics',
    () {
      expect(OiHueInterpolation.shorter.interpolate(10, 90, 0.5), 50);
      expect(OiHueInterpolation.longer.interpolate(10, 90, 0.5), 230);
      expect(OiHueInterpolation.longer.interpolate(90, 10, 0.5), 230);
      expect(OiHueInterpolation.longer.interpolate(10, 10, 0.5), 190);
      expect(OiHueInterpolation.shorter.interpolate(10, 190, 0.5), 100);
      expect(OiHueInterpolation.shorter.interpolate(190, 10, 0.5), 100);
      expect(OiHueInterpolation.increasing.interpolate(10, 90, 0.5), 50);
      expect(OiHueInterpolation.decreasing.interpolate(90, 10, 0.5), 50);
      expect(OiHueInterpolation.shorter.interpolate(-10, 370, 0.5), 0);
      expect(OiHueInterpolation.shorter.interpolate(350, 10, 0), 350);
      expect(OiHueInterpolation.shorter.interpolate(350, 10, 1), 10);
    },
  );
}
