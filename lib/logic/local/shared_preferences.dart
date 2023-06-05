import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: constant_identifier_names

const API_KEY_KEY = "API_KEY";
const CHAT_TEMPERATURE_KEY = "CHAT_TEMPERATURE_KEY";
const GLOBAL_DIRECTIVE_KEY = "GLOBAL_DIRECTIVE_KEY";

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

Future<String?> get globalDirective async {
  final sp = await SharedPreferences.getInstance();
  return sp.getString(GLOBAL_DIRECTIVE_KEY);
}

Future<void> saveGlobalDirective(String temp) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(GLOBAL_DIRECTIVE_KEY, temp);
}

Future<void> deleteGlobalDirective() async {
  final sp = await SharedPreferences.getInstance();
  await sp.remove(GLOBAL_DIRECTIVE_KEY);
}
