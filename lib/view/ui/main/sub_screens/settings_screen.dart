import 'package:chatai/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('세팅'),
      ),
      body: Center(
        child: MaterialButton(
          color: Colors.yellow,
          onPressed: () {
            Get.find<LoginController>().kakaoLogout(context);
          },
          child: const Text('Kakao LogOut'),
        ),
      ),
    );
  }
}
