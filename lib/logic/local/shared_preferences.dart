import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

Future<String?> get apiKey async {
  final sp = await SharedPreferences.getInstance();
  return sp.getString(API_KEY_KEY);
}

Future<void> saveApiKey(String key) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(API_KEY_KEY, key);
}

Future<void> deleteApiKey() async {
  final sp = await SharedPreferences.getInstance();
  await sp.remove(API_KEY_KEY);
}

Future<double?> get chatTemperature async {
  final sp = await SharedPreferences.getInstance();
  return sp.getDouble(CHAT_TEMPERATURE_KEY);
}

Future<void> saveChatTemperature(double temp) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setDouble(CHAT_TEMPERATURE_KEY, temp);
}

Future<void> deleteChatTemperature() async {
  final sp = await SharedPreferences.getInstance();
  await sp.remove(CHAT_TEMPERATURE_KEY);
}