import 'dart:async';
import 'dart:isolate';

/// Runs [compute] on another isolate and fails if it does not finish
/// within [limit].
///
/// A test timeout cannot interrupt a synchronous endless loop, because the
/// loop blocks the isolate that would fire the timeout. Running the
/// computation elsewhere keeps the test responsive, so a regression that
/// loops forever fails instead of hanging the suite. The worker isolate is
/// killed either way.
///
/// [compute] must not capture anything that cannot be sent to an isolate.
Future<T> runBounded<T>(
  T Function() compute, {
  Duration limit = const Duration(seconds: 10),
}) async {
  final port = ReceivePort();
  final isolate = await Isolate.spawn(_run<T>, (port.sendPort, compute));
  try {
    final message = await port.first.timeout(
      limit,
      onTimeout: () => throw TimeoutException(
        'The computation did not finish; it probably loops forever.',
        limit,
      ),
    );
    final (bool ok, Object? payload) = message as (bool, Object?);
    if (!ok) throw StateError('The computation threw: $payload');
    return payload as T;
  } finally {
    isolate.kill(priority: Isolate.immediate);
    port.close();
  }
}

void _run<T>((SendPort, T Function()) args) {
  final (port, compute) = args;
  try {
    port.send((true, compute()));
  } on Object catch (error) {
    port.send((false, error.toString()));
  }
}
