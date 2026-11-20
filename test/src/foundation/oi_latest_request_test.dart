// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/_oi_latest_request.dart';

void main() {
  late OiLatestRequest requests;
  late List<String> results;
  late List<Object> errors;

  Future<void> run(
    Future<String> Function() request, {
    bool Function()? active,
  }) => requests.run(
    request,
    active: active ?? () => true,
    onResult: results.add,
    onError: (error, _) => errors.add(error),
  );

  setUp(() {
    requests = OiLatestRequest();
    results = [];
    errors = [];
  });

  test('delivers the result of a single request', () async {
    await run(() async => 'a');

    expect(results, ['a']);
    expect(errors, isEmpty);
  });

  test('drops an earlier request that answers after a later one', () async {
    final first = Completer<String>();
    final second = Completer<String>();
    final firstDone = run(() => first.future);
    final secondDone = run(() => second.future);

    second.complete('second');
    await secondDone;
    first.complete('first');
    await firstDone;

    expect(results, ['second']);
  });

  test('drops an earlier request that answers before a later one', () async {
    final first = Completer<String>();
    final second = Completer<String>();
    final firstDone = run(() => first.future);
    final secondDone = run(() => second.future);

    first.complete('first');
    await firstDone;
    expect(results, isEmpty);

    second.complete('second');
    await secondDone;
    expect(results, ['second']);
  });

  test('drops the failure of a superseded request', () async {
    final first = Completer<String>();
    final second = Completer<String>();
    final firstDone = run(() => first.future);
    final secondDone = run(() => second.future);

    first.completeError(StateError('stale'));
    await firstDone;
    expect(errors, isEmpty);

    second.complete('second');
    await secondDone;
    expect(results, ['second']);
  });

  test('reports an Exception', () async {
    await run(() async => throw const FormatException('bad'));

    expect(errors.single, isFormatException);
    expect(results, isEmpty);
  });

  test('reports an Error', () async {
    await run(() async => throw StateError('bad'));

    expect(errors.single, isStateError);
  });

  test('reports a synchronous throw', () async {
    await run(() => throw StateError('bad'));

    expect(errors.single, isStateError);
  });

  test('cancel drops the request in flight', () async {
    final completer = Completer<String>();
    final done = run(() => completer.future);

    requests.cancel();
    completer.complete('late');
    await done;

    expect(results, isEmpty);
    expect(errors, isEmpty);
  });

  test('drops the answer once the owner is no longer active', () async {
    var active = true;
    final completer = Completer<String>();
    final done = run(() => completer.future, active: () => active);

    active = false;
    completer.complete('late');
    await done;

    expect(results, isEmpty);
  });
}
