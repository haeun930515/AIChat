import 'dart:developer';
import 'package:chatai/view/ui/login/login_screen.dart';
import 'package:chatai/view/ui/main/main_screen.dart';
import 'package:chatai/provider/firebase_api.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;

class LoginApi {
  final String url =
      'https://us-central1-copyui-82583.cloudfunctions.net/createCustomToken';
  Future<String> createCustomToken(Map<String, dynamic> user) async {
    final customTokenResponse = await http.post(Uri.parse(url), body: user);
    return customTokenResponse.body;
  }

  // 로그인 연동
  kakaoLogin() async {
    if (await AuthApi.instance.hasToken()) {
      try {
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        log('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
        loginOn();
      } catch (error) {
        if (error is KakaoException && error.isInvalidTokenError()) {
          log('토큰 만료 $error');
        } else {
          log('토큰 정보 조회 실패 $error');
        }
        try {
          // 카카오 계정으로 로그인
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          log('로그인 성공 ${token.accessToken}');
          loginOn();
        } catch (error) {
          log('로그인 실패 $error');
        }
      }
    } else {
      // 카카오톡 실행 가능 여부 확인
      // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          loginOn();
        } catch (error) {
          log('카카오톡으로 로그인 실패 $error');
          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            return;
          }
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            await UserApi.instance.loginWithKakaoAccount();
            loginOn();
          } catch (error) {
            log('카카오계정으로 로그인 실패 $error');
          }
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          loginOn();
        } catch (error) {
          log('카카오계정으로 로그인 실패 $error');
        }
      }
    }
  }

  loginOn() async {
    User user = await UserApi.instance.me();
    String id = user.id.toString();
    String name = user.kakaoAccount?.profile?.nickname ?? '';

    log('로그인 성공');
    //loginTokenInfo();
    final token = await createCustomToken({
      'uid': user.id.toString(),
      'displayName': name,
    });
    await auth.FirebaseAuth.instance.signInWithCustomToken(token);
    Get.off(() => GetBuilder<FirebaseService>(
          init: FirebaseService(
            id: id,
            name: name,
            roomNum: 0,
          ),
          builder: (controller) => const MainScreen(),
        ));
  }

  loginTokenInfo() async {
    try {
      AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
      log('토큰 정보 보기 성공'
          '\n회원정보: ${tokenInfo.id}'
          '\n만료시간: ${tokenInfo.expiresIn} 초');
      try {
        User user = await UserApi.instance.me();
        log(
          '사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}',
          // 해당 아이디와 닉네임을 파이어베이스에 있는 데이터와 비교 분석 후 이미 접속을 1번 이상 한 유저라면 데이터를 가져오고 아니라면 저장한다.
        );
      } catch (error) {
        log('사용자 정보 요청 실패 $error');
      }
    } catch (error) {
      log('토큰 정보 보기 실패 $error');
    }
  }

  logOut() async {
    final provider = await _googleSignIn.isSignedIn();
    if (provider) {
      await _googleSignIn.signOut();
      log('로그아웃 성공, Google SDK에서 토큰 삭제');
      Get.offAll(() => const LoginScreen());
    } else {
      try {
        await auth.FirebaseAuth.instance.signOut();
        await UserApi.instance.logout();
        log('로그아웃 성공, Kakao SDK에서 토큰 삭제');
        Get.offAll(() => const LoginScreen());
      } catch (error) {
        log('로그아웃 실패, Kakao SDK에서 토큰 삭제 $error');
      }
    }
  }

  // 구글 로그인
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  googleLoginOn() async {
    // Trigger the Google Authentication flow.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      // Obtain the auth details from the request.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential.
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials.
      return await _auth.signInWithCredential(credential);
    } else {
      throw Exception('Google sign in failed');
    }
  }

  googleLogin() async {
    try {
      final userCredential = await googleLoginOn();
      if (userCredential != null) {
        googleloginOn(userCredential.user);
      } else {
        log('로그인 실패');
      }
    } catch (error) {
      log('로그인 실패 $error');
    }
  }

  googleloginOn(auth.User user) async {
    String id = user.uid;
    String name = user.displayName ?? '';

    log('구글 로그인 성공');
    loginTokenInfo();
    Get.off(() => GetBuilder<FirebaseService>(
          init: FirebaseService(
            id: id,
            name: name,
            roomNum: 0,
          ),
          builder: (controller) => const MainScreen(),
        ));
  }
}
