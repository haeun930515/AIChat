import 'package:chatai/controller/login_controller.dart';
import 'package:chatai/provider/kakao_api.dart';
import 'package:chatai/repository/login_repository.dart';
import 'package:get/get.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() {
      return LoginController(
          repository: LoginRepository(apiClient: LoginApi()));
    });
  }
}
