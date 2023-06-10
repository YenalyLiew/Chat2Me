import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:chat_to_me/logic/local/shared_preferences.dart' as sp;
import 'package:dio/dio.dart';

import '../model/basic_model.dart';
import '../model/chat_message.dart';
import '../model/chat_response.dart' as chat_response;

final _dio = Dio();

void _configureDio(String key) {
  _dio.options.baseUrl = "https://api.openai.com/v1/";
  _dio.options.headers = _getAuthenticationHeaders(key);
  _dio.options.connectTimeout = _timeoutDuration;
  _dio.options.receiveTimeout = _timeoutDuration;
  _dio.options.sendTimeout = _timeoutDuration;
}

const _timeoutDuration = Duration(seconds: 15);

Map<String, String> _getAuthenticationHeaders(String key) => {
      "Authorization": "Bearer $key",
      "Content-Type": "application/json",
    };

Future<chat_response.AIChatResponse> getAIChatResponse({
  required AIModel model,
  required ChatMessages messages,
  double? temperature,
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
  final String? key = await sp.apiKey.value;
  final double? temp = temperature ?? await sp.chatTemperature.value;
  final double? tp = topP ?? await sp.topP.value;
  final int? mt = maxTokens ?? await sp.maxTokens.value;
  final double? pp = presencePenalty ?? await sp.presencePenalty.value;
  final double? fp = frequencyPenalty ?? await sp.frequencyPenalty.value;
  if (key != null) {
    _configureDio(key);
    try {
      final Future<Response<String>> postFuture = _dio.post("chat/completions",
          options: Options(validateStatus: (status) => status != null),
          data: jsonEncode(
            <String, dynamic>{
              "model": model.name,
              "messages": messages.all,
              if (temp != null) "temperature": temp,
              if (tp != null) "top_p": tp,
              if (n != null) "n": n,
              if (stream != null) "stream": stream,
              if (stop != null) "stop": stop,
              if (mt != null) "max_tokens": mt,
              if (pp != null) "presence_penalty": pp,
              if (fp != null) "frequency_penalty": fp,
              if (logitBias != null) "logit_bias": logitBias,
              if (user != null) "user": user,
            },
          ));
      final Response<String> post = await postFuture;

      final body = post.data!;
      Map<String, dynamic> decode = jsonDecode(body);
      if (decode.containsKey("error")) {
        return chat_response.Error.fromJson(decode);
      }
      return chat_response.Success.fromJson(decode);
    } on DioException catch (e) {
      final err = chat_response.Error(
        code: e.response?.statusCode?.toString(),
        message: e.response?.statusMessage,
        type: e.type.toString(),
        param: e.error?.toString(),
      );
      return err;
    }
  }
  return chat_response.Error(
      message: "You have not set OpenAI key yet, right?");
}