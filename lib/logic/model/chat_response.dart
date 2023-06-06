sealed class AIChatResponse {}

class Success extends AIChatResponse {
  final String id;
  final String object;
  final int created;
  final Choices choices;
  final Usage usage;

  Success(this.id, this.object, this.created, this.choices, this.usage);

  Choice getFirstChoice() => choices.choices[0];

  factory Success.fromJson(Map<String, dynamic> json) => Success(
        json["id"],
        json["object"],
        json["created"],
        Choices.convert(json["choices"]),
        Usage.convert(json["usage"]),
      );
}

class Choices {
  final List<Choice> choices;

  Choices(this.choices);

  factory Choices.convert(List<dynamic> mapList) {
    // dynamic == Map<String, dynamic>
    List<Choice> choices = [];
    for (var choice in mapList) {
      choices.add(Choice.convert(choice));
    }
    return Choices(choices);
  }
}

class Choice {
  final int index;
  final Message message;
  final String? finishReason;

  Choice(this.index, this.message, this.finishReason);

  factory Choice.convert(Map<String, dynamic> map) => Choice(
      map["index"], Message.convert(map["message"]), map["finish_reason"]);
}

class Message {
  final String role;
  final String content;

  Message(this.role, this.content);

  factory Message.convert(Map<String, dynamic> map) =>
      Message(map["role"]!, map["content"]!);
}

class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  Usage(this.promptTokens, this.completionTokens, this.totalTokens);

  factory Usage.convert(Map<String, dynamic> map) => Usage(
      map["prompt_tokens"]!, map["completion_tokens"]!, map["total_tokens"]!);
}

class Error extends AIChatResponse {
  final String? message;
  final String? type;
  final String? param;
  final String? code;

  Error(this.message, this.type, this.param, this.code);

  factory Error.fromJson(Map<String, dynamic> map) => Error(
      map["error"]["message"],
      map["error"]["type"],
      map["error"]["param"],
      map["error"]["code"]);

  @override
  String toString() {
    StringBuffer sb = StringBuffer("Oops, something went wrong!\n");
    if (message != null && message!.isNotEmpty) sb.writeln("message: $message");
    if (type != null && type!.isNotEmpty) sb.writeln("type: $type");
    if (param != null && param!.isNotEmpty) sb.writeln("param: $param");
    if (code != null && code!.isNotEmpty) sb.writeln("code: $code");
    return sb.toString().substring(0, sb.length - 1);
  }
}
