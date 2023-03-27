import 'package:chatai/controller/main_nav_controller.dart';
import 'package:chatai/provider/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Get.find<FirebaseService>();
    p.loadRoomTitles();
    p.loadRoomCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방'),
        backgroundColor: const Color.fromRGBO(134, 93, 255, 1),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          p.RoomCreat(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Obx(
        () => ListView.builder(
          itemCount: p.maxRoomNum.value,
          itemBuilder: (context, i) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Text(
                    '채팅방 ${i + 1}',
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                Obx(
                  () => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    decoration: BoxDecoration(
                        color: p.roomNum == i.obs
                            ? Colors.grey[700]
                            : Colors.blue[700],
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(0))),
                    child: ListTile(
                      onTap: () {
                        p.roomNum.value = i;
                        p.getPreviousChats(i);
                        Get.find<MainNavController>().changeRootPageIndex(0);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => {
                          p.DelChatRoom(i),
                        },
                      ),
                      title: Text(
                        p.roomTitles[i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
