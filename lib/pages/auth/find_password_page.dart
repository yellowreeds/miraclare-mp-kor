import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/widgets/custom_app_bar.dart';
import 'package:goodeeps2/widgets/gradient_background.dart';

import '../../controllers/pages/find_password_controller.dart';

class FindPasswordPage extends StatelessWidget {
  late final FindPasswordController controller =
      Get.find<FindPasswordController>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;


    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onFocus();
    });

    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(title: "비밀번호 찾기"),
        body: ImageBackground(
          child: Container(
            height: screenHeight,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: screenWidth,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Container(
                              width: screenWidth * 0.15,
                              child: TextField(
                                controller: controller.countryCodeController,
                                keyboardType: TextInputType.phone,
                                maxLength: 4,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: '국가 코드',
                                  counterStyle:
                                      TextStyle(color: Colors.transparent),
                                  labelStyle: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Color.fromRGBO(133, 135, 140, 1),
                                    fontSize: 14,
                                  ),
                                  disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Colors.white,
                                    fontSize: 16),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: controller.phoneController,
                                keyboardType: TextInputType.phone,
                                focusNode: controller.phoneFocusNode,
                                maxLength: 15,
                                decoration: InputDecoration(
                                  labelText: '휴대폰 번호(숫자만 입력)',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: Color.fromRGBO(133, 135, 140, 1),
                                      fontSize: 14),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Colors.white,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: '이메일',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Pretendart',
                                      color: Color.fromRGBO(133, 135, 140, 1),
                                      fontSize: 14),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Container(
                        width: screenWidth,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B6DE0), Color(0xFFAB07E4)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () => {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          child: Text(
                            '찾기',
                            style: TextStyle(
                              fontFamily: 'Pretendart',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
                      //             textScaleFactor: 0.8,
                      //             "로그인 중",
                      //             style: TextStyle(
                      //                 color:
                      //                     Color.fromRGBO(231, 231, 232, 1),
                      //                 fontSize: screenHeight * 0.02),
                      //           )
                      //         ],
                      //       )
                      //     : Text(textScaleFactor: 0.8, "")
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
