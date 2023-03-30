import 'package:chatai/controller/main_nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sub_screens/chat_screen.dart';
import 'sub_screens/home_screen.dart';
import 'sub_screens/settings_screen.dart';

class MainScreen extends GetView<MainNavController> {
  const MainScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(MainNavController());
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.rootPageIndex.value,
            children: const [HomeScreen(), ChatsScreen(), SettingsScreen()],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.rootPageIndex.toInt(),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: controller.rootPageIndex,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.forum),
                  label: '',
                  activeIcon: Icon(
                    Icons.forum,
                    color: Color.fromRGBO(134, 93, 255, 1),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: '',
                  activeIcon: Icon(
                    Icons.chat,
                    color: Color.fromRGBO(134, 93, 255, 1),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: '',
                  activeIcon: Icon(
                    Icons.settings,
                    color: Color.fromRGBO(134, 93, 255, 1),
                  )),
            ],
          ),
        ));
  }
}
