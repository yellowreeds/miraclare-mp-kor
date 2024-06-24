import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/home_controller.dart';
import 'package:goodeeps2/controllers/pages/info_controller.dart';
import 'package:goodeeps2/controllers/pages/main_navigation_controller.dart';

class MainNavigationPage extends GetView<MainNavigationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value] ??
          SizedBox.shrink()),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(0xFF231B3D),
            selectedItemColor: Colors.white,
            unselectedItemColor: Color(0xFF817C99),
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTabIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: '평가',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: '설정',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '메인',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info),
                label: '정보',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.logout),
                label: '로그아웃',
              ),
            ],
          )),
    );
  }
}
