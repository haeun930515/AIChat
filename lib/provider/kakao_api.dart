import 'dart:developer';
import 'package:chatai/view/ui/login/login_screen.dart';
import 'package:chatai/view/ui/main/main_screen.dart';
import 'package:chatai/provider/firebase_api.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LoginApi {
// 로그인 연동
  kakaoLogin(context) async {
    if (await AuthApi.instance.hasToken()) {
      try {
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        log('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
        loginOn(context);
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
          loginOn(context);
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
          loginOn(context);
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
            loginOn(context);
          } catch (error) {
            log('카카오계정으로 로그인 실패 $error');
          }
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          loginOn(context);
        } catch (error) {
          log('카카오계정으로 로그인 실패 $error');
        }
      }
    }
  }

  loginOn(context) async {
    User user = await UserApi.instance.me();
    String id = user.id.toString();
    String name = user.kakaoAccount?.profile?.nickname ?? '';

    log('카카오톡으로 로그인 성공');
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

  kakaoLogOut(context) async {
    try {
      await UserApi.instance.logout();
      log('로그아웃 성공, SDK에서 토큰 삭제');
      Get.offAll(
        () => GetBuilder(builder: (controller) => const LoginScreen()),
      );
    } catch (error) {
      log('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
  }
}
