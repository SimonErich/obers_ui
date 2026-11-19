import 'package:flutter/widgets.dart';

/// Decides when a scrollable's "load more" callback may fire.
///
/// A naive `pixels >= maxScrollExtent - threshold` check fires on every scroll
/// tick while the position stays inside the threshold zone, and never fires
/// for a first page that is shorter than the viewport unless the user
/// scrolls. This latch fires once when the position is inside the zone and
/// stays shut until one of these happens:
///
/// * the position leaves the zone,
/// * the scroll extent changes (more content was laid out),
/// * the owner calls [reset] because its data changed, or
/// * a load started through [track] has completed and the owner calls
///   [rearmAfterUpdate] on its next update.
///
/// Owners call [shouldFire] from their scroll listener and once after layout
/// (first frame and after each update), which covers the short-first-page
/// case.
///
/// Shared by `OiInfiniteScroll`, `OiListView`, `OiActivityFeed` and
/// `OiChatWindow`. Not exported from the package.
class OiLoadMoreLatch {
  bool _busy = false;
  bool _settled = false;
  double? _firedExtent;

  /// Whether a load started through [track] is still running.
  bool get isBusy => _busy;

  /// Whether the load-more callback should be called for [metrics] now.
  ///
  /// Returns true at most once until the latch is re-armed (see the class
  /// documentation). [threshold] is the distance from the end of the content
  /// at which loading starts.
  bool shouldFire(ScrollMetrics metrics, {required double threshold}) {
    if (!metrics.hasPixels || !metrics.hasContentDimensions) return false;
    final extent = metrics.maxScrollExtent;
    if (metrics.pixels < extent - threshold) {
      if (!_busy) _firedExtent = null;
      return false;
    }
    if (_busy || _firedExtent == extent) return false;
    _firedExtent = extent;
    _settled = false;
    return true;
  }

  /// Keeps the latch shut until [load] completes.
  ///
  /// Completes when [load] does, with the same error if it fails.
  Future<void> track(Future<void> load) async {
    _busy = true;
    try {
      await load;
    } finally {
      _busy = false;
      _settled = true;
    }
  }

  /// Re-arms the latch if a tracked load has completed since it last fired.
  ///
  /// Call from `didUpdateWidget`: a rebuild after a finished load usually
  /// means new content, which may still not fill the viewport.
  void rearmAfterUpdate() {
    if (!_settled) return;
    _settled = false;
    _firedExtent = null;
  }

  /// Re-arms the latch unconditionally, e.g. after the item count changed.
  void reset() {
    _settled = false;
    _firedExtent = null;
  }
}
