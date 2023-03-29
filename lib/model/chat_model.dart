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

/// ChatAISendModel - AI 채팅 API 전달값

class ChatAISendModel {
  final String prompt;
  final String model = "gpt-4";

  ChatAISendModel(this.prompt);

  Map<String, dynamic> toJson() {
    return {
      'messages': [
        {"role": "user", "content": prompt}
      ],
      'model': model
    };
  }
}
