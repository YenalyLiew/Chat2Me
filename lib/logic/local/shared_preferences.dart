import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: constant_identifier_names

const API_KEY_KEY = "API_KEY";
const CHAT_TEMPERATURE_KEY = "CHAT_TEMPERATURE_KEY";
const GLOBAL_DIRECTIVE_KEY = "GLOBAL_DIRECTIVE_KEY";
const TOP_P_KEY = "TOP_P_KEY";
const MAX_TOKENS_KEY = "MAX_TOKENS_KEY";
const PRESENCE_PENALTY_KEY = "PRESENCE_PENALTY_KEY";
const FREQUENCY_PENALTY_KEY = "FREQUENCY_PENALTY_KEY";

final apiKey = SharedPreferencesManager<String>.secure(API_KEY_KEY);

const chatTemperature = SharedPreferencesManager<double>(CHAT_TEMPERATURE_KEY);

const globalDirective = SharedPreferencesManager<String>(GLOBAL_DIRECTIVE_KEY);

const topP = SharedPreferencesManager<double>(TOP_P_KEY);

const maxTokens = SharedPreferencesManager<int>(MAX_TOKENS_KEY);

const presencePenalty = SharedPreferencesManager<double>(PRESENCE_PENALTY_KEY);

const frequencyPenalty =
    SharedPreferencesManager<double>(FREQUENCY_PENALTY_KEY);

class SharedPreferencesManager<T> {
  const SharedPreferencesManager(this._key, [this._defaultValue])
      : iv = null,
        encrypter = null;

  static const String _secureKey = "Rae6KUIw4HsZWqXuNTXR0mhucZ6gOerI";

  final IV? iv;
  final Encrypter? encrypter;

  /// Only support String. If you want to use other type, go to sleep.
  SharedPreferencesManager.secure(this._key, [this._defaultValue])
      : iv = IV.fromLength(16),
        encrypter = Encrypter(AES(Key.fromUtf8(_secureKey)));

  final String _key;
  final T? _defaultValue;

  Future<T?> get value async {
    final sp = await SharedPreferences.getInstance();
    final T? val = sp.get(_key) as T? ?? _defaultValue;
    return switch (val) {
      String s => (encrypter == null ? s : encrypter!.decrypt64(s, iv: iv!)),
      T? t => t
    } as T?;
  }

  Future<bool> save(T value) async {
    final sp = await SharedPreferences.getInstance();
    return switch (value) {
      String s => await sp.setString(
          _key, encrypter == null ? s : encrypter!.encrypt(s, iv: iv!).base64),
      int i => await sp.setInt(_key, i),
      double d => await sp.setDouble(_key, d),
      bool b => await sp.setBool(_key, b),
      List<String> l => await sp.setStringList(_key, l),
      _ => throw Exception("Type not supported")
    };
  }

  Future<bool> delete() async {
    final sp = await SharedPreferences.getInstance();
    return await sp.remove(_key);
  }
}
