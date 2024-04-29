import 'package:goodeeps2/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferencesKey {
  accessToken("accessToken"),
  refreshToken("refreshToken"),
  deviceId("deviceId");

  final String rawValue;

  const SharedPreferencesKey(this.rawValue);
}

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  static Future<void> saveData(SharedPreferencesKey key, dynamic value) async {
    final prefs = await _instance;

    if (value is String) {
      await prefs.setString(key.rawValue, value);
    } else if (value is bool) {
      await prefs.setBool(key.rawValue, value);
    } else if (value is int) {
      await prefs.setInt(key.rawValue, value);
    } else if (value is double) {
      await prefs.setDouble(key.rawValue, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key.rawValue, value);
    } else {
      throw ArgumentError("Unsupported data type");
    }
    logger.i("Success fully Save : ${value}");
  }

  static Future<dynamic> fetchData(SharedPreferencesKey key) async {
    final prefs = await _instance;
    final dynamic value = prefs.get(key.rawValue);
    return value;
  }

  static Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear(); // 모든 데이터 삭제
  }
}
