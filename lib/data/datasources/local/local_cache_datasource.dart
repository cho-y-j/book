import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheDatasource {
  final SharedPreferences _prefs;
  LocalCacheDatasource(this._prefs);

  Future<void> cacheString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<void> cacheStringList(String key, List<String> value) => _prefs.setStringList(key, value);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> cacheBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> remove(String key) => _prefs.remove(key);
  Future<void> clear() => _prefs.clear();
}
