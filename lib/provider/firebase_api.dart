import 'package:chatai/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService extends GetxController {
  var isLoading = false.obs;
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
    isLoading.value = true;
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
    isLoading.value = false;
  }

  // 메시지 전송
  Future<void> SendMessage(String usertext, String aitext) async {
    isLoading.value = true;
    if (usertext.isNotEmpty) {
      var now = DateTime.now().millisecondsSinceEpoch;
      ChatModel chat = ChatModel(id, name, usertext, aitext, now);
      await firebase.collection("ChatRoom$roomNum").add(chat.toJson());
    }
    getPreviousChats(roomNum.value);
    loadRoomTitles();
    isLoading.value = false;
  }

  // 채팅방 삭제
  void DelChatRoom(int roomNum) async {
    isLoading.value = true;
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
        await doc.reference.delete();
        update();
        getPreviousChats(roomNum);
        loadRoomTitles();
      }
      isLoading.value = false;
    } catch (e) {
      print('Error deleting chat room: $e');
    }
  }

  RoomCreat(context) {
    isLoading.value = true;
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
    isLoading.value = false;
  }

  Future<String> RoomTitle(int index) async {
    //isLoading.value = true;
    QuerySnapshot r = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('ChatRoom$index')
        .orderBy('uploadTime', descending: true)
        .limit(1)
        .get();
    //isLoading.value = false;
    return r.docs.isNotEmpty ? r.docs.first.get('usertext') : '대화가 없습니다.';
  }

  Future<void> loadRoomTitles() async {
    //isLoading.value = true;
    for (int i = 0; i < roomTitles.length; i++) {
      final title = await RoomTitle(i);
      roomTitles[i] = title;
    }
    //isLoading.value = false;
  }

  loadRoomCount() async {
    //isLoading.value = true;
    int curMaxRoomNum = 0;
    for (int i = 0; i < 10; i++) {
      QuerySnapshot r = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('ChatRoom$i')
          .orderBy('uploadTime', descending: true)
          .limit(1)
          .get();
      if (r.docs.isNotEmpty) {
        curMaxRoomNum = i + 1;
      }
    }
    maxRoomNum.value = curMaxRoomNum;
    //isLoading.value = false;
  }

  Stream<DocumentSnapshot<Object?>> listenToChatRooms() {
    return FirebaseFirestore.instance.collection('users').doc(id).snapshots();
  }

  void ChatClear() {
    chattingList.clear();
  }

  Map<String, String> headers = {
    'Authorization': dotenv.env['CHAT_API_KEY']!,
    "Content-Type": "application/json"
  };

  getChat(String chat) async {
    isLoading.value = true;
    final chatbody = jsonEncode(ChatAISendModel(chat).toJson());
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(url, body: chatbody, headers: headers);
    if (response.statusCode == 200) {
      Map ss = jsonDecode(utf8.decode(response.bodyBytes));
      String answer = {ss['choices'][0]['message']['content']}.toString();
      answer = answer.substring(1, answer.length - 1);
      isLoading.value = false;
      return answer;
    } else {
      isLoading.value = false;
      throw Error();
    }
  }
}
