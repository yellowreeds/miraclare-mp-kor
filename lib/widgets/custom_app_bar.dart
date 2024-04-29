import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppBarType { title, logo }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
            fontFamily: 'Pretendart',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white),
        textAlign: TextAlign.center,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Get.back();
        },
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      backgroundColor: Colors.transparent,
      // 투명 배경 지정
      elevation: 0, // 그림자 제거
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}
