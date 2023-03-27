import 'package:chatai/controller/login_controller.dart';
import 'package:chatai/provider/kakao_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../repository/login_repository.dart';

// 로그인 화면

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(
        LoginController(repository: LoginRepository(apiClient: LoginApi())));
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(child: GetBuilder<LoginController>(
          builder: (_) {
            return MaterialButton(
              color: Colors.yellow,
              onPressed: () {
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
