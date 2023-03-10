import 'dart:async';

import 'package:chatai/provider/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../model/chat_model.dart';
import '../widgets/chatList_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController sendController;
  late StreamSubscription streamSubscription;

  bool firstLoad = true;

  @override
  void initState() {
    sendController = TextEditingController();
    var p = Provider.of<FirebaseService>(context, listen: false);
    streamSubscription = p.getSnapshot().listen((event) {
      if (firstLoad) {
        firstLoad = false;
        return;
      }
      p.addOne(
          ChatModel.fromJson(event.docs[0].data() as Map<String, dynamic>));
    });
    super.initState();
  }

  // @override
  // void dispose() {
  //   streamSubscription.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    var p = Provider.of<FirebaseService>(context);
    Future.microtask(() {
      p.load();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                p.CreateRoom();
              });
            },
            icon: const Icon(Icons.navigate_next),
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<FirebaseService>(
            builder: (context, p, _) {
              return Expanded(
                child: ListView(
                  reverse: true,
                  children: p.chattingList
                      .map((e) => ChattingItem(
                            chattingModel: e,
                          ))
                      .toList(),
                ),
              );
            },
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
                      controller: sendController,
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
                  onTap: () {
                    var text = sendController.text;
                    //ChatAPIService().getChat(text);
                    sendController.text = '';
                    p.SendMessage(text, 'aitext test');
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
