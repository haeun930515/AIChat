import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/chat_model.dart';
import 'package:http/http.dart' as http;

class ChatAPIService {
  Map<String, String> headers = {
    "Authorization": dotenv.env['CHAT_API_KEY']!,
    "Content-Type": "application/json"
  };

  getChat(String chat) async {
    final chatbody = jsonEncode(ChatAISendModel(chat).toJson());
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(url, body: chatbody, headers: headers);
    if (response.statusCode == 200) {
      Map ss = jsonDecode(response.body);
      String answer = {ss['choices'][0]['message']['content']}.toString();
      answer = answer.substring(1, answer.length - 1);
      return answer;
    } else {
      throw Error();
    }
  }
}
