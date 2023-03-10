import 'dart:convert';
import '../model/chat_model.dart';
import 'package:http/http.dart' as http;

class ChatApiService {
  static Future<List<ChatModel>> getChats() async {
    List<ChatModel> chatInstances = [];
    // chat api 주소에 맞게 변경 현재는 웹툰을 불러옴
    final url =
        Uri.parse('https://webtoon-crawler.nomadcoders.workers.dev/today');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> chats = jsonDecode(response.body);
      for (var chat in chats) {
        chatInstances.add(ChatModel.fromJson(chat));
      }
      return chatInstances;
    }
    throw Error();
  }
}

class ChatAPIService {
  Map<String, String> headers = {
    "Authorization": "하단 auth key 입력 후 테스트 가능",
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


// chat api = POST "https://api.openai.com/v1/completions"

// "Authorization" : "Bearer sk-9CBc3EwRB65" + "6CLSPxT6BT3BlbkFJHdG9ZggPWwI3o7xcCZEb"
//  "Content-Type" : application/json"

// "{
//        "model": "text-davinci-003",
//        "prompt": "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly.\n\nHuman: Hello, who are you?\nAI: I am an AI created by OpenAI. How can I help you today?\nHuman: I'd like to cancel my subscription.\nAI:",
//        "temperature": 0.9,
//        "max_tokens": 150,
//        "top_p": 1,
//        "frequency_penalty": 0.0,
//        "presence_penalty": 0.6,
//        "stop": [" Human:", " AI:"]
//       }
// "
// 
// {
//     "id": "cmpl-6k78bYYBst84xUbZCQNL8vcReRzIy",
//     "object": "text_completion",
//     "created": 1676448545,
//     "model": "text-davinci-003",
//     "choices": [
//         {
//             "text": " Certainly, I'd be glad to help you with that. What subscription service are you trying to cancel?",
//             "index": 0,
//             "logprobs": null,
//             "finish_reason": "stop"
//         }
//     ],
//     "usage": {
//         "prompt_tokens": 66,
//         "completion_tokens": 21,
//         "total_tokens": 87
//     }
// }
