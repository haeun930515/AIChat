import 'package:chatai/controller/login_controller.dart';
import 'package:chatai/provider/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Get.find<FirebaseService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: const Color.fromRGBO(134, 93, 255, 1),
      ),
      body: ListView(
        children: [
          const Divider(
            height: 1,
            thickness: 2,
          ),
          ListTile(
            title: const Text('내 정보'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('내 정보'),
                    content: Text('이름 : ${p.name}'),
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
            },
          ),
          const Divider(
            height: 1,
            thickness: 2,
          ),
          ListTile(
            title: const Text('Kakao LogOut'),
            onTap: () {
              Get.find<LoginController>().kakaoLogout(context);
            },
          ),
          const Divider(
            height: 1,
            thickness: 2,
          ),
          // 다른 버튼들을 추가하려면 ListTile을 추가하면 됩니다.
        ],
      ),
    );
  }
}
