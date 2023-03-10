import 'package:chatai/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService extends ChangeNotifier {
  String id;
  String name;
  int roomNum;
  var chattingList = <ChatModel>[];
  late Stream<List<String>> chatRoomsStream;
  late DocumentReference firebase =
      FirebaseFirestore.instance.collection('users').doc(id);
  FirebaseService({
    required this.id,
    required this.name,
    required this.roomNum,
  });

  // 메시지 전송
  Future SendMessage(String usertext, String aitext) async {
    var now = DateTime.now().millisecondsSinceEpoch;
    await firebase
        .collection("ChatRoom$roomNum")
        .add(ChatModel(id, name, usertext, aitext, now).toJson())
        .then((value) => print("Text Added"))
        .catchError((error) => print("Failed to add text : $error"));
  }

  // 다음 채팅 방
  void CreateRoom() {
    if (roomNum != 9) {
      roomNum++;
      load();
    }
  }

  // 채팅방 삭제
  void DelChatRoom(int roomNum) async {
    await firebase.collection("ChatRoom$roomNum").get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    await firebase.collection("ChatRoom$roomNum").doc().delete();
  }

  Stream<QuerySnapshot> getSnapshot() {
    return firebase
        .collection("ChatRoom$roomNum")
        .orderBy('uploadTime', descending: true)
        .limit(1)
        .snapshots();
  }

  void addOne(ChatModel model) {
    chattingList.insert(0, model);
    notifyListeners();
  }

  Future load() async {
    chattingList = <ChatModel>[];
    var result = await firebase
        .collection("ChatRoom$roomNum")
        .orderBy('uploadTime', descending: true)
        .get();
    var l = result.docs.map((e) => ChatModel.fromJson(e.data())).toList();
    chattingList.addAll(l);
    if (!disposed) {
      notifyListeners();
    }
  }

  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  Future<int> roomCount() async {
    late int count;

    // 서브컬렉션을 구하는 로직 필요!
    count = await listenToChatRooms().length;

    print('방 개수: $count');
    return count;
  }

  Future<Object> RoomTitle(int index) async {
    QuerySnapshot r = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('ChatRoom$index')
        .orderBy('uploadTime', descending: true)
        .limit(1)
        .get();
    String l;
    if (r.docs.isNotEmpty) {
      // 데이터가 있을 경우
      l = r.docs.first.get('usertext');
    } else {
      // 데이터가 없을 경우
      l = '대화가 없습니다.';
    }
    return l;
  }

  Stream<DocumentSnapshot<Object?>> listenToChatRooms() {
    return FirebaseFirestore.instance.collection('users').doc(id).snapshots();
  }
}
