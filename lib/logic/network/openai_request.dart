import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:chat_to_me/logic/local/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/basic_model.dart';
import '../model/chat_message.dart';
import '../model/chat_response.dart' as chat_response;

const _timeoutDuration = Duration(seconds: 10);

Map<String, String> _getAuthenticationHeaders(String key) => {
      "Authorization": "Bearer $key",
      "Content-Type": "application/json",
    };

Future<chat_response.AIChatResponse?> getAIChatResponse({
  required AIModel model,
  required ChatMessages messages,
  // double? temperature,
  double? topP,
  int? n,
  bool? stream,
  dynamic stop,
  int? maxTokens,
  double? presencePenalty,
  double? frequencyPenalty,
  Map? logitBias,
  String? user,
}) async {
  final String? key = await apiKey;
  final double? temperature = await chatTemperature;
  log(key ?? '', name: "api_key");
  if (key != null) {
    final Future<http.Response> postFuture = http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: _getAuthenticationHeaders(key),
      body: jsonEncode(<String, dynamic>{
        "model": model.name,
        "messages": messages.all,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (n != null) "n": n,
        if (stream != null) "stream": stream,
        if (stop != null) "stop": stop,
        if (maxTokens != null) "max_tokens": maxTokens,
        if (presencePenalty != null) "presence_penalty": presencePenalty,
        if (frequencyPenalty != null) "frequency_penalty": frequencyPenalty,
        if (logitBias != null) "logit_bias": logitBias,
        if (user != null) "user": user,
      }),
    );
    postFuture.timeout(_timeoutDuration,
        onTimeout: () => http.Response(
            jsonEncode(<String, dynamic>{"error": "timeout"}), 408));
    final post = await postFuture;
    String decoded = utf8.decode(post.bodyBytes);
    log(decoded, name: "request_chat_body");
    Map<String, dynamic> decode = jsonDecode(decoded);
    if (decode.containsKey("error")) {
      return chat_response.Error.fromJson(decode);
    }
    return chat_response.Success.fromJson(decode);
  }
  return null;
}
