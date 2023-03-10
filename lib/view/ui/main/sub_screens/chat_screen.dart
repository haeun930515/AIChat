import 'package:chatai/provider/firebase_api.dart';
import 'package:chatai/view/ui/main/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ChatsScreenState createState() => ChatsScreenState();
}

class ChatsScreenState extends State<ChatsScreen> {
  int maxRoomNum = 10;

  @override
  void didChangeDependencies() {
    Provider.of<FirebaseService>(context, listen: false).listenToChatRooms();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var p = Provider.of<FirebaseService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방'),
      ),
      body: StreamBuilder<DocumentSnapshot<Object?>>(
        stream: p.listenToChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('로딩 실패'));
          } else {
            return ListView.builder(
              key: UniqueKey(),
              itemCount: maxRoomNum,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: Text(
                        '채팅방 $index',
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                          color: p.roomNum == index
                              ? Colors.grey[700]
                              : Colors.blue[700],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(0))),
                      child: ListTile(
                        onTap: () {
                          // 화면 전환 필요!
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: ((context) => ChangeNotifierProvider(
                                      create: (context) => FirebaseService(
                                        id: p.id,
                                        name: p.name,
                                        roomNum: index,
                                      ),
                                      child: const MainScreen(),
                                    ))),
                          );
                          setState(() {
                            p.roomNum = index;
                          });
                          //Get.toNamed()
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => const HomeScreen(),
                          //   ),
                          // );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => p.DelChatRoom(index),
                        ),
                        // 내용이 보이게 수정해야 함
                        title: Text('채팅 내용 $index 번째',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
