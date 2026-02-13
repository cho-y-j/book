import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  bool get hasSeenOnboarding => _prefs.getBool('hasSeenOnboarding') ?? false;
  Future<void> setHasSeenOnboarding(bool value) =>
      _prefs.setBool('hasSeenOnboarding', value);

  // Notification Sound
  String get notificationSound =>
      _prefs.getString('notificationSound') ?? 'notification_default.mp3';
  Future<void> setNotificationSound(String value) =>
      _prefs.setString('notificationSound', value);

  // Recent Searches
  List<String> get recentSearches =>
      _prefs.getStringList('recentSearches') ?? [];
  Future<void> setRecentSearches(List<String> value) =>
      _prefs.setStringList('recentSearches', value);

  Future<void> addRecentSearch(String query) async {
    final searches = recentSearches;
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) searches.removeLast();
    await setRecentSearches(searches);
  }

  Future<void> clearRecentSearches() =>
      _prefs.remove('recentSearches');

  // Clear all
  Future<void> clearAll() => _prefs.clear();
}
