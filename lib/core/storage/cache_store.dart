import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value cache for JSON lists, used for the offline fallback.
class CacheStore {
  CacheStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _prefix = 'cache_v1:';

  Future<void> saveList(String key, List<Map<String, dynamic>> items) {
    return _prefs.setString('$_prefix$key', jsonEncode(items));
  }

  List<Map<String, dynamic>>? readList(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      // Corrupted entry: treat it as a cache miss.
      return null;
    }
  }
}