class ChatModel {
  ChatModel(
    this.id,
    this.name,
    this.usertext,
    this.aitext,
    this.uploadTime,
  );
  final String id;
  final String name;
  final String usertext;
  final String aitext;
  final int uploadTime;

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(json['id'], json['name'], json['usertext'], json['aitext'],
        json['uploadTime']);
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'usertext': usertext,
      'aitext': aitext,
      'uploadTime': uploadTime,
    };
  }
}

/// ChatAIResponseModel - AI 채팅 API 결과값
/// Choices - AI 채팅 결과값 Json format

class ChatAIResponseModel {
  final String id;
  final int created;
  final List<dynamic> choices;

  ChatAIResponseModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        created = json['created'],
        choices = json['choices'];
}

class Choices {
  final String text;
  final int index;

  Choices.fromJson(Map<String, dynamic> json)
      : index = json['index'],
        text = json['text'];
}

/// ChatAISendModel - AI 채팅 API 전달값

class ChatAISendModel {
  final String prompt;
  final String model = "text-davinci-003";

  ChatAISendModel(this.prompt);

  Map<String, dynamic> toJson() {
    return {
      'messages': [
        {"role": "user", "content": prompt}
      ],
      'model': model,
      'max_tokens': 150
    };
  }
}
