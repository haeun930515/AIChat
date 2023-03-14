import 'package:chatai/controller/main_nav_controller.dart';
import 'package:chatai/view/ui/main/sub_screens/chat_screen.dart';
import 'package:chatai/view/ui/main/sub_screens/home_screen.dart';
import 'package:chatai/view/ui/main/sub_screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends GetView<MainNavController> {
  const MainScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ));
  }
}
