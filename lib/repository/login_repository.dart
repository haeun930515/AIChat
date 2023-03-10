import 'package:chatai/provider/kakao_api.dart';

class LoginRepository {
  final LoginApi apiClient;

  LoginRepository({required this.apiClient});

  kakaoLogin(context) {
    return apiClient.kakaoLogin(context);
  }

  kakaoLogout(context) {
    return apiClient.kakaoLogOut(context);
  }
}
