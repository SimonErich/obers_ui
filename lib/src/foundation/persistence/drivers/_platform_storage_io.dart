import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Reads a string value using SharedPreferences.
Future<String?> platformRead(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

/// Writes a string value using SharedPreferences.
Future<void> platformWrite(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

/// Deletes a value using SharedPreferences.
Future<void> platformDelete(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}

/// Returns true if a key exists in SharedPreferences.
Future<bool> platformExists(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey(key);
}
