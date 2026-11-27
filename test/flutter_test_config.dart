import 'dart:async';
import 'dart:io' show Platform;

import 'package:alchemist/alchemist.dart';
import 'package:obers_ui/src/foundation/oi_input_modality_detector.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // A small pixel-diff tolerance absorbs sub-pixel anti-aliasing on
  // non-text edges (shadows, rounded borders) that can vary between the
  // machine that generated a golden and CI. CI goldens additionally render
  // text as solid blocks (Ahem), so text never contributes a diff.
  const threshold = 0.01; // 1%

  // Only the machine-independent CI goldens (goldens/ci/) are committed; the
  // human-readable platform goldens (goldens/<platform>/) are gitignored and
  // host-specific. So compare platform goldens locally (for debugging) but
  // disable them on CI, where the files don't exist. GitHub Actions and most
  // CI providers set CI=true.
  final isCi = Platform.environment['CI'] == 'true';

  // `flutter test` reports Android as the host platform, which would start
  // every OiApp in touch mode (48 dp minimum touch targets). The suite and the
  // goldens assert desktop layouts, so pin the starting modality to pointer.
  // Tests about the platform seed reset this to null.
  OiInputModalityDetector.debugInitialModalityOverride =
      OiInputModality.pointer;

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        enabled: !isCi,
        diffThreshold: threshold,
      ),
      ciGoldensConfig: const CiGoldensConfig(diffThreshold: threshold),
    ),
    run: testMain,
  );
}
