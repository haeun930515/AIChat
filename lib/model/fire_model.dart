class FireModel {
  FireModel({
    this.id,
    this.name,
    this.chatList,
  });

  String? id;
  String? name;
  List<List<String>>? chatList;

  FireModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    chatList = json['chatList'];
  }

// 파이어 베이스로 저장 할때 쓴다.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['chatList'] = chatList;
    return map;
  }
}
