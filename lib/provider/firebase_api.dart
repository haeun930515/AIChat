import 'package:chatai/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxController {
  String id;
  String name;
  RxInt roomNum;
  RxInt maxRoomNum = RxInt(0);
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

  getPreviousChats(int roomNum) {
    chattingList.clear();
    firebase
        .collection('ChatRoom$roomNum')
        .orderBy("uploadTime", descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        ChatModel cs = ChatModel.fromJson(element.data());
        chattingList.add(cs);
      }
    });
  }

  // 메시지 전송
  Future<void> SendMessage(String usertext, String aitext) async {
    if (usertext.isNotEmpty) {
      var now = DateTime.now().millisecondsSinceEpoch;
      ChatModel chat = ChatModel(id, name, usertext, aitext, now);
      await firebase.collection("ChatRoom$roomNum").add(chat.toJson());
    }
    update();
    loadRoomTitles();
  }

  // 채팅방 삭제
  void DelChatRoom(int roomNum) async {
    try {
      QuerySnapshot snapshot =
          await firebase.collection("ChatRoom$roomNum").get();
      List<QueryDocumentSnapshot> subCollections = snapshot.docs;

      for (QueryDocumentSnapshot doc in subCollections) {
        await firebase.collection("ChatRoom$roomNum").get().then((subsnapshot) {
          for (DocumentSnapshot subdoc in subsnapshot.docs) {
            subdoc.reference.delete();
          }
        });
      }
    } catch (e) {
      print('Error deleting chat room: $e');
    }
  }

  RoomCreat(context) {
    maxRoomNum++;
    if (maxRoomNum > 10) {
      maxRoomNum = 10.obs;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('최대 방 갯수 초과'),
            content: const Text('채팅방은 10개를 초과 할 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('닫기'),
              ),
            ],
          );
        },
      );
    }
    update();
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

  loadRoomCount() async {
    int curMaxRoomNum = 0;
    for (int i = 0; i < roomTitles.length; i++) {
      QuerySnapshot r = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('ChatRoom$i')
          .orderBy('uploadTime', descending: true)
          .limit(1)
          .get();
      if (r.docs.isNotEmpty) {
        curMaxRoomNum++;
      }
    }
    maxRoomNum.value = curMaxRoomNum;
  }

  Stream<DocumentSnapshot<Object?>> listenToChatRooms() {
    return FirebaseFirestore.instance.collection('users').doc(id).snapshots();
  }

  void ChatClear() {
    chattingList.clear();
  }
}
