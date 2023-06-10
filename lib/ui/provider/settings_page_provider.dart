import 'package:flutter/material.dart';

import '../../logic/local/shared_preferences.dart' as sp;
import '../../logic/model/chat_message.dart';

class SettingsPageProvider extends ChangeNotifier {
  double? _chatTemperature;
  String? _globalDirective;
  double? _topP;
  int? _maxTokens;
  double? _presencePenalty;
  double? _frequencyPenalty;

  void initialize() async {
    _chatTemperature = await sp.chatTemperature.value;
    _globalDirective = await sp.globalDirective.value;
    _topP = await sp.topP.value;
    _maxTokens = await sp.maxTokens.value;
    _presencePenalty = await sp.presencePenalty.value;
    _frequencyPenalty = await sp.frequencyPenalty.value;
    notifyListeners();
  }

  Future<bool> removeApiKey() async {
    bool res = await sp.apiKey.delete();
    ChatMessages.removeSingleton();
    return res;
  }

  double? get chatTemperature => _chatTemperature;

  Future<bool> setChatTemperature(double? value) async {
    bool res = false;
    if (value != null) {
      await sp.chatTemperature.save(value);
    } else {
      await sp.chatTemperature.delete();
    }
    _chatTemperature = value;
    notifyListeners();
    return res;
  }

  String? get globalDirective => _globalDirective;

  Future<bool> setGlobalDirective(String? value) async {
    bool res = false;
    if (value != null) {
      ChatMessages.singleton().addSystem(value);
      res = await sp.globalDirective.save(value);
    } else {
      ChatMessages.singleton().removeSystem();
      res = await sp.globalDirective.delete();
    }
    _globalDirective = value;
    notifyListeners();
    return res;
  }

  double? get topP => _topP;

  Future<bool> setTopP(double? value) async {
    bool res = false;
    if (value != null) {
      res = await sp.topP.save(value);
    } else {
      res = await sp.topP.delete();
    }
    _topP = value;
    notifyListeners();
    return res;
  }

  int? get maxTokens => _maxTokens;

  Future<bool> setMaxTokens(int? value) async {
    bool res = false;
    if (value != null) {
      res = await sp.maxTokens.save(value);
    } else {
      res = await sp.maxTokens.delete();
    }
    _maxTokens = value;
    notifyListeners();
    return res;
  }

  double? get presencePenalty => _presencePenalty;

  Future<bool> setPresencePenalty(double? value) async {
    bool res = false;
    if (value != null) {
      res = await sp.presencePenalty.save(value);
    } else {
      res = await sp.presencePenalty.delete();
    }
    _presencePenalty = value;
    notifyListeners();
    return res;
  }

  double? get frequencyPenalty => _frequencyPenalty;

  Future<bool> setFrequencyPenalty(double? value) async {
    bool res = false;
    if (value != null) {
      res = await sp.frequencyPenalty.save(value);
    } else {
      res = await sp.frequencyPenalty.delete();
    }
    _frequencyPenalty = value;
    notifyListeners();
    return res;
  }
}
