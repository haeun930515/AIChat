import 'package:chatai/binding/chat_binding.dart';
import 'package:chatai/binding/login_binding.dart';
import 'package:chatai/routes/app_routes.dart';
import 'package:chatai/view/ui/login/login_screen.dart';
import 'package:chatai/view/ui/main/main_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(
        name: Routes.LOGIN,
        page: () => const LoginScreen(),
        binding: LoginBinding()),
    GetPage(
        name: Routes.MAIN,
        page: () => const MainScreen(),
        bindings: [LoginBinding(), ChatBinding()]),
  ];
}
