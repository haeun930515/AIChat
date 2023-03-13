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
  late FirebaseService p;
  late Stream<DocumentSnapshot> chatRoomsStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    p = Provider.of<FirebaseService>(context, listen: false);
    chatRoomsStream = p.listenToChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: chatRoomsStream,
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
                        },
                        trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => {
                                  p.DelChatRoom(index),
                                  setState(() {}),
                                }),
                        title: FutureBuilder<String>(
                          future: p.RoomTitle(index),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('에러 발생');
                            } else {
                              return Text(
                                snapshot.data!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              );
                            }
                          },
                        ),
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
