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

  Future<List<ChatModel>> getPreviousChats(int roomNum) async {
    chattingList = <ChatModel>[];
    final snapshot = await firebase
        .collection('ChatRoom$roomNum')
        .orderBy('uploadTime', descending: true)
        .get();
    try {
      for (var doc in snapshot.docs) {
        final chat = ChatModel.fromJson(doc.data());
        chattingList.add(chat);
      }
      return chattingList;
    } catch (e) {
      print('Error getting previous chats: $e');
      return [];
    }
  }

  // 메시지 전송
  Future<void> SendMessage(String usertext, String aitext) async {
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
    try {
      chattingList = <ChatModel>[];
      QuerySnapshot snapshot =
          await firebase.collection("ChatRoom$roomNum").get();
      List<QueryDocumentSnapshot> docs = snapshot.docs;
      for (QueryDocumentSnapshot doc in docs) {
        await doc.reference
            .collection("ChatRoom$roomNum")
            .get()
            .then((subsnapshot) {
          for (DocumentSnapshot subdoc in subsnapshot.docs) {
            subdoc.reference.delete();
          }
        });
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting chat room: $e');
    }
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

  Future<String> RoomTitle(int index) async {
    QuerySnapshot r = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('ChatRoom$index')
        .orderBy('uploadTime', descending: true)
        .limit(1)
        .get();
    return r.docs.isNotEmpty ? r.docs.first.get('usertext') : '대화가 없습니다.';
  }

  Stream<DocumentSnapshot<Object?>> listenToChatRooms() {
    return FirebaseFirestore.instance.collection('users').doc(id).snapshots();
  }
}
