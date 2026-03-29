// Web platform storage implementation — internal file, docs not required.
import 'dart:async';
import 'package:web/web.dart' as web;

/// Reads a string value from window.localStorage.
Future<String?> platformRead(String key) async =>
    web.window.localStorage.getItem(key);

/// Writes a string value to window.localStorage.
Future<void> platformWrite(String key, String value) async =>
    web.window.localStorage.setItem(key, value);

/// Deletes a value from window.localStorage.
Future<void> platformDelete(String key) async =>
    web.window.localStorage.removeItem(key);

/// Returns true if a key exists in window.localStorage.
Future<bool> platformExists(String key) async =>
    web.window.localStorage.getItem(key) != null;
