import 'package:chatai/provider/kakao_api.dart';

class LoginRepository {
  final LoginApi apiClient;

  LoginRepository({required this.apiClient});

  kakaoLogin() {
    return apiClient.kakaoLogin();
  }

  logout() {
    return apiClient.logOut();
  }

  googlelogin() {
    return apiClient.googleLogin();
  }
}
