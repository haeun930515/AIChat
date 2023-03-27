import 'package:chatai/controller/chat_controller.dart';
import 'package:chatai/provider/chat_api.dart';
import 'package:chatai/provider/firebase_api.dart';
import 'package:chatai/repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/chatList_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ChatController(
        repository: ChatRepository(apiClient: ChatAPIService())));
    final p = Get.find<FirebaseService>();
    p.getPreviousChats(p.roomNum.value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        backgroundColor: const Color.fromRGBO(134, 93, 255, 1),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                itemCount: p.chattingList.length,
                itemBuilder: (context, index) {
                  final reversedIndex = p.chattingList.length - index - 1;
                  if (reversedIndex < 0) {
                    return null;
                  }
                  final chattingModel = p.chattingList[reversedIndex];
                  return ChattingItem(
                    chattingModel: chattingModel,
                  );
                },
              ),
            ),
          ),
          // 구분선
          Divider(
            thickness: 1.5,
            height: 1.5,
            color: Colors.grey[300],
          ),
          Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .5),
            margin:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: TextField(
                      controller: p.sendController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(fontSize: 27),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '텍스트 입력',
                          hintStyle: TextStyle(color: Colors.grey[400])),
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    var text = p.sendController.text;
                    var md = await Get.find<ChatController>().getAnswer(text);
                    p.SendMessage(text, md);
                    p.sendController.text = '';
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: Icon(
                      Icons.send,
                      size: 33,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
