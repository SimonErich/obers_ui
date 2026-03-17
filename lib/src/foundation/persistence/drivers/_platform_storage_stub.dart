// Stub — never used at runtime, only satisfies the analyzer for platforms
// that don't support either html or io.
import 'dart:async';

/// Reads a string value from platform storage.
Future<String?> platformRead(String key) async => null;

/// Writes a string value to platform storage.
Future<void> platformWrite(String key, String value) async {}

/// Deletes a value from platform storage.
Future<void> platformDelete(String key) async {}

/// Returns true if a value exists in platform storage.
Future<bool> platformExists(String key) async => false;
