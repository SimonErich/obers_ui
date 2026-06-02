import 'dart:async';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // A small pixel-diff tolerance absorbs sub-pixel anti-aliasing on
  // non-text edges (shadows, rounded borders) that can vary between the
  // machine that generated a golden and CI. CI goldens additionally render
  // text as solid blocks (Ahem), so text never contributes a diff.
  const threshold = 0.01; // 1%

  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(diffThreshold: threshold),
      ciGoldensConfig: CiGoldensConfig(diffThreshold: threshold),
    ),
    run: testMain,
  );
}
