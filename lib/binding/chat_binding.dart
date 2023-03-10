import 'package:chatai/controller/chat_controller.dart';
import 'package:chatai/provider/chat_api.dart';
import 'package:chatai/repository/chat_repository.dart';
import 'package:get/get.dart';

class ChatBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() {
      return ChatController(
          repository: ChatRepository(apiClient: ChatAPIService()));
    });
  }
}
