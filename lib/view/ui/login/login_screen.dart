import 'package:chatai/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 로그인 화면

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(child: GetBuilder<LoginController>(
          builder: (_) {
            return MaterialButton(
              color: Colors.yellow,
              onPressed: () async {
                Get.find<LoginController>().kakaoLogin(context);
              },
              child: const Text('Kakao Login'),
            );
          },
        )),
      ),
    );
  }
}
