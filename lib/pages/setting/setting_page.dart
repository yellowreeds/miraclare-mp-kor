import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/controllers/pages/setting_controller.dart';
import 'package:goodeeps2/widgets/backgrounds.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';

class SettingPage extends GetView<SettingController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: "설정",showBackButton:false),
      body: GradientBackground(
        child: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: controller.settings.length,
              itemBuilder: (BuildContext context, int index) {
                SettingType setting = controller.settings[index];
                return Column(children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: setting.leading,
                    // leading: Image(image: setting.image, width: 28, height: 28),
                    trailing: const Icon(Icons.chevron_right, size: 32,
                      color:Colors.white,),
                    title: Text(
                      setting.title,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onTap: () => controller.pressedItem(setting),
                  ),
                  const Divider(
                    color: Colors.white24,
                    thickness: 0.4,
                  ),
                ]);
              },
            ),
            // Positioned(
            //   bottom: 8,
            //   left: 0,
            //   right: 0,
            //   child: Container(
            //     color: Color(0xFF1C1C1C),
            //     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Text(
            //           "펌웨어 정보  1.2 / 3.6",
            //           style: TextStyle(color: Colors.white, fontSize: 14),
            //         ),
            //         Text(
            //           "App 정보  1.2 / 3.6",
            //           style: TextStyle(color: Colors.white, fontSize: 14),
            //         ),
            //         SizedBox(height: 16),
            //         ElevatedButton(
            //           onPressed: () {
            //             // 업데이트 버튼 눌렀을 때 동작
            //           },
            //           style: ElevatedButton.styleFrom(
            //             // primary: Color(0xFF2E2E2E),
            //           ),
            //           child: Center(
            //             child: Text("업데이트"),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

