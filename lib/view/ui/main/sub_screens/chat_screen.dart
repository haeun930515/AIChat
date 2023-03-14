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
            Map<String, dynamic>? data =
                snapshot.data?.data() as Map<String, dynamic>?;
            List<Widget> roomList = [];
            for (int i = 0; i < maxRoomNum; i++) {
              CollectionReference subcollectionRef =
                  p.firebase.collection('ChatRoom$i');
              roomList.add(
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: Text(
                        '채팅방 $i',
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                          color: p.roomNum == i
                              ? Colors.grey[700]
                              : Colors.blue[700],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(0))),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: subcollectionRef.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(child: Text('로딩 실패'));
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            String usertext = '대화가 없습니다.';
                            if (snapshot.hasData &&
                                snapshot.data!.docs.isNotEmpty) {
                              QueryDocumentSnapshot? document =
                                  snapshot.data!.docs.last;
                              usertext = document['usertext'] ?? '대화가 없습니다.';
                            }

                            return ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          ChangeNotifierProvider(
                                            create: (context) =>
                                                FirebaseService(
                                              id: p.id,
                                              name: p.name,
                                              roomNum: i,
                                            ),
                                            child: const MainScreen(),
                                          ))),
                                );
                              },
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => {
                                        p.DelChatRoom(i),
                                        setState(() {}),
                                      }),
                              title: Text(
                                usertext,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView(children: roomList);
          }
        },
      ),
    );
  }
}
