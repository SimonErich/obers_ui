import 'dart:async';

/// Runs async requests so that only the most recent one is ever applied.
///
/// A search field fires a request per keystroke and the answers may come back
/// in any order. Each [run] supersedes the ones before it: when an earlier
/// request finally answers or fails, it is dropped without calling back, so it
/// can neither replace newer results nor clear the loading state of a request
/// that is still on its way.
///
/// Not exported from the package.
class OiLatestRequest {
  int _latest = 0;

  /// Drops whatever is in flight; its answer will be ignored.
  ///
  /// Call whenever the query changes, not only when the next request starts:
  /// between the two lies the debounce, and an answer landing there would
  /// still be the latest. Call it from `dispose` too.
  void cancel() => _latest++;

  /// Starts [request], superseding every earlier one.
  ///
  /// [onResult] or [onError] is called only while this request is still the
  /// latest and [active] returns true; pass `() => mounted` from a `State`.
  /// Every failure reaches [onError], an `Error` as much as an `Exception` and
  /// a synchronous throw as much as a failed future, so the caller can always
  /// leave its loading state.
  Future<void> run<T>(
    Future<T> Function() request, {
    required bool Function() active,
    required void Function(T result) onResult,
    required void Function(Object error, StackTrace stackTrace) onError,
  }) async {
    final token = ++_latest;
    bool wanted() => token == _latest && active();

    final T result;
    try {
      result = await request();
      // A failing search must not leave the widget loading forever, whatever
      // it throws.
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      if (wanted()) onError(error, stackTrace);
      return;
    }
    if (wanted()) onResult(result);
  }
}
