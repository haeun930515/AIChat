import 'package:chatai/model/chat_model.dart';
import 'package:chatai/provider/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChattingItem extends StatelessWidget {
  ChattingItem({
    Key? key,
    required ChatModel chattingModel,
  })  : chattingModel = chattingModel.obs,
        super(key: key);
  final Rx<ChatModel> chattingModel;

  @override
  Widget build(BuildContext context) {
    var p = Get.find<FirebaseService>();
    var isMe = chattingModel.value.id == p.id;

    return Column(
      children: [
        Chat_Item(context, isMe),
        Chat_Item(context, !isMe),
      ],
    );
  }

  Container Chat_Item(BuildContext context, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Text(
                  isMe ? chattingModel.value.name : 'ai',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: isMe ? Colors.grey[700] : Colors.grey[800],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(30),
                    topRight: const Radius.circular(30),
                    bottomLeft: Radius.circular(isMe ? 30 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 30),
                  ),
                ),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Text(
                          isMe
                              ? chattingModel.value.usertext
                              : chattingModel.value.aitext,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
