enum AIModel {
  gpt3_5Turbo("gpt-3.5-turbo"),
  gpt3_5Turbo_0301("gpt-3.5-turbo-0301");

  const AIModel(this.name);

  final String name;
}

enum Role {
  system("system"),
  user("user"),
  assistant("assistant");

  const Role(this.name);

  final String name;

  static Role parse(String role) => switch (role) {
        "system" => Role.system,
        "user" => Role.user,
        "assistant" => Role.assistant,
        _ => throw StateError("Unreachable code.")
      };
}
