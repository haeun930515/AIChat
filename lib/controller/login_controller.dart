import 'package:chatai/repository/login_repository.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final LoginRepository repository;
  LoginController({required this.repository});

  kakaoLogin(context) {
    repository.kakaoLogin(context);
  }

  kakaoLogout(context) {
    repository.kakaoLogout(context);
  }
}
