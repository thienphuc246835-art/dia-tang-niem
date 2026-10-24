import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local JSON storage. Nothing leaves the device (CLAUDE.md principle 8).
///
/// MVP uses SharedPreferences so the app also runs on web; repositories only talk to
/// this class, so moving to drift/SQLite later does not touch the features.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'dtn.';

  Object? readJson(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  Map<String, dynamic> readMap(String key) {
    final v = readJson(key);
    return v is Map<String, dynamic> ? v : <String, dynamic>{};
  }

  List<Map<String, dynamic>> readList(String key) {
    final v = readJson(key);
    if (v is! List) return [];
    return v.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> writeJson(String key, Object value) =>
      _prefs.setString('$_prefix$key', jsonEncode(value));

  Future<void> clearAll() async {
    for (final key
        in _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList()) {
      await _prefs.remove(key);
    }
  }
}

/// Overridden in main() once SharedPreferences is ready.
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('localStoreProvider must be overridden'),
);

String newId() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);
