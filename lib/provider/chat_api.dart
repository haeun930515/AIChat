import 'dart:convert';
import '../model/chat_model.dart';
import 'package:http/http.dart' as http;

class ChatAPIService {
  Map<String, String> headers = {
    "Authorization":
        "Bearer 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",
    "Content-Type": "application/json"
  };

  getChat(String chat) async {
    final chatbody = jsonEncode(ChatAISendModel(chat).toJson());
    final url = Uri.parse('https://api.openai.com/v1/completions');
    final response = await http.post(url, body: chatbody, headers: headers);
    if (response.statusCode == 200) {
      final ChatAIResponseModel md =
          ChatAIResponseModel.fromJson(jsonDecode(response.body));
      Choices cs = Choices.fromJson(md.choices[0]);
      return cs.text;
    } else {
      throw Error();
    }
  }
}
