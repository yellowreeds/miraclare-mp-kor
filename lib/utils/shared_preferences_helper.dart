import 'dart:convert';

import 'package:goodeeps2/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferencesKey {
  accessToken("accessToken"),
  refreshToken("refreshToken"),
  survey("survey"),
  deviceId("deviceId"),
  userId("userId"),
  vth("vth");

  final String rawValue;

  const SharedPreferencesKey(this.rawValue);
}

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  static Future<void> saveData(SharedPreferencesKey key, dynamic value) async {
    final prefs = await _instance;

    if (key == SharedPreferencesKey.survey) {
      value = jsonEncode(value);
      logger.i(value);
    }

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
    // logger.i("Success fully Save : ${key} : ${value}");
  }

  static Future<dynamic> fetchData(SharedPreferencesKey key) async {
    final prefs = await _instance;
    final dynamic value = prefs.get(key.rawValue);
    if (key == SharedPreferencesKey.survey && value != null) {
      final List<dynamic> survey = jsonDecode(value);
      return survey;
    }
    return value;
  }

  static Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear(); // 모든 데이터 삭제
  }

  static Future<bool> isLogined() async {
    final String? accessToken = await SharedPreferencesHelper.fetchData(
        SharedPreferencesKey.accessToken);
    final String? refreshToken = await SharedPreferencesHelper.fetchData(
        SharedPreferencesKey.refreshToken);
    logger.i(accessToken);
    logger.i(refreshToken);
    return accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
  }
}
