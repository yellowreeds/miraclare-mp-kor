import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/controllers/pages/login_controller.dart';
import 'package:goodeeps2/pages/auth/change_password_page.dart';
import 'package:goodeeps2/pages/auth/find_id_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goodeeps2/services/login.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class LoginPage extends StatelessWidget {
  late final LoginController controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
                child: VideoPlayer(controller.videoPlayerController)),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                height: screenHeight,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                              width: screenWidth * 0.5,
                              child: Image.asset('assets/images/gdl.png')),
                          // SizedBox(
                          //   height: screenHeight * 0.015,
                          // ),
                          Container(
                            width: screenWidth,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Expanded(
                                  child: MediaQuery(
                                    data: const MediaQueryData(
                                        textScaleFactor: 0.85),
                                    child: TextField(
                                      controller: controller.idController,
                                      decoration: InputDecoration(
                                        labelText: '아이디',
                                        labelStyle: TextStyle(
                                            fontFamily: 'Pretendart',
                                            color: Color.fromRGBO(
                                                133, 135, 140, 1),
                                            fontSize: screenHeight * 0.025),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenHeight * 0.025),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: screenWidth,
                            // padding: EdgeInsets.all(5),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Expanded(
                                  child: MediaQuery(
                                    data: const MediaQueryData(
                                        textScaleFactor: 0.85),
                                    child: TextField(
                                      controller:
                                          controller.passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: '비밀번호',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Pretendart',
                                          color: Color.fromRGBO(
                                              133, 135, 140, 1),
                                          fontSize: screenHeight * 0.025,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenHeight * 0.025),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Obx(
                                  () => Checkbox(
                                    value: controller.isAutoLogin.value,
                                    onChanged: (newValue) {
                                      logger.i(newValue);
                                      controller.isAutoLogin.value =
                                          newValue ?? false;
                                    },
                                  ),
                                ),
                                Text(
                                  textScaleFactor: 0.85,
                                  '자동 로그인',
                                  style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontSize: screenHeight * 0.022,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          Container(
                            width: screenWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF8B6DE0),
                                  Color(0xFFAB07E4)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: ElevatedButton(
                              onPressed: controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                              child: Text(
                                textScaleFactor: 0.85,
                                '로그인',
                                style: TextStyle(
                                  fontFamily: 'Pretendart',
                                  fontSize: screenHeight * 0.022,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          Container(
                            height: screenHeight * 0.03,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: controller.pressedFindIdButton,
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04),
                                  ),
                                  child: Text(
                                    textScaleFactor: 0.85,
                                    "아이디 찾기",
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.018,
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  thickness: 0.5,
                                ),
                                TextButton(
                                  onPressed:
                                      controller.pressedFindPasswordButton,
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04),
                                  ),
                                  child: Text(
                                    textScaleFactor: 0.85,
                                    "비밀번호 찾기",
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.018,
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  thickness: 0.5,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.toNamed("/terms-agreement");
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           TermsAgreement()),
                                    // );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04),
                                  ),
                                  child: Text(
                                    textScaleFactor: 0.85,
                                    "회원가입",
                                    style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.018,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          // isLoading
                          //     ? Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           Center(
                          //             child: SizedBox(
                          //               width: 25,
                          //               height: 25,
                          //               child: CircularProgressIndicator(
                          //                 color: Colors.white,
                          //               ),
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             width: screenWidth * 0.02,
                          //           ),
                          //           Text(
                          //             textScaleFactor: 0.85,
                          //             "로그인 중",
                          //             style: TextStyle(
                          //                 color:
                          //                     Color.fromRGBO(231, 231, 232, 1),
                          //                 fontSize: screenHeight * 0.02),
                          //           )
                          //         ],
                          //       )
                          //     : Text(textScaleFactor: 0.85, "")
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: screenHeight * 0.08,
                        child:
                            Image.asset('assets/images/logotransparent.png'),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
