import 'package:chatai/controller/chat_controller.dart';
import 'package:chatai/provider/chat_api.dart';
import 'package:chatai/provider/firebase_api.dart';
import 'package:chatai/repository/chat_repository.dart';
import 'package:chatai/view/ui/main/widgets/chatList_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<FirebaseService> {
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
      body: Stack(children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('채팅'),
              backgroundColor: const Color.fromRGBO(134, 93, 255, 1),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                        reverse: true,
                        itemCount: controller.chattingList.length,
                        itemBuilder: (context, index) {
                          return ChattingItem(
                            chattingModel: controller.chattingList[index],
                          );
                        });
                  }),
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
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
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
                          var md = await controller.getChat(text);
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
          ),
        ),
        Obx(
          () => Offstage(
            offstage: !controller.isLoading.value,
            child: Stack(children: const <Widget>[
              Opacity(
                opacity: 0.5,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
