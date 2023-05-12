import 'dart:developer';
import 'package:chatai/controller/main_nav_controller.dart';
import 'package:chatai/firebase_options.dart';
import 'package:chatai/routes/app_pages.dart';
import 'package:chatai/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

void main() async {
  //ChatAPIService().getChat('what is your name');

  // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 아래 메서드 호출 필요
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 파이어베이스 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
//
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '0b1acaac136372b78c81a18e037a956a',
    javaScriptAppKey: '5bd2118a462bac58f859d9ceb2c1970e',
  );

  // 카카오 로그인 해시 키 받는 함수
  hasykey();

  // 키 초기화
  await dotenv.load();

  FlutterNativeSplash.remove(); // 초기화가 끝나는 시점에 삽입
  runApp(
    GetMaterialApp(
        title: 'ai chat',
        theme: ThemeData(primaryColor: Colors.white),
        getPages: AppPages.pages,
        initialRoute: Routes.LOGIN,
        initialBinding: BindingsBuilder(() {
          Get.put(MainNavController());
        })),
  );
}

void hasykey() async {
  var hasykey = await KakaoSdk.origin;
  log(hasykey);
}
