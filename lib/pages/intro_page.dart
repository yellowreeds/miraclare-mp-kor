// intro_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/routes.dart';
import 'package:goodeeps2/utils/shared_preferences_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/pages/auth/login_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();
    setupVideoController();

    Future.delayed(Duration(seconds: 3), () async {});
    checkIsLogin();
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  Future<void> checkIsLogin() async {
    // SharedPreferencesHelper.clearAll();
    final isLogined = await SharedPreferencesHelper.isLogined();
    if (isLogined) {
      Get.offAllNamed(PageRouter.home.rawValue);
    } else {
      Get.offAllNamed(PageRouter.login.rawValue);
    }
  }

  void setupVideoController() {
    videoController = VideoPlayerController.asset('assets/images/bglogin.mp4')
      ..initialize().then((_) {
        videoController.setLooping(true);
        videoController.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: VideoPlayer(videoController),
          ),
          Container(
            height: screenHeight,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                            width: screenHeight * 0.25,
                            child: Image.asset(
                                'assets/images/gdl.png') // goodeeps logo,
                            ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "My only one doctor for the Deep Sleep",
                          // jargon text
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Pretendart',
                            fontSize: screenHeight * 0.02,
                            color: Color.fromRGBO(206, 207, 209, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: screenHeight * 0.08,
                    child: Image.asset(
                        'assets/images/logotransparent.png'), // miraclare logo
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
