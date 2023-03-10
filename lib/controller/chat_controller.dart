import 'package:chatai/repository/chat_repository.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final ChatRepository repository;
  ChatController({required this.repository});

  getAnswer(String text) {
    return repository.getAnswer(text);
  }
}
