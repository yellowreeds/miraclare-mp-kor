import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppBarType { title, logo }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // forceMaterialTransparency: true,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
            fontFamily: 'Pretendart',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white),
        textAlign: TextAlign.center,
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Get.back();
              },
            )
          : null,
      iconTheme: const IconThemeData(
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
