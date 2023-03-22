import 'package:chatai/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxController {
  String id;
  String name;
  RxInt roomNum;
  RxList<ChatModel> chattingList = <ChatModel>[].obs;
  RxList<String> roomTitles = List.generate(10, (index) => "대화가 없습니다.").obs;
  late Stream<List<String>> chatRoomsStream;
  late DocumentReference firebase =
      FirebaseFirestore.instance.collection('users').doc(id);
  TextEditingController sendController = TextEditingController();
  FirebaseService({
    required this.id,
    required this.name,
    required int roomNum,
  }) : roomNum = roomNum.obs;

  Future<void> getPreviousChats(int roomNum) async {
    final res = await firebase
        .collection('ChatRoom$roomNum')
        .orderBy('uploadTime', descending: true)
        .get();
    final chats = res.docs.map((e) => ChatModel.fromJson(e.data())).toList();
    chattingList.clear();
    chattingList.addAll(chats.reversed);
    update();
  }

  // 메시지 전송
  Future<void> SendMessage(String usertext, String aitext) async {
    if (usertext.isNotEmpty) {
      var now = DateTime.now().millisecondsSinceEpoch;
      ChatModel chat = ChatModel(id, name, usertext, aitext, now);
      await firebase
          .collection("ChatRoom$roomNum")
          .add(chat.toJson())
          .then((value) => {
                print("Text Added"),
                chattingList.add(chat),
              })
          .catchError((error) => print("Failed to add text : $error"));
    }
    update();
  }

  // 채팅방 삭제
  void DelChatRoom(int roomNum) async {
    try {
      chattingList = <ChatModel>[].obs;
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
    update();
  }

  Future load() async {
    chattingList = <ChatModel>[].obs;
    var result = await firebase
        .collection("ChatRoom$roomNum")
        .orderBy('uploadTime', descending: true)
        .get();
    var l = result.docs.map((e) => ChatModel.fromJson(e.data())).toList();
    chattingList.addAll(l);
    update();
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

  Future<void> loadRoomTitles() async {
    for (int i = 0; i < roomTitles.length; i++) {
      final title = await RoomTitle(i);
      roomTitles[i] = title;
    }
  }

  Stream<DocumentSnapshot<Object?>> listenToChatRooms() {
    return FirebaseFirestore.instance.collection('users').doc(id).snapshots();
  }

  void ChatClear() {
    chattingList.clear();
  }
}
